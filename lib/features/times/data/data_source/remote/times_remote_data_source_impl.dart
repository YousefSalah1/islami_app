import 'package:dio/dio.dart';
import 'times_remote_data_source.dart';

/// Dio-based service for AlAdhan Prayer Times API.
/// Only supports city-based lookups (no GPS / coordinates).
class TimesRemoteDataSourceImpl implements TimesRemoteDataSource {
  late final Dio _dio;

  static const String _baseUrl = 'https://api.aladhan.com/v1/';

  /// Default calculation method: 3 = Muslim World League (reliable worldwide)
  static const int defaultMethod = 3;

  TimesRemoteDataSourceImpl() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
  }

  /// Fetch prayer timings by city and country name.
  @override
  Future<Map<String, dynamic>> getTimingsByCity({
    required String city,
    required String country,
    int method = defaultMethod,
  }) async {
    final now = DateTime.now();
    final date =
        '${now.day.toString().padLeft(2, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.year}';

    final response = await _dio.get(
      'timingsByCity/$date',
      queryParameters: {'city': city, 'country': country, 'method': method},
    );

    final data = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : Map<String, dynamic>.from(response.data as Map);

    if (data['code'] != 200) {
      throw Exception('API error: ${data['status']}');
    }
    return data;
  }
}
