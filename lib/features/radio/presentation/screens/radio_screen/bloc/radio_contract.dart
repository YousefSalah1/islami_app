import '../../../../domain/entities/radio_station_entity.dart';

class RadioState {
  final bool isLoading;
  final bool isInitialLoad;
  final bool isSuccess;
  final List<RadioStationEntity> stations;
  final String? errorMessage;
  
  final bool isPlaying;
  final bool isBuffering;
  final int? currentStationIndex;

  RadioState({
    this.isLoading = false,
    this.isInitialLoad = true,
    this.isSuccess = false,
    this.stations = const [],
    this.errorMessage,
    this.isPlaying = false,
    this.isBuffering = false,
    this.currentStationIndex,
  });

  RadioState copyWith({
    bool? isLoading,
    bool? isInitialLoad,
    bool? isSuccess,
    List<RadioStationEntity>? stations,
    String? errorMessage,
    bool? isPlaying,
    bool? isBuffering,
    int? currentStationIndex,
  }) {
    return RadioState(
      isLoading: isLoading ?? this.isLoading,
      isInitialLoad: isInitialLoad ?? this.isInitialLoad,
      isSuccess: isSuccess ?? this.isSuccess,
      stations: stations ?? this.stations,
      errorMessage: errorMessage,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      currentStationIndex: currentStationIndex, // intentionally raw to allow null-reset
    );
  }
}

abstract class RadioEvent {}

class LoadRadioStationsEvent extends RadioEvent {}

class PlayStationEvent extends RadioEvent {
  final int index;
  PlayStationEvent(this.index);
}

class StopStationEvent extends RadioEvent {}

class AudioStateChangedEvent extends RadioEvent {
  final bool isPlaying;
  final bool isBuffering;
  AudioStateChangedEvent({required this.isPlaying, required this.isBuffering});
}
