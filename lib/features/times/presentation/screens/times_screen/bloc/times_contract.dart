import '../../../../domain/entities/prayer_times_entity.dart';

enum TimesStatus { initial, loading, success, error }

class TimesState {
  final TimesStatus status;
  final PrayerTimesEntity? prayerTimes;
  final String? errorMessage;
  final String? selectedCountry;
  final String? selectedCity;
  final String countdownString;
  final String nextPrayerName;

  TimesState({
    this.status = TimesStatus.initial,
    this.prayerTimes,
    this.errorMessage,
    this.selectedCountry,
    this.selectedCity,
    this.countdownString = '00:00:00',
    this.nextPrayerName = '',
  });

  TimesState copyWith({
    TimesStatus? status,
    PrayerTimesEntity? prayerTimes,
    String? errorMessage,
    String? selectedCountry,
    String? selectedCity,
    String? countdownString,
    String? nextPrayerName,
  }) {
    return TimesState(
      status: status ?? this.status,
      prayerTimes: prayerTimes ?? this.prayerTimes,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedCity: selectedCity ?? this.selectedCity,
      countdownString: countdownString ?? this.countdownString,
      nextPrayerName: nextPrayerName ?? this.nextPrayerName,
    );
  }
}

abstract class TimesEvent {}

class InitTimesEvent extends TimesEvent {}

class FetchTimesByCityEvent extends TimesEvent {
  final String country;
  final String city;
  final bool fromInit;

  FetchTimesByCityEvent({required this.country, required this.city, this.fromInit = false});
}

class SelectCountryEvent extends TimesEvent {
  final String country;
  SelectCountryEvent(this.country);
}

class SelectCityEvent extends TimesEvent {
  final String city;
  SelectCityEvent(this.city);
}

class TickEvent extends TimesEvent {}

class ResetTimesEvent extends TimesEvent {}
