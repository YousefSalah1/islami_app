class PrayerTimesEntity {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  final String gregorianReadable;
  final String weekday;

  final String hijriDay;
  final String hijriMonthEn;
  final String hijriMonthAr;
  final String hijriYear;

  final String city;

  const PrayerTimesEntity({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.gregorianReadable,
    required this.weekday,
    required this.hijriDay,
    required this.hijriMonthEn,
    required this.hijriMonthAr,
    required this.hijriYear,
    required this.city,
  });
}
