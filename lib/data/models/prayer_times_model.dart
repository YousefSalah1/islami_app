class PrayerTimesModel {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  // Gregorian date fields
  final String gregorianReadable; // e.g. "28 Jun 2024"
  final String weekday; // e.g. "Saturday"

  // Hijri date fields
  final String hijriDay;
  final String hijriMonthEn;
  final String hijriMonthAr;
  final String hijriYear;

  final String city;

  PrayerTimesModel({
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

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json, String cityName) {
    final data = json['data'] as Map<String, dynamic>;
    final timings = data['timings'] as Map<String, dynamic>;
    final dateData = data['date'] as Map<String, dynamic>;

    final gregorian = dateData['gregorian'] as Map<String, dynamic>? ?? {};
    final hijri = dateData['hijri'] as Map<String, dynamic>? ?? {};
    final hijriMonth = hijri['month'] as Map<String, dynamic>? ?? {};
    final gregorianWeekday = gregorian['weekday'] as Map<String, dynamic>? ?? {};

    return PrayerTimesModel(
      fajr: _cleanTime(timings['Fajr']),
      sunrise: _cleanTime(timings['Sunrise']),
      dhuhr: _cleanTime(timings['Dhuhr']),
      asr: _cleanTime(timings['Asr']),
      maghrib: _cleanTime(timings['Maghrib']),
      isha: _cleanTime(timings['Isha']),
      gregorianReadable: dateData['readable'] as String? ?? '',
      weekday: gregorianWeekday['en'] as String? ?? '',
      hijriDay: hijri['day'] as String? ?? '',
      hijriMonthEn: hijriMonth['en'] as String? ?? '',
      hijriMonthAr: hijriMonth['ar'] as String? ?? '',
      hijriYear: hijri['year'] as String? ?? '',
      city: cityName,
    );
  }

  static String _cleanTime(dynamic raw) {
    if (raw == null) return '--:--';
    // Strip timezone suffix like "(EET)" or "(CET)"
    return (raw as String).split(' ').first;
  }

  String get hijriDateString => '$hijriDay $hijriMonthAr $hijriYear هـ';

  /// Current active prayer (the one whose time has passed most recently)
  String get currentPrayer {
    final now = DateTime.now();
    final nowMins = now.hour * 60 + now.minute;

    final ordered = [
      ('Fajr', _toMinutes(fajr)),
      ('Sunrise', _toMinutes(sunrise)),
      ('Dhuhr', _toMinutes(dhuhr)),
      ('Asr', _toMinutes(asr)),
      ('Maghrib', _toMinutes(maghrib)),
      ('Isha', _toMinutes(isha)),
    ];

    String current = 'Isha';
    for (final (name, mins) in ordered) {
      if (nowMins >= mins) current = name;
    }
    return current;
  }

  /// Next prayer name (first prayer after now, wraps to Fajr)
  String get nextPrayer {
    final now = DateTime.now();
    final nowMins = now.hour * 60 + now.minute;

    final ordered = [
      ('Fajr', _toMinutes(fajr)),
      ('Dhuhr', _toMinutes(dhuhr)),
      ('Asr', _toMinutes(asr)),
      ('Maghrib', _toMinutes(maghrib)),
      ('Isha', _toMinutes(isha)),
    ];

    for (final (name, mins) in ordered) {
      if (nowMins < mins) return name;
    }
    return 'Fajr';
  }

  int _toMinutes(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  DateTime prayerAsDateTime(String timeStr) {
    final clean = timeStr.split(' ').first;
    final parts = clean.split(':');
    if (parts.length < 2) return DateTime.now();
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.tryParse(parts[0]) ?? 0,
      int.tryParse(parts[1]) ?? 0,
    );
  }
}
