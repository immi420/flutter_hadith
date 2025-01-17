library flutter_hadith;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class HadithDatabase {
  late Database _database;

  // Initialize the database
  Future<void> init({required String assetPath}) async {
    final dbDir = await getDatabasesPath();
    final dbPath = join(dbDir, 'hadith_books.db');

    // Copy the database from assets if not already present
    if (!File(dbPath).existsSync()) {
      ByteData data = await rootBundle.load(assetPath);
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes);
    }

    _database = await openDatabase(dbPath);
  }

  // Fetch all book titles
  Future<List<Map<String, dynamic>>> getAllBooks() async {
    return await _database.query('tbl_Kitab');
  }

  // Get all chapters for a specific book
  Future<List<String>> getChaptersForBook(int kitabId) async {
    final result = await _database.query(
      'hadees_languages',
      columns: ['DISTINCT baab'],
      where: 'kitab_id = ?',
      whereArgs: [kitabId],
    );
    return result.map((row) => row['baab'] as String).toList();
  }

  // Fetch Hadith text by ID
  Future<Map<String, dynamic>> getHadithById(int hadeesId) async {
    final result = await _database.query(
      'hadees',
      where: 'record_id = ?',
      whereArgs: [hadeesId],
    );
    return result.isNotEmpty ? result.first : {};
  }

  // Search Hadith text
  Future<List<Map<String, dynamic>>> searchHadith(String query) async {
    final result = await _database.rawQuery("""
      SELECT * FROM hadees 
      WHERE arabic LIKE ? OR arabic_without_aeraab LIKE ?
      """, ['%$query%', '%$query%']);
    return result;
  }

  // Fetch translations for a Hadith
  Future<List<Map<String, dynamic>>> getTranslationsForHadith(
      int hadeesId) async {
    final result = await _database.query(
      'hadees_languages',
      where: 'hadees_id = ?',
      whereArgs: [hadeesId],
    );
    return result;
  }

  // Fetch available languages
  Future<List<Map<String, dynamic>>> getAvailableLanguages() async {
    return await _database.query('language');
  }

  // Fetch all Hadiths for a specific book
  Future<List<Map<String, dynamic>>> getHadithsForBook(int kitabId) async {
    final result = await _database.query(
      'hadees',
      where: 'kitab_id = ?',
      whereArgs: [kitabId],
    );
    return result;
  }

  // Fetch Hadiths by chapter (baab)
  Future<List<Map<String, dynamic>>> getHadithsForChapter(
      String chapterName) async {
    final result = await _database.query(
      'hadees_languages',
      where: 'baab = ?',
      whereArgs: [chapterName],
    );
    return result;
  }

  // Bookmark a Hadith
  Future<void> bookmarkHadith(int hadeesId, bool isBookmarked) async {
    await _database.update(
      'hadees',
      {'bookmarked': isBookmarked ? 1 : 0},
      where: 'record_id = ?',
      whereArgs: [hadeesId],
    );
  }

  // Fetch bookmarked Hadiths
  Future<List<Map<String, dynamic>>> getBookmarkedHadiths() async {
    final result = await _database.query(
      'hadees',
      where: 'bookmarked = ?',
      whereArgs: [1],
    );
    return result;
  }

  // Fetch Hadiths by narrator (Ravi)
  Future<List<Map<String, dynamic>>> getHadithsByNarrator(
      String narrator) async {
    final result = await _database.query(
      'hadees_languages',
      where: 'ravi LIKE ?',
      whereArgs: ['%$narrator%'],
    );
    return result;
  }

  // Fetch Hadiths by volume
  Future<List<Map<String, dynamic>>> getHadithsByVolume(int volume) async {
    final result = await _database.query(
      'hadees',
      where: 'volume = ?',
      whereArgs: [volume],
    );
    return result;
  }

  // Close the database
  Future<void> close() async {
    await _database.close();
  }
}
