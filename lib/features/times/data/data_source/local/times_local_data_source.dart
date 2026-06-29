abstract class TimesLocalDataSource {
  Future<void> saveLocation({required String country, required String city});
  Future<Map<String, String?>> getSavedLocation();
  Future<void> cachePrayerTimes(Map<String, dynamic> data, String city);
  Future<Map<String, dynamic>?> getCachedPrayerTimes();
  Future<String?> getCachedCity();
}
