// lib/src/models/book.dart
class Book {
  final int id;
  final String titleUrdu;
  final String titleEnglish;
  final int bookNumber;

  const Book({
    required this.id,
    required this.titleUrdu,
    required this.titleEnglish,
    required this.bookNumber,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['Kitab_ID'] as int,
      titleUrdu: map['Kitab'] as String,
      titleEnglish: map['Kitab_Eng'] as String,
      bookNumber: map['BookNo'] as int,
    );
  }
}
