// lib/src/hadith_database.dart
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'exceptions/hadith_database_exception.dart';
import 'models/book.dart';
import 'models/hadith.dart';
import 'models/hadith_translations.dart';
import 'models/language.dart';

class HadithDatabase {
  late final Map<String, Database> _databases;
  bool _isInitialized = false;

  Future<void> init({required List<String> assetPaths}) async {
    try {
      _databases = {};
      final dbDir = await getDatabasesPath();

      for (String assetPath in assetPaths) {
        final dbName = basename(assetPath);
        final dbPath = join(dbDir, dbName);

        await _copyDatabaseIfNeeded(assetPath, dbPath);
        final database = await openDatabase(dbPath);
        _databases[dbName] = database;
      }
      _isInitialized = true;
    } catch (e) {
      throw HadithDatabaseException(
          'Failed to initialize database', e.toString());
    }
  }

  Future<void> _copyDatabaseIfNeeded(String assetPath, String dbPath) async {
    if (!File(dbPath).existsSync()) {
      try {
        ByteData data = await rootBundle.load(assetPath);
        List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        await File(dbPath).writeAsBytes(bytes);
      } catch (e) {
        throw HadithDatabaseException(
          'Failed to copy database from assets',
          e.toString(),
        );
      }
    }
  }

  void _checkInitialization() {
    if (!_isInitialized) {
      throw HadithDatabaseException(
        'Database not initialized',
        'Call init() before using any database operations',
      );
    }
  }

  List<String> getAvailableBooks() {
    _checkInitialization();
    return _databases.keys.toList();
  }

  Future<List<Book>> getAllBooks(String dbName) async {
    _checkInitialization();
    final db = _getDatabase(dbName);
    final results = await db.query('tbl_Kitab');
    return results.map((map) => Book.fromMap(map)).toList();
  }

  Future<List<String>> getChaptersForBook(String dbName, int kitabId) async {
    _checkInitialization();
    final db = _getDatabase(dbName);
    final result = await db.query(
      'hadees_languages',
      columns: ['DISTINCT baab'],
      where: 'kitab_id = ?',
      whereArgs: [kitabId],
    );
    return result.map((row) => row['baab'] as String).toList();
  }

  Future<Hadith?> getHadithById(String dbName, int hadithId) async {
    _checkInitialization();
    final db = _getDatabase(dbName);
    final result = await db.query(
      'hadees',
      where: 'record_id = ?',
      whereArgs: [hadithId],
    );
    return result.isNotEmpty ? Hadith.fromMap(result.first) : null;
  }

  Future<List<Hadith>> searchHadith(String dbName, String query) async {
    _checkInitialization();
    final db = _getDatabase(dbName);
    final result = await db.rawQuery("""
      SELECT * FROM hadees 
      WHERE arabic LIKE ? OR arabic_without_aeraab LIKE ?
    """, ['%$query%', '%$query%']);
    return result.map((map) => Hadith.fromMap(map)).toList();
  }

  Future<List<HadithTranslation>> getTranslationsForHadith(
    String dbName,
    int hadithId,
  ) async {
    _checkInitialization();
    final db = _getDatabase(dbName);
    final result = await db.query(
      'hadees_languages',
      where: 'hadees_id = ?',
      whereArgs: [hadithId],
    );
    return result.map((map) => HadithTranslation.fromMap(map)).toList();
  }

  Future<List<Language>> getAvailableLanguages(String dbName) async {
    _checkInitialization();
    final db = _getDatabase(dbName);
    final result = await db.query('language');
    return result.map((map) => Language.fromMap(map)).toList();
  }

  Future<List<Hadith>> getHadithsForBook(String dbName, int kitabId) async {
    _checkInitialization();
    final db = _getDatabase(dbName);
    final result = await db.query(
      'hadees',
      where: 'kitab_id = ?',
      whereArgs: [kitabId],
    );
    return result.map((map) => Hadith.fromMap(map)).toList();
  }

  Future<List<HadithTranslation>> getHadithsForChapter(
    String dbName,
    String chapterName,
  ) async {
    _checkInitialization();
    final db = _getDatabase(dbName);
    final result = await db.query(
      'hadees_languages',
      where: 'baab = ?',
      whereArgs: [chapterName],
    );
    return result.map((map) => HadithTranslation.fromMap(map)).toList();
  }

  Future<void> bookmarkHadith(
    String dbName,
    int hadithId,
    bool isBookmarked,
  ) async {
    _checkInitialization();
    final db = _getDatabase(dbName);
    await db.update(
      'hadees',
      {'bookmarked': isBookmarked ? 1 : 0},
      where: 'record_id = ?',
      whereArgs: [hadithId],
    );
  }

  Future<List<Hadith>> getBookmarkedHadiths(String dbName) async {
    _checkInitialization();
    final db = _getDatabase(dbName);
    final result = await db.query(
      'hadees',
      where: 'bookmarked = ?',
      whereArgs: [1],
    );
    return result.map((map) => Hadith.fromMap(map)).toList();
  }

  Future<List<HadithTranslation>> getHadithsByNarrator(
    String dbName,
    String narrator,
  ) async {
    _checkInitialization();
    final db = _getDatabase(dbName);
    final result = await db.query(
      'hadees_languages',
      where: 'ravi LIKE ?',
      whereArgs: ['%$narrator%'],
    );
    return result.map((map) => HadithTranslation.fromMap(map)).toList();
  }

  Future<List<Hadith>> getHadithsByVolume(
    String dbName,
    int volume,
  ) async {
    _checkInitialization();
    final db = _getDatabase(dbName);
    final result = await db.query(
      'hadees',
      where: 'volume = ?',
      whereArgs: [volume],
    );
    return result.map((map) => Hadith.fromMap(map)).toList();
  }

  Database _getDatabase(String dbName) {
    final db = _databases[dbName];
    if (db == null) {
      throw HadithDatabaseException('Database $dbName is not initialized');
    }
    return db;
  }

  Future<void> close() async {
    _checkInitialization();
    for (var db in _databases.values) {
      await db.close();
    }
    _isInitialized = false;
  }
}
