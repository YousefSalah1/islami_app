abstract class TimesRemoteDataSource {
  Future<Map<String, dynamic>> getTimingsByCity({required String city, required String country});
}
