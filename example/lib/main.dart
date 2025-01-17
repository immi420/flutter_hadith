import 'package:flutter_hadith/flutter_hadith.dart';

// Example Usage

void main() async {
  final hadithDB = HadithDatabase();

  // Initialize the package with multiple Hadith database paths
  await hadithDB.init(
    assetPaths: [
      // 'assets/musnad.db',
      // 'assets/bukhari.db',
      // 'assets/muslim.db',
      // 'assets/abu_dawood.db',
      // 'assets/tirmazi.db',
      // 'assets/nasai.db',
      // 'assets/maia.db',
      // 'assets/mishkat.db',
      'assets/silsila.db',
    ],
  );

  // Fetch the list of available Hadith databases
  final availableBooks = hadithDB.getAvailableBooks();
  print('Available Books: $availableBooks');

  // Select a database to work with
  const selectedDatabase = 'silsila.db';

  // Fetch all book titles from the selected database
  final books = await hadithDB.getAllBooks(selectedDatabase);
  print('Books in $selectedDatabase: $books');

  // Get chapters for a specific book (kitab_id = 1)
  final chapters = await hadithDB.getChaptersForBook(selectedDatabase, 1);
  print('Chapters for Book 1: $chapters');

  // Fetch a Hadith by ID
  final hadith = await hadithDB.getHadithById(selectedDatabase, 1);
  print('Hadith: $hadith');

  // Search for a Hadith containing specific text
  final searchResults = await hadithDB.searchHadith(selectedDatabase, 'الحمد');
  print('Search Results: $searchResults');

  // Bookmark a Hadith
  await hadithDB.bookmarkHadith(selectedDatabase, 1, true);
  print('Hadith bookmarked.');

  // Fetch all bookmarked Hadiths
  final bookmarkedHadiths =
      await hadithDB.getBookmarkedHadiths(selectedDatabase);
  print('Bookmarked Hadiths: $bookmarkedHadiths');

  // Fetch Hadiths by narrator
  final hadithsByNarrator =
      await hadithDB.getHadithsByNarrator(selectedDatabase, 'Abu Hurairah');
  print('Hadiths by Narrator: $hadithsByNarrator');

  // Fetch Hadiths by chapter
  final hadithsByChapter =
      await hadithDB.getHadithsForChapter(selectedDatabase, 'Chapter Name');
  print('Hadiths by Chapter: $hadithsByChapter');

  // Close all databases when done
  await hadithDB.close();
}
