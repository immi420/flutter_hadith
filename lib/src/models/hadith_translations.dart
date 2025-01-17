// lib/src/models/hadith_translation.dart
class HadithTranslation {
  final int id;
  final String translatedText;
  final String chapter;
  final String bookName;
  final String narrator;
  final String references;
  final String explanation;
  final int languageId;
  final int hadithId;
  final int hadithRecordId;

  const HadithTranslation({
    required this.id,
    required this.translatedText,
    required this.chapter,
    required this.bookName,
    required this.narrator,
    required this.references,
    required this.explanation,
    required this.languageId,
    required this.hadithId,
    required this.hadithRecordId,
  });

  factory HadithTranslation.fromMap(Map<String, dynamic> map) {
    return HadithTranslation(
      id: map['id'] as int,
      translatedText: map['hadees'] as String,
      chapter: map['baab'] as String,
      bookName: map['kitab'] as String,
      narrator: map['ravi'] as String,
      references: map['Takhreej'] as String,
      explanation: map['wazahat'] as String,
      languageId: map['language_id'] as int,
      hadithId: map['hadees_id'] as int,
      hadithRecordId: map['hadees_record_id'] as int,
    );
  }
}
