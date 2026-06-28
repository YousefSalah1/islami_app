import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/prayer_times_model.dart';
import '../../../data/services/prayer_api_service.dart';

enum TimesStatus { initial, loading, success, error, permissionDenied }

class LocationInfo {
  final String country;
  final String city;
  final String district;

  const LocationInfo({required this.country, required this.city, required this.district});
}

class TimesProvider extends ChangeNotifier {
  final PrayerApiService _api = PrayerApiService();

  TimesStatus status = TimesStatus.initial;
  PrayerTimesModel? prayerTimes;
  LocationInfo? locationInfo;
  String? errorMessage;
  bool hasCachedData = false;

  // Countdown state — updated every second
  Timer? _countdownTimer;
  Duration countdownDuration = Duration.zero;
  String nextPrayerName = '';

  TimesProvider() {
    _tryLoadCache();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // GPS Flow
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> fetchByGPS() async {
    _setLoading();

    try {
      // 1. Location service
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setError('Location services are disabled.\nPlease enable them and try again.');
        return;
      }

      // 2. Permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        status = TimesStatus.permissionDenied;
        errorMessage =
            'Location permission denied.\nPlease allow access or use manual city search.';
        notifyListeners();
        return;
      }

      // 3. Get coordinates
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );

      // 4. Reverse geocode
      String country = '';
      String city = '';
      String district = '';
      try {
        final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          country = p.country ?? '';
          city = (p.locality?.isNotEmpty == true ? p.locality : p.administrativeArea) ?? '';
          district = p.subLocality ?? '';
        }
      } catch (_) {
        // Geocoding failure is non-fatal
      }

      locationInfo = LocationInfo(country: country, city: city, district: district);

      // 5. Fetch prayer times
      final method = PrayerApiService.methodForCountry(country.isNotEmpty ? country : null);
      final data = await _api.getTimingsByCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
        method: method,
      );

      final label = city.isNotEmpty ? city : 'Your Location';
      prayerTimes = PrayerTimesModel.fromJson(data, label);
      await _cache(data, label);
      _startCountdown();
      status = TimesStatus.success;
    } catch (e) {
      // Try cache fallback
      if (prayerTimes != null) {
        status = TimesStatus.success;
        errorMessage = 'Using cached data (offline mode)';
      } else {
        _setError('Failed to get prayer times.\nCheck your internet connection.');
      }
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Manual City Flow
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> fetchByCity({required String city, required String country}) async {
    _setLoading();
    try {
      final data = await _api.getTimingsByCity(city: city, country: country);
      locationInfo = LocationInfo(country: country, city: city, district: '');
      prayerTimes = PrayerTimesModel.fromJson(data, city);
      await _cache(data, city);
      _startCountdown();
      status = TimesStatus.success;
    } catch (_) {
      if (prayerTimes != null) {
        status = TimesStatus.success;
        errorMessage = 'Using cached data — could not update.';
      } else {
        _setError('City not found or no internet.\nCheck spelling and try again.');
      }
    }
    notifyListeners();
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
    // If next prayer is Fajr and it has already passed today → tomorrow
    if (nextTime.isBefore(now)) {
      nextTime = nextTime.add(const Duration(days: 1));
    }
    countdownDuration = nextTime.difference(now);
    notifyListeners();
  }

  String _timeForName(String name) {
    if (prayerTimes == null) return '00:00';
    return switch (name) {
      'Fajr' => prayerTimes!.fajr,
      'Dhuhr' => prayerTimes!.dhuhr,
      'Asr' => prayerTimes!.asr,
      'Maghrib' => prayerTimes!.maghrib,
      'Isha' => prayerTimes!.isha,
      _ => prayerTimes!.fajr,
    };
  }

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

  Future<void> _tryLoadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('prayer_cache_data');
      final city = prefs.getString('prayer_cache_city') ?? '';
      if (raw != null) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        prayerTimes = PrayerTimesModel.fromJson(data, city);
        hasCachedData = true;
        _startCountdown();
        notifyListeners();
      }
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────────

  void _setLoading() {
    status = TimesStatus.loading;
    errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    status = TimesStatus.error;
    errorMessage = message;
    notifyListeners();
  }

  void reset() {
    status = TimesStatus.initial;
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
