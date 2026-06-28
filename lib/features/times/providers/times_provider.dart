import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/prayer_times_model.dart';
import '../../../data/services/prayer_api_service.dart';

enum TimesStatus { initial, loading, success, error }

class TimesProvider extends ChangeNotifier {
  final _api = PrayerApiService();

  TimesStatus status = TimesStatus.initial;
  PrayerTimesModel? prayerTimes;
  String? errorMessage;

  // Currently selected manual location
  String? selectedCountry;
  String? selectedCity;

  // Countdown
  Timer? _countdownTimer;
  Duration countdownDuration = Duration.zero;
  String nextPrayerName = '';

  TimesProvider() {
    _init();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Initialise — restore saved location and auto-fetch
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> _init() async {
    await _restoreLocation();
    if (selectedCountry != null && selectedCity != null) {
      await fetchByCity(country: selectedCountry!, city: selectedCity!, fromInit: true);
    } else {
      await _tryLoadCache();
    }
  }

  Future<void> _restoreLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      selectedCountry = prefs.getString('pref_country');
      selectedCity = prefs.getString('pref_city');
    } catch (_) {}
  }

  Future<void> _saveLocation(String country, String city) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pref_country', country);
      await prefs.setString('pref_city', city);
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Fetch
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> fetchByCity({
    required String country,
    required String city,
    bool fromInit = false,
  }) async {
    if (!fromInit) {
      status = TimesStatus.loading;
      errorMessage = null;
      notifyListeners();
    } else if (status != TimesStatus.success) {
      status = TimesStatus.loading;
      notifyListeners();
    }

    try {
      final data = await _api.getTimingsByCity(city: city, country: country);
      selectedCountry = country;
      selectedCity = city;
      prayerTimes = PrayerTimesModel.fromJson(data, city);
      await _saveLocation(country, city);
      await _cache(data, city);
      _startCountdown();
      status = TimesStatus.success;
      errorMessage = null;
    } catch (_) {
      final cached = await _loadCache();
      if (cached != null) {
        prayerTimes = cached;
        _startCountdown();
        status = TimesStatus.success;
        errorMessage = 'Using cached data — check your connection.';
      } else {
        status = TimesStatus.error;
        errorMessage = 'Could not fetch prayer times.\nCheck your internet connection.';
      }
    }
    notifyListeners();
  }

  /// Called when user picks a new country — resets city selection.
  void selectCountry(String country) {
    if (selectedCountry == country) return;
    selectedCountry = country;
    selectedCity = null;
    notifyListeners();
  }

  /// Called when user picks a new city — auto-fetches.
  Future<void> selectCity(String city) async {
    if (selectedCountry == null) return;
    await fetchByCity(country: selectedCountry!, city: city);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Countdown
  // ─────────────────────────────────────────────────────────────────────────────

  void _startCountdown() {
    _countdownTimer?.cancel();
    _tick();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (prayerTimes == null) return;
    final now = DateTime.now();
    final next = prayerTimes!.nextPrayer;
    nextPrayerName = next;

    DateTime nextTime = prayerTimes!.prayerAsDateTime(_timeForName(next));
    if (nextTime.isBefore(now)) {
      nextTime = nextTime.add(const Duration(days: 1));
    }
    countdownDuration = nextTime.difference(now);
    notifyListeners();
  }

  String _timeForName(String name) => switch (name) {
    'Fajr' => prayerTimes!.fajr,
    'Dhuhr' => prayerTimes!.dhuhr,
    'Asr' => prayerTimes!.asr,
    'Maghrib' => prayerTimes!.maghrib,
    'Isha' => prayerTimes!.isha,
    _ => prayerTimes!.fajr,
  };

  String get countdownString {
    final h = countdownDuration.inHours;
    final m = countdownDuration.inMinutes.remainder(60);
    final s = countdownDuration.inSeconds.remainder(60);
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Cache
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> _cache(Map<String, dynamic> data, String city) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('prayer_cache_data', jsonEncode(data));
      await prefs.setString('prayer_cache_city', city);
    } catch (_) {}
  }

  Future<PrayerTimesModel?> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('prayer_cache_data');
      final city = prefs.getString('prayer_cache_city') ?? '';
      if (raw != null) {
        return PrayerTimesModel.fromJson(jsonDecode(raw) as Map<String, dynamic>, city);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _tryLoadCache() async {
    final cached = await _loadCache();
    if (cached != null && mounted) {
      prayerTimes = cached;
      _startCountdown();
      notifyListeners();
    }
  }

  bool get mounted => !_disposed;
  bool _disposed = false;

  void reset() {
    status = TimesStatus.initial;
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _countdownTimer?.cancel();
    super.dispose();
  }
}
