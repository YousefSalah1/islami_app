import '../entities/prayer_times_entity.dart';
import '../repository/times_repository.dart';

abstract class GetCachedPrayerTimesUseCase {
  Future<PrayerTimesEntity?> execute();
}

class GetCachedPrayerTimesUseCaseImpl implements GetCachedPrayerTimesUseCase {
  final TimesRepository _repository;

  GetCachedPrayerTimesUseCaseImpl(this._repository);

  @override
  Future<PrayerTimesEntity?> execute() {
    return _repository.getCachedPrayerTimes();
  }
}
