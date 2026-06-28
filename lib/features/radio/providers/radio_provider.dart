import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import '../../../data/models/radio_station_model.dart';

class RadioProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  List<RadioStationModel> stations = [];
  bool isLoading = true;
  bool isPlaying = false;
  bool isBuffering = false;
  int? currentStationIndex;
  String? errorMessage;

  RadioProvider() {
    _fetchStations();
    _player.playerStateStream.listen((state) {
      isPlaying = state.playing;
      isBuffering =
          state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;
      notifyListeners();
    });
  }

  Future<void> _fetchStations() async {
    try {
      final response = await http
          .get(Uri.parse('https://mp3quran.net/api/v3/radios?language=ar'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['radios'] ?? [];
        stations = list.map((r) => RadioStationModel.fromJson(r)).toList();
      } else {
        errorMessage = 'Failed to load stations';
      }
    } catch (_) {
      errorMessage = 'Network error. Check your connection.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> playStation(int index) async {
    if (currentStationIndex == index && isPlaying) {
      await _player.pause();
      return;
    }
    if (currentStationIndex == index && !isPlaying) {
      await _player.play();
      return;
    }
    currentStationIndex = index;
    errorMessage = null;
    notifyListeners();
    try {
      await _player.setUrl(stations[index].url);
      await _player.play();
    } catch (_) {
      errorMessage = 'Could not play this station';
      notifyListeners();
    }
  }

  Future<void> stop() async {
    await _player.stop();
    currentStationIndex = null;
    notifyListeners();
  }

  Future<void> retry() async {
    stations = [];
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    await _fetchStations();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
