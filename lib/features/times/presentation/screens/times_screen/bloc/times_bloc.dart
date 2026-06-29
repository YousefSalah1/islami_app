import 'dart:async';
import '../../../../domain/usecase/get_prayer_times_usecase.dart';
import '../../../../domain/usecase/save_location_usecase.dart';
import '../../../../domain/usecase/get_saved_location_usecase.dart';
import '../../../../domain/usecase/get_cached_prayer_times_usecase.dart';
import 'times_contract.dart';
import '../../../../data/models/prayer_times_model.dart'; // need the utility methods

class TimesBloc {
  final GetPrayerTimesUseCase _getPrayerTimesUseCase;
  final SaveLocationUseCase _saveLocationUseCase;
  final GetSavedLocationUseCase _getSavedLocationUseCase;
  final GetCachedPrayerTimesUseCase _getCachedPrayerTimesUseCase;

  final _stateController = StreamController<TimesState>.broadcast();
  Stream<TimesState> get state => _stateController.stream;
  TimesState _currentState = TimesState();

  final _eventController = StreamController<TimesEvent>();
  Sink<TimesEvent> get eventSink => _eventController.sink;

  Timer? _countdownTimer;

  TimesBloc(
    this._getPrayerTimesUseCase,
    this._saveLocationUseCase,
    this._getSavedLocationUseCase,
    this._getCachedPrayerTimesUseCase,
  ) {
    _eventController.stream.listen(_mapEventToState);
  }

  Future<void> _mapEventToState(TimesEvent event) async {
    if (event is InitTimesEvent) {
      await _handleInit();
    } else if (event is FetchTimesByCityEvent) {
      await _handleFetchByCity(event);
    } else if (event is SelectCountryEvent) {
      if (_currentState.selectedCountry != event.country) {
        _emit(_currentState.copyWith(
          selectedCountry: event.country,
          selectedCity: null,
        ));
      }
    } else if (event is SelectCityEvent) {
      if (_currentState.selectedCountry != null) {
        _eventController.sink.add(FetchTimesByCityEvent(
          country: _currentState.selectedCountry!,
          city: event.city,
        ));
      }
    } else if (event is TickEvent) {
      _handleTick();
    } else if (event is ResetTimesEvent) {
      _emit(TimesState(
        selectedCountry: _currentState.selectedCountry,
        selectedCity: _currentState.selectedCity,
      ));
    }
  }

  Future<void> _handleInit() async {
    final location = await _getSavedLocationUseCase.execute();
    final country = location['country'];
    final city = location['city'];

    if (country != null && city != null) {
      _emit(_currentState.copyWith(selectedCountry: country, selectedCity: city));
      _eventController.sink.add(FetchTimesByCityEvent(country: country, city: city, fromInit: true));
    } else {
      final cached = await _getCachedPrayerTimesUseCase.execute();
      if (cached != null) {
        _emit(_currentState.copyWith(
          prayerTimes: cached,
          status: TimesStatus.success,
        ));
        _startCountdown();
      }
    }
  }

  Future<void> _handleFetchByCity(FetchTimesByCityEvent event) async {
    if (!event.fromInit) {
      _emit(_currentState.copyWith(status: TimesStatus.loading, errorMessage: null));
    } else if (_currentState.status != TimesStatus.success) {
      _emit(_currentState.copyWith(status: TimesStatus.loading));
    }

    try {
      final times = await _getPrayerTimesUseCase.execute(country: event.country, city: event.city);
      await _saveLocationUseCase.execute(country: event.country, city: event.city);
      _emit(_currentState.copyWith(
        selectedCountry: event.country,
        selectedCity: event.city,
        prayerTimes: times,
        status: TimesStatus.success,
        errorMessage: null,
      ));
      _startCountdown();
    } catch (_) {
      final cached = await _getCachedPrayerTimesUseCase.execute();
      if (cached != null) {
        _emit(_currentState.copyWith(
          prayerTimes: cached,
          status: TimesStatus.success,
          errorMessage: 'Using cached data — check your connection.',
        ));
        _startCountdown();
      } else {
        _emit(_currentState.copyWith(
          status: TimesStatus.error,
          errorMessage: 'Could not fetch prayer times.\nCheck your internet connection.',
        ));
      }
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _handleTick();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_eventController.isClosed) {
        _eventController.sink.add(TickEvent());
      }
    });
  }

  void _handleTick() {
    if (_currentState.prayerTimes == null) return;
    
    // Using cast to model to access utility methods
    final model = _currentState.prayerTimes as PrayerTimesModel;
    final now = DateTime.now();
    final next = model.nextPrayer;

    DateTime nextTime = model.prayerAsDateTime(_timeForName(next, model));
    if (nextTime.isBefore(now)) {
      nextTime = nextTime.add(const Duration(days: 1));
    }
    
    final duration = nextTime.difference(now);
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    final countdownString = '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';

    _emit(_currentState.copyWith(
      nextPrayerName: next,
      countdownString: countdownString,
    ));
  }

  String _timeForName(String name, PrayerTimesModel model) => switch (name) {
    'Fajr' => model.fajr,
    'Dhuhr' => model.dhuhr,
    'Asr' => model.asr,
    'Maghrib' => model.maghrib,
    'Isha' => model.isha,
    _ => model.fajr,
  };

  void _emit(TimesState newState) {
    _currentState = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_currentState);
    }
  }

  void dispose() {
    _countdownTimer?.cancel();
    _stateController.close();
    _eventController.close();
  }
}
