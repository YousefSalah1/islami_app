import '../../domain/entities/prayer_times_entity.dart';

class PrayerTimesModel extends PrayerTimesEntity {
  const PrayerTimesModel({
    required super.fajr,
    required super.sunrise,
    required super.dhuhr,
    required super.asr,
    required super.maghrib,
    required super.isha,
    required super.gregorianReadable,
    required super.weekday,
    required super.hijriDay,
    required super.hijriMonthEn,
    required super.hijriMonthAr,
    required super.hijriYear,
    required super.city,
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
