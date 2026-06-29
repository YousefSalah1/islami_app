import '../../domain/entities/prayer_times_entity.dart';
import '../../domain/repository/times_repository.dart';
import '../models/prayer_times_model.dart';
import '../data_source/local/times_local_data_source.dart';
import '../data_source/remote/times_remote_data_source.dart';

class TimesRepositoryImpl implements TimesRepository {
  final TimesRemoteDataSource _remoteDataSource;
  final TimesLocalDataSource _localDataSource;

  TimesRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<PrayerTimesEntity> getPrayerTimes({required String country, required String city}) async {
    final data = await _remoteDataSource.getTimingsByCity(city: city, country: country);
    final model = PrayerTimesModel.fromJson(data, city);
    await _localDataSource.cachePrayerTimes(data, city);
    return model;
  }

  @override
  Future<void> saveLocation({required String country, required String city}) async {
    return _localDataSource.saveLocation(country: country, city: city);
  }

  @override
  Future<Map<String, String?>> getSavedLocation() async {
    return _localDataSource.getSavedLocation();
  }

  @override
  Future<PrayerTimesEntity?> getCachedPrayerTimes() async {
    final data = await _localDataSource.getCachedPrayerTimes();
    final city = await _localDataSource.getCachedCity();
    if (data != null && city != null) {
      return PrayerTimesModel.fromJson(data, city);
    }
    return null;
  }
}
