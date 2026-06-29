import 'dart:async';
import '../../../../domain/usecase/get_ahadith_usecase.dart';
import 'hadith_contract.dart';

class HadithBloc {
  final GetAhadithUseCase _getAhadithUseCase;

  final _stateController = StreamController<HadithState>.broadcast();
  Stream<HadithState> get state => _stateController.stream;
  HadithState _currentState = HadithState();

  final _eventController = StreamController<HadithEvent>();
  Sink<HadithEvent> get eventSink => _eventController.sink;

  HadithBloc(this._getAhadithUseCase) {
    _eventController.stream.listen(_mapEventToState);
  }

  Future<void> _mapEventToState(HadithEvent event) async {
    if (event is LoadHadithEvent) {
      await _handleLoad(event);
    }
  }

  Future<void> _handleLoad(LoadHadithEvent event) async {
    _emit(_currentState.copyWith(isLoading: true, errorMessage: null));
    try {
      final result = await _getAhadithUseCase.execute();
      _emit(_currentState.copyWith(
        isLoading: false,
        isInitialLoad: false,
        isSuccess: true,
        data: result,
      ));
    } catch (e) {
      _emit(_currentState.copyWith(
        isLoading: false,
        isInitialLoad: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void _emit(HadithState newState) {
    _currentState = newState;
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
    _eventController.close();
  }
}
