import '../entities/prayer_times_entity.dart';

abstract class TimesRepository {
  Future<PrayerTimesEntity> getPrayerTimes({required String country, required String city});
  Future<void> saveLocation({required String country, required String city});
  Future<Map<String, String?>> getSavedLocation();
  Future<PrayerTimesEntity?> getCachedPrayerTimes();
}
