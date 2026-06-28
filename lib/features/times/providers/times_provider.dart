import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../../data/models/prayer_times_model.dart';

class TimesProvider extends ChangeNotifier {
  PrayerTimesModel? prayerTimes;
  bool isLoading = false;
  String? errorMessage;
  String cityInput = 'Cairo';
  String countryInput = 'Egypt';

  Future<void> fetchByCity({String? city, String? country}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final c = city ?? cityInput;
    final co = country ?? countryInput;

    try {
      final now = DateTime.now();
      final date =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
      final uri = Uri.parse('https://api.aladhan.com/v1/timingsByCity/$date?city=$c&country=$co');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200) {
          prayerTimes = PrayerTimesModel.fromJson(data, c);
          cityInput = c;
          countryInput = co;
        } else {
          errorMessage = 'City not found. Try another name.';
        }
      } else {
        errorMessage = 'Server error. Try again.';
      }
    } catch (_) {
      errorMessage = 'Network error. Check your connection.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchByLocation() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        errorMessage = 'Please enable location services.';
        isLoading = false;
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        errorMessage = 'Location permission denied.';
        isLoading = false;
        notifyListeners();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );

      final now = DateTime.now();
      final date =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
      final uri = Uri.parse(
        'https://api.aladhan.com/v1/timings/$date?latitude=${position.latitude}&longitude=${position.longitude}',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200) {
          prayerTimes = PrayerTimesModel.fromJson(data, 'Current Location');
        } else {
          errorMessage = 'Could not get prayer times.';
        }
      } else {
        errorMessage = 'Server error. Try again.';
      }
    } catch (_) {
      errorMessage = 'Failed to get your location.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
