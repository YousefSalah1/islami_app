import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'times_local_data_source.dart';

class TimesLocalDataSourceImpl implements TimesLocalDataSource {
  final SharedPreferences _prefs;

  TimesLocalDataSourceImpl(this._prefs);

  @override
  Future<void> saveLocation({required String country, required String city}) async {
    await _prefs.setString('pref_country', country);
    await _prefs.setString('pref_city', city);
  }

  @override
  Future<Map<String, String?>> getSavedLocation() async {
    return {
      'country': _prefs.getString('pref_country'),
      'city': _prefs.getString('pref_city'),
    };
  }

  @override
  Future<void> cachePrayerTimes(Map<String, dynamic> data, String city) async {
    await _prefs.setString('prayer_cache_data', jsonEncode(data));
    await _prefs.setString('prayer_cache_city', city);
  }

  @override
  Future<Map<String, dynamic>?> getCachedPrayerTimes() async {
    final raw = _prefs.getString('prayer_cache_data');
    if (raw != null) {
      return jsonDecode(raw) as Map<String, dynamic>;
    }
    return null;
  }

  @override
  Future<String?> getCachedCity() async {
    return _prefs.getString('prayer_cache_city');
  }
}
