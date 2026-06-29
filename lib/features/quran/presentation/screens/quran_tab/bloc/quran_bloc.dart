import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../domain/usecase/get_all_surahs_usecase.dart';
import 'quran_contract.dart';

class QuranBloc {
  final GetAllSurahsUseCase _getAllSurahsUseCase;
  final SharedPreferences _sharedPreferences;

  final _stateController = StreamController<QuranState>.broadcast();
  Stream<QuranState> get state => _stateController.stream;
  QuranState _currentState = QuranState();

  final _eventController = StreamController<QuranEvent>();
  Sink<QuranEvent> get eventSink => _eventController.sink;

  QuranBloc(this._getAllSurahsUseCase, this._sharedPreferences) {
    _eventController.stream.listen(_mapEventToState);
  }

  Future<void> _mapEventToState(QuranEvent event) async {
    if (event is LoadQuranEvent) {
      await _handleLoad(event);
    } else if (event is SaveLastReadSurahEvent) {
      await _handleSaveLastRead(event);
    }
  }

  Future<void> _handleLoad(LoadQuranEvent event) async {
    _emit(_currentState.copyWith(isLoading: true));
    
    final surahs = _getAllSurahsUseCase.execute();
    
    final lastIndex = _sharedPreferences.getInt('last_read_surah_index');
    final lastRead = (lastIndex != null && lastIndex >= 0 && lastIndex < surahs.length) 
        ? surahs[lastIndex] 
        : _currentState.lastReadSurah;

    _emit(_currentState.copyWith(
      isLoading: false,
      allSurahs: surahs,
      lastReadSurah: lastRead,
    ));
  }

  Future<void> _handleSaveLastRead(SaveLastReadSurahEvent event) async {
    await _sharedPreferences.setInt('last_read_surah_index', event.index);
    final lastRead = _currentState.allSurahs[event.index];
    _emit(_currentState.copyWith(
      lastReadSurah: lastRead,
    ));
  }

  void _emit(QuranState newState) {
    _currentState = newState;
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
    _eventController.close();
  }
}
