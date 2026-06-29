import '../../models/radio_station_model.dart';

abstract class RadioRemoteDataSource {
  Future<List<RadioStationModel>> getRadioStations();
}
