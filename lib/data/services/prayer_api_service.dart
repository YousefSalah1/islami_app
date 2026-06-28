import 'dart:convert';
import 'package:dio/dio.dart';

class PrayerApiService {
  late final Dio _dio;

  static const _baseUrl = 'https://api.aladhan.com/v1/';

  PrayerApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
  }

  /// Fetch timings by GPS coordinates (lat/lon + method)
  Future<Map<String, dynamic>> getTimingsByCoordinates({
    required double latitude,
    required double longitude,
    int method = 3,
  }) async {
    final now = DateTime.now();
    final date =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

    final response = await _dio.get(
      'timings/$date',
      queryParameters: {'latitude': latitude, 'longitude': longitude, 'method': method},
    );
    return _parseResponse(response);
  }

  /// Fetch timings by city + country name
  Future<Map<String, dynamic>> getTimingsByCity({
    required String city,
    required String country,
  }) async {
    final now = DateTime.now();
    final date =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

    final response = await _dio.get(
      'timingsByCity/$date',
      queryParameters: {'city': city, 'country': country},
    );
    return _parseResponse(response);
  }

  Map<String, dynamic> _parseResponse(Response response) {
    final data = response.data is String
        ? jsonDecode(response.data as String) as Map<String, dynamic>
        : response.data as Map<String, dynamic>;

    if (data['code'] != 200) {
      throw Exception('API error: ${data['status']}');
    }
    return data;
  }

  /// Determine the best calculation method based on country name.
  static int methodForCountry(String? country) {
    const map = {
      'Egypt': 5,
      'Saudi Arabia': 4,
      'Qatar': 4,
      'United Arab Emirates': 4,
      'Bahrain': 4,
      'Kuwait': 4,
      'Oman': 4,
      'Yemen': 4,
      'United States': 2,
      'Canada': 2,
      'Pakistan': 1,
      'India': 1,
      'Bangladesh': 1,
      'Afghanistan': 1,
      'Turkey': 13,
      'Russia': 8,
      'Singapore': 3,
      'France': 3,
      'United Kingdom': 3,
      'Germany': 3,
      'Netherlands': 3,
      'Belgium': 3,
      'Indonesia': 4,
      'Malaysia': 3,
      'Iran': 7,
    };
    return map[country] ?? 3; // Default: Muslim World League
  }
}
