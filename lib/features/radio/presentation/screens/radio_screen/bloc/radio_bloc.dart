import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../../../../domain/usecase/get_radio_stations_usecase.dart';
import 'radio_contract.dart';

class RadioBloc {
  final GetRadioStationsUseCase _getRadioStationsUseCase;
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription? _playerSubscription;

  final _stateController = StreamController<RadioState>.broadcast();
  Stream<RadioState> get state => _stateController.stream;
  RadioState _currentState = RadioState();

  final _eventController = StreamController<RadioEvent>();
  Sink<RadioEvent> get eventSink => _eventController.sink;

  RadioBloc(this._getRadioStationsUseCase) {
    _eventController.stream.listen(_mapEventToState);
    
    _playerSubscription = _player.playerStateStream.listen((state) {
      final isPlaying = state.playing;
      final isBuffering = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;
      
      eventSink.add(AudioStateChangedEvent(
        isPlaying: isPlaying,
        isBuffering: isBuffering,
      ));
    });
  }

  Future<void> _mapEventToState(RadioEvent event) async {
    if (event is LoadRadioStationsEvent) {
      await _handleLoad(event);
    } else if (event is PlayStationEvent) {
      await _handlePlayStation(event);
    } else if (event is StopStationEvent) {
      await _handleStopStation(event);
    } else if (event is AudioStateChangedEvent) {
      _emit(_currentState.copyWith(
        isPlaying: event.isPlaying,
        isBuffering: event.isBuffering,
        currentStationIndex: _currentState.currentStationIndex,
      ));
    }
  }

  Future<void> _handleLoad(LoadRadioStationsEvent event) async {
    _emit(_currentState.copyWith(isLoading: true, errorMessage: null, currentStationIndex: _currentState.currentStationIndex));
    try {
      final result = await _getRadioStationsUseCase.execute();
      _emit(_currentState.copyWith(
        isLoading: false,
        isInitialLoad: false,
        isSuccess: true,
        stations: result,
        currentStationIndex: _currentState.currentStationIndex,
      ));
    } catch (e) {
      _emit(_currentState.copyWith(
        isLoading: false,
        isInitialLoad: false,
        errorMessage: e.toString(),
        currentStationIndex: _currentState.currentStationIndex,
      ));
    }
  }

  Future<void> _handlePlayStation(PlayStationEvent event) async {
    final index = event.index;
    
    if (_currentState.currentStationIndex == index && _currentState.isPlaying) {
      await _player.pause();
      return;
    }
    if (_currentState.currentStationIndex == index && !_currentState.isPlaying) {
      await _player.play();
      return;
    }
    
    _emit(_currentState.copyWith(
      currentStationIndex: index,
      errorMessage: null,
    ));
    
    try {
      await _player.setUrl(_currentState.stations[index].url);
      await _player.play();
    } catch (_) {
      _emit(_currentState.copyWith(
        errorMessage: 'Could not play this station',
        currentStationIndex: index,
      ));
    }
  }

  Future<void> _handleStopStation(StopStationEvent event) async {
    await _player.stop();
    _emit(_currentState.copyWith(
      currentStationIndex: null, // explicitly resetting
      errorMessage: null,
    ));
  }

  void _emit(RadioState newState) {
    _currentState = newState;
    _stateController.add(_currentState);
  }

  void dispose() {
    _playerSubscription?.cancel();
    _player.dispose();
    _stateController.close();
    _eventController.close();
  }
}
