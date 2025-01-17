// lib/src/enums/hadith_status.dart
enum HadithStatus {
  unknown(0),
  sahih(1),
  hasan(2),
  daeef(3);

  final int value;
  const HadithStatus(this.value);

  factory HadithStatus.fromInt(int value) {
    return HadithStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => HadithStatus.unknown,
    );
  }
}
