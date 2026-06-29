import '../entities/radio_station_entity.dart';

abstract class RadioRepository {
  Future<List<RadioStationEntity>> getRadioStations();
}
