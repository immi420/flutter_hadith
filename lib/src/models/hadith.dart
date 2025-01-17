// lib/src/models/hadith.dart
import '../enums/hadith_status.dart';

class Hadith {
  final int id;
  final int hadithNumber;
  final String arabicText;
  final String arabicTextWithoutDiacritics;
  final int internationalNumber;
  final HadithStatus status;
  final bool isBookmarked;
  final int kitabId;
  final int volume;
  final int bookNumber;

  const Hadith({
    required this.id,
    required this.hadithNumber,
    required this.arabicText,
    required this.arabicTextWithoutDiacritics,
    required this.internationalNumber,
    required this.status,
    required this.isBookmarked,
    required this.kitabId,
    required this.volume,
    required this.bookNumber,
  });

  factory Hadith.fromMap(Map<String, dynamic> map) {
    return Hadith(
      id: map['record_id'] as int,
      hadithNumber: map['hadees_number'] as int,
      arabicText: map['arabic'] as String,
      arabicTextWithoutDiacritics: map['arabic_without_aeraab'] as String,
      internationalNumber: map['international_number'] as int,
      status: HadithStatus.fromInt(map['status'] as int),
      isBookmarked: (map['bookmarked'] as int) == 1,
      kitabId: map['kitab_id'] as int,
      volume: map['volume'] as int,
      bookNumber: map['book_number'] as int,
    );
  }
}
