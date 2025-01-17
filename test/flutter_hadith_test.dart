import 'package:flutter_hadith/flutter_hadith.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HadithDatabase hadithDB;

  setUp(() async {
    hadithDB = HadithDatabase();
    await hadithDB.init(assetPath: 'assets/silsila.db');
  });

  tearDown(() async {
    await hadithDB.close();
  });

  test('Fetch all books', () async {
    final books = await hadithDB.getAllBooks();
    expect(books, isNotEmpty, reason: 'Books list should not be empty');
  });

  test('Fetch chapters for a book', () async {
    final chapters = await hadithDB.getChaptersForBook(1);
    expect(chapters, isNotEmpty, reason: 'Chapters list should not be empty');
  });

  test('Fetch Hadith by ID', () async {
    final hadith = await hadithDB.getHadithById(1);
    expect(hadith, isNotEmpty, reason: 'Hadith should not be empty');
    expect(hadith['record_id'], 1,
        reason: 'The record_id should match the query');
  });

  test('Search Hadith text', () async {
    final searchResults = await hadithDB.searchHadith('الحمد');
    expect(searchResults, isNotEmpty,
        reason: 'Search results should not be empty');
  });

  test('Fetch translations for a Hadith', () async {
    final translations = await hadithDB.getTranslationsForHadith(1);
    expect(translations, isNotEmpty,
        reason: 'Translations should not be empty');
  });

  test('Fetch available languages', () async {
    final languages = await hadithDB.getAvailableLanguages();
    expect(languages, isNotEmpty, reason: 'Languages list should not be empty');
  });

  test('Fetch all Hadiths for a book', () async {
    final hadithsForBook = await hadithDB.getHadithsForBook(1);
    expect(hadithsForBook, isNotEmpty,
        reason: 'Hadiths for book should not be empty');
  });

  test('Fetch Hadiths for a chapter', () async {
    final hadithsForChapter =
        await hadithDB.getHadithsForChapter('Chapter Name');
    expect(hadithsForChapter, isNotEmpty,
        reason: 'Hadiths for chapter should not be empty');
  });

  test('Bookmark a Hadith', () async {
    await hadithDB.bookmarkHadith(1, true);
    final bookmarked = await hadithDB.getBookmarkedHadiths();
    expect(bookmarked.any((hadith) => hadith['record_id'] == 1), isTrue,
        reason: 'Hadith should be bookmarked');

    await hadithDB.bookmarkHadith(1, false);
    final unbookmarked = await hadithDB.getBookmarkedHadiths();
    expect(unbookmarked.any((hadith) => hadith['record_id'] == 1), isFalse,
        reason: 'Hadith should not be bookmarked');
  });

  test('Fetch Hadiths by narrator', () async {
    final hadithsByNarrator =
        await hadithDB.getHadithsByNarrator('Abu Hurairah');
    expect(hadithsByNarrator, isNotEmpty,
        reason: 'Hadiths by narrator should not be empty');
  });

  test('Fetch Hadiths by volume', () async {
    final hadithsByVolume = await hadithDB.getHadithsByVolume(1);
    expect(hadithsByVolume, isNotEmpty,
        reason: 'Hadiths by volume should not be empty');
  });
}
