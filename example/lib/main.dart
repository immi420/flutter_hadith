// example/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_hadith/flutter_hadith.dart';

void main() {
  runApp(const HadithExampleApp());
}

class HadithExampleApp extends StatelessWidget {
  const HadithExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HadithExample(),
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.green,
      ),
    );
  }
}

class HadithExample extends StatefulWidget {
  const HadithExample({super.key});

  @override
  State<HadithExample> createState() => _HadithExampleState();
}

class _HadithExampleState extends State<HadithExample> {
  final HadithDatabase hadithDB = HadithDatabase();
  String _log = '';
  bool _isInitialized = false;
  static const String selectedDatabase = 'silsila.db';

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  void _addLog(String message) {
    setState(() {
      _log += '$message\n\n';
    });
  }

  Future<void> _initializeDatabase() async {
    try {
      await hadithDB.init(
        assetPaths: [
          'assets/silsila.db',
          // Add other database paths as needed
          // 'assets/bukhari.db',
          // 'assets/muslim.db',
          // 'assets/abu_dawood.db',
          // 'assets/tirmazi.db',
          // 'assets/nasai.db',
          // 'assets/maia.db',
          // 'assets/mishkat.db',
        ],
      );
      setState(() => _isInitialized = true);
      _addLog('Database initialized successfully');
    } catch (e) {
      _addLog('Error initializing database: $e');
    }
  }

  Future<void> _demonstrateAllFeatures() async {
    if (!_isInitialized) {
      _addLog('Database not initialized yet');
      return;
    }

    try {
      // 1. Get available books
      final availableBooks = hadithDB.getAvailableBooks();
      _addLog('Available Books: $availableBooks');

      // 2. Get all books from selected database
      final books = await hadithDB.getAllBooks(selectedDatabase);
      _addLog('Books in $selectedDatabase:');
      for (var book in books) {
        _addLog('- ${book.titleEnglish} (${book.titleUrdu})');
      }

      // 3. Get chapters for first book
      if (books.isNotEmpty) {
        final chapters = await hadithDB.getChaptersForBook(
          selectedDatabase,
          books.first.id,
        );
        _addLog('Chapters in first book:');
        for (var chapter in chapters) {
          _addLog('- $chapter');
        }
      }

      // 4. Get specific Hadith
      final hadith = await hadithDB.getHadithById(selectedDatabase, 1);
      if (hadith != null) {
        _addLog('First Hadith:');
        _addLog('Arabic: ${hadith.arabicText}');
        _addLog('Status: ${hadith.status}');

        // 5. Get translations for this Hadith
        final translations = await hadithDB.getTranslationsForHadith(
          selectedDatabase,
          hadith.id,
        );
        _addLog('Translations:');
        for (var translation in translations) {
          _addLog('- ${translation.translatedText}');
        }

        // 6. Bookmark the Hadith
        await hadithDB.bookmarkHadith(selectedDatabase, hadith.id, true);
        _addLog('Hadith bookmarked');
      }

      // 7. Get available languages
      final languages = await hadithDB.getAvailableLanguages(selectedDatabase);
      _addLog('Available Languages:');
      for (var language in languages) {
        _addLog('- ${language.name}');
      }

      // 8. Search for Hadith
      final searchResults = await hadithDB.searchHadith(
        selectedDatabase,
        'الحمد',
      );
      _addLog('Search Results for "الحمد": ${searchResults.length} found');

      // 9. Get bookmarked Hadiths
      final bookmarked = await hadithDB.getBookmarkedHadiths(selectedDatabase);
      _addLog('Bookmarked Hadiths: ${bookmarked.length}');

      // 10. Get Hadiths by narrator
      final narratorHadiths = await hadithDB.getHadithsByNarrator(
        selectedDatabase,
        'Abu Hurairah',
      );
      _addLog('Hadiths by Abu Hurairah: ${narratorHadiths.length}');

      // 11. Get Hadiths by volume
      final volumeHadiths = await hadithDB.getHadithsByVolume(
        selectedDatabase,
        1,
      );
      _addLog('Hadiths in Volume 1: ${volumeHadiths.length}');
    } catch (e) {
      _addLog('Error during demonstration: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadith Database Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isInitialized ? _demonstrateAllFeatures : null,
              child: const Text('Run All Features'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  _log,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _log = ''),
        child: const Icon(Icons.clear),
      ),
    );
  }

  @override
  void dispose() {
    hadithDB.close();
    super.dispose();
  }
}
