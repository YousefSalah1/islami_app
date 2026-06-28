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
    final timings = json['data']['timings'];
    final dateData = json['data']['date'];
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
    return 'Fajr'; // next day
  }

  int _toMinutes(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return 0;
    return int.tryParse(parts[0]) ?? 0 * 60 + (int.tryParse(parts[1]) ?? 0);
  }
}
