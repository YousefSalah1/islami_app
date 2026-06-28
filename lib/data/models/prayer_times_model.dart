class PrayerTimesModel {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String date;
  final String city;

  PrayerTimesModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
    required this.city,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json, String cityName) {
    final timings = json['data']['timings'] as Map<String, dynamic>;
    final dateData = json['data']['date'] as Map<String, dynamic>;
    return PrayerTimesModel(
      fajr: timings['Fajr'] ?? '--:--',
      sunrise: timings['Sunrise'] ?? '--:--',
      dhuhr: timings['Dhuhr'] ?? '--:--',
      asr: timings['Asr'] ?? '--:--',
      maghrib: timings['Maghrib'] ?? '--:--',
      isha: timings['Isha'] ?? '--:--',
      date: dateData['readable'] ?? '',
      city: cityName,
    );
  }

  // Returns which prayer is next based on current time
  String get nextPrayer {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    final prayers = {
      'Fajr': _toMinutes(fajr),
      'Dhuhr': _toMinutes(dhuhr),
      'Asr': _toMinutes(asr),
      'Maghrib': _toMinutes(maghrib),
      'Isha': _toMinutes(isha),
    };

    for (final entry in prayers.entries) {
      if (currentMinutes < entry.value) return entry.key;
    }
    return 'Fajr'; // wraps to next day
  }

  // Fixed: operator precedence bug corrected
  int _toMinutes(String time) {
    // Strip any extra info after space (e.g. "03:47 (CET)")
    final clean = time.split(' ').first;
    final parts = clean.split(':');
    if (parts.length < 2) return 0;
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    return hours * 60 + minutes;
  }
}
