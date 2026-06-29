import 'dart:async';
import '../../../../domain/usecase/get_azkar_usecase.dart';
import 'azkar_contract.dart';

class AzkarBloc {
  final GetAzkarUseCase _getAzkarUseCase;

  final _stateController = StreamController<AzkarState>.broadcast();
  Stream<AzkarState> get state => _stateController.stream;
  AzkarState _currentState = AzkarState();

  final _eventController = StreamController<AzkarEvent>();
  Sink<AzkarEvent> get eventSink => _eventController.sink;

  AzkarBloc(this._getAzkarUseCase) {
    _eventController.stream.listen(_mapEventToState);
  }

  Future<void> _mapEventToState(AzkarEvent event) async {
    if (event is LoadAzkarEvent) {
      await _handleLoad(event);
    } else if (event is SelectCategoryEvent) {
      _emit(_currentState.copyWith(
        selectedCategoryIndex: event.index,
        currentZikrIndex: 0,
        tapCount: 0,
      ));
    } else if (event is TapZikrEvent) {
      if (_currentState.tapCount < _currentState.targetCount) {
        _emit(_currentState.copyWith(tapCount: _currentState.tapCount + 1));
        if (_currentState.tapCount >= _currentState.targetCount) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (!_eventController.isClosed) {
              _eventController.sink.add(NextZikrEvent());
            }
          });
        }
      }
    } else if (event is NextZikrEvent) {
      final list = _currentState.currentCategoryZikr;
      if (list.isNotEmpty) {
        _emit(_currentState.copyWith(
          currentZikrIndex: (_currentState.currentZikrIndex + 1) % list.length,
          tapCount: 0,
        ));
      }
    } else if (event is ResetZikrEvent) {
      _emit(_currentState.copyWith(tapCount: 0));
    }
  }

  Future<void> _handleLoad(LoadAzkarEvent event) async {
    _emit(_currentState.copyWith(isLoading: true));
    try {
      final azkar = await _getAzkarUseCase.execute();
      _emit(_currentState.copyWith(
        isLoading: false,
        allAzkar: azkar,
        categories: azkar.keys.toList(),
      ));
    } catch (e) {
      _emit(_currentState.copyWith(isLoading: false));
    }
  }

  void _emit(AzkarState newState) {
    _currentState = newState;
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
    _eventController.close();
  }
}
