library flutter_hadith;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class HadithDatabase {
  late Map<String, Database> _databases;

  // Initialize the databases
  Future<void> init({required List<String> assetPaths}) async {
    _databases = {};
    final dbDir = await getDatabasesPath();

    for (String assetPath in assetPaths) {
      final dbName = basename(assetPath);
      final dbPath = join(dbDir, dbName);

      // Copy the database from assets if not already present
      if (!File(dbPath).existsSync()) {
        ByteData data = await rootBundle.load(assetPath);
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(dbPath).writeAsBytes(bytes);
      }

      final database = await openDatabase(dbPath);
      _databases[dbName] = database;
    }
  }

  // Fetch all available book databases
  List<String> getAvailableBooks() {
    return _databases.keys.toList();
  }

  // Fetch all book titles for a specific database
  Future<List<Map<String, dynamic>>> getAllBooks(String dbName) async {
    final db = _databases[dbName];
    if (db == null) throw Exception('Database $dbName is not initialized.');
    return await db.query('tbl_Kitab');
  }

  // Get all chapters for a specific book
  Future<List<String>> getChaptersForBook(String dbName, int kitabId) async {
    final db = _databases[dbName];
    if (db == null) throw Exception('Database $dbName is not initialized.');
    final result = await db.query(
      'hadees_languages',
      columns: ['DISTINCT baab'],
      where: 'kitab_id = ?',
      whereArgs: [kitabId],
    );
    return result.map((row) => row['baab'] as String).toList();
  }

  // Fetch Hadith text by ID
  Future<Map<String, dynamic>> getHadithById(
      String dbName, int hadeesId) async {
    final db = _databases[dbName];
    if (db == null) throw Exception('Database $dbName is not initialized.');
    final result = await db.query(
      'hadees',
      where: 'record_id = ?',
      whereArgs: [hadeesId],
    );
    return result.isNotEmpty ? result.first : {};
  }

  // Search Hadith text
  Future<List<Map<String, dynamic>>> searchHadith(
      String dbName, String query) async {
    final db = _databases[dbName];
    if (db == null) throw Exception('Database $dbName is not initialized.');
    final result = await db.rawQuery("""
      SELECT * FROM hadees 
      WHERE arabic LIKE ? OR arabic_without_aeraab LIKE ?
      """, ['%$query%', '%$query%']);
    return result;
  }

  // Fetch translations for a Hadith
  Future<List<Map<String, dynamic>>> getTranslationsForHadith(
      String dbName, int hadeesId) async {
    final db = _databases[dbName];
    if (db == null) throw Exception('Database $dbName is not initialized.');
    final result = await db.query(
      'hadees_languages',
      where: 'hadees_id = ?',
      whereArgs: [hadeesId],
    );
    return result;
  }

  // Fetch available languages
  Future<List<Map<String, dynamic>>> getAvailableLanguages(
      String dbName) async {
    final db = _databases[dbName];
    if (db == null) throw Exception('Database $dbName is not initialized.');
    return await db.query('language');
  }

  // Fetch all Hadiths for a specific book
  Future<List<Map<String, dynamic>>> getHadithsForBook(
      String dbName, int kitabId) async {
    final db = _databases[dbName];
    if (db == null) throw Exception('Database $dbName is not initialized.');
    final result = await db.query(
      'hadees',
      where: 'kitab_id = ?',
      whereArgs: [kitabId],
    );
    return result;
  }

  // Fetch Hadiths by chapter (baab)
  Future<List<Map<String, dynamic>>> getHadithsForChapter(
      String dbName, String chapterName) async {
    final db = _databases[dbName];
    if (db == null) throw Exception('Database $dbName is not initialized.');
    final result = await db.query(
      'hadees_languages',
      where: 'baab = ?',
      whereArgs: [chapterName],
    );
    return result;
  }

  // Bookmark a Hadith
  Future<void> bookmarkHadith(
      String dbName, int hadeesId, bool isBookmarked) async {
    final db = _databases[dbName];
    if (db == null) throw Exception('Database $dbName is not initialized.');
    await db.update(
      'hadees',
      {'bookmarked': isBookmarked ? 1 : 0},
      where: 'record_id = ?',
      whereArgs: [hadeesId],
    );
  }

  // Fetch bookmarked Hadiths
  Future<List<Map<String, dynamic>>> getBookmarkedHadiths(String dbName) async {
    final db = _databases[dbName];
    if (db == null) throw Exception('Database $dbName is not initialized.');
    final result = await db.query(
      'hadees',
      where: 'bookmarked = ?',
      whereArgs: [1],
    );
    return result;
  }

  // Fetch Hadiths by narrator (Ravi)
  Future<List<Map<String, dynamic>>> getHadithsByNarrator(
      String dbName, String narrator) async {
    final db = _databases[dbName];
    if (db == null) throw Exception('Database $dbName is not initialized.');
    final result = await db.query(
      'hadees_languages',
      where: 'ravi LIKE ?',
      whereArgs: ['%$narrator%'],
    );
    return result;
  }

  // Fetch Hadiths by volume
  Future<List<Map<String, dynamic>>> getHadithsByVolume(
      String dbName, int volume) async {
    final db = _databases[dbName];
    if (db == null) throw Exception('Database $dbName is not initialized.');
    final result = await db.query(
      'hadees',
      where: 'volume = ?',
      whereArgs: [volume],
    );
    return result;
  }

  // Close all databases
  Future<void> close() async {
    for (var db in _databases.values) {
      await db.close();
    }
  }
}
