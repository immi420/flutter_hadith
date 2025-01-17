import 'package:flutter_hadith/flutter_hadith.dart';

// Example Usage
void main() async {
  final hadithDB = HadithDatabase();

  await hadithDB.init(assetPath: 'assets/silsila.db');

  // Fetch all books
  final books = await hadithDB.getAllBooks();
  print('Books: $books');

  // Get chapters for a specific book
  final chapters = await hadithDB.getChaptersForBook(1);
  print('Chapters: $chapters');

  // Fetch a Hadith by ID
  final hadith = await hadithDB.getHadithById(1);
  print('Hadith: $hadith');

  // Search for a Hadith
  final searchResults = await hadithDB.searchHadith('الحمد');
  print('Search Results: $searchResults');

  // Fetch available languages
  final languages = await hadithDB.getAvailableLanguages();
  print('Languages: $languages');

  // Fetch all Hadiths for a specific book
  final hadithsForBook = await hadithDB.getHadithsForBook(1);
  print('Hadiths for Book: $hadithsForBook');

  // Bookmark a Hadith
  await hadithDB.bookmarkHadith(1, true);
  print('Hadith bookmarked.');

  // Fetch bookmarked Hadiths
  final bookmarkedHadiths = await hadithDB.getBookmarkedHadiths();
  print('Bookmarked Hadiths: $bookmarkedHadiths');

  // Fetch Hadiths by narrator
  final hadithsByNarrator = await hadithDB.getHadithsByNarrator('Abu Hurairah');
  print('Hadiths by Narrator: $hadithsByNarrator');

  // Fetch Hadiths by volume
  final hadithsByVolume = await hadithDB.getHadithsByVolume(1);
  print('Hadiths by Volume: $hadithsByVolume');

  await hadithDB.close();
}
