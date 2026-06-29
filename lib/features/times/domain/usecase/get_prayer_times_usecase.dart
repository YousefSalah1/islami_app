import '../entities/prayer_times_entity.dart';
import '../repository/times_repository.dart';

abstract class GetPrayerTimesUseCase {
  Future<PrayerTimesEntity> execute({required String country, required String city});
}

class GetPrayerTimesUseCaseImpl implements GetPrayerTimesUseCase {
  final TimesRepository _repository;

  GetPrayerTimesUseCaseImpl(this._repository);

  @override
  Future<PrayerTimesEntity> execute({required String country, required String city}) {
    return _repository.getPrayerTimes(country: country, city: city);
  }
}
