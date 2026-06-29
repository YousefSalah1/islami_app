import 'dart:async';
import '../../../../domain/usecase/get_surah_verses_usecase.dart';
import 'sura_details_contract.dart';

class SuraDetailsBloc {
  final GetSurahVersesUseCase _getSurahVersesUseCase;

  final _stateController = StreamController<SuraDetailsState>.broadcast();
  Stream<SuraDetailsState> get state => _stateController.stream;
  SuraDetailsState _currentState = SuraDetailsState();

  final _eventController = StreamController<SuraDetailsEvent>();
  Sink<SuraDetailsEvent> get eventSink => _eventController.sink;

  SuraDetailsBloc(this._getSurahVersesUseCase) {
    _eventController.stream.listen(_mapEventToState);
  }

  Future<void> _mapEventToState(SuraDetailsEvent event) async {
    if (event is LoadVersesEvent) {
      await _handleLoad(event);
    }
  }

  Future<void> _handleLoad(LoadVersesEvent event) async {
    _emit(_currentState.copyWith(isLoading: true, errorMessage: null));
    try {
      final verses = await _getSurahVersesUseCase.execute(event.surahIndex);
      _emit(_currentState.copyWith(isLoading: false, verses: verses));
    } catch (e) {
      _emit(_currentState.copyWith(isLoading: false, errorMessage: 'Failed to load verses'));
    }
  }

  void _emit(SuraDetailsState newState) {
    _currentState = newState;
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
    _eventController.close();
  }
}
