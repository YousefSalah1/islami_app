import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/radio_station_model.dart';
import 'radio_remote_data_source.dart';

class RadioRemoteDataSourceImpl implements RadioRemoteDataSource {
  @override
  Future<List<RadioStationModel>> getRadioStations() async {
    final response = await http
        .get(Uri.parse('https://mp3quran.net/api/v3/radios?language=ar'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['radios'] ?? [];
      return list.map((r) => RadioStationModel.fromJson(r)).toList();
    } else {
      throw Exception('Failed to load stations');
    }
  }
}
