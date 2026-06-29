import '../entities/radio_station_entity.dart';

abstract class GetRadioStationsUseCase {
  Future<List<RadioStationEntity>> execute();
}
