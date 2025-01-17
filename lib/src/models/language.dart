// lib/src/models/language.dart
class Language {
  final int id;
  final String name;

  const Language({
    required this.id,
    required this.name,
  });

  factory Language.fromMap(Map<String, dynamic> map) {
    return Language(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }
}
