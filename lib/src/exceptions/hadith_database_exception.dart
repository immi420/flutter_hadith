// lib/src/exceptions/hadith_database_exception.dart
class HadithDatabaseException implements Exception {
  final String message;
  final String? details;

  HadithDatabaseException(this.message, [this.details]);

  @override
  String toString() => details != null ? '$message: $details' : message;
}
