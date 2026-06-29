import '../entities/radio_station_entity.dart';
import '../repository/radio_repository.dart';
import 'get_radio_stations_usecase.dart';

class GetRadioStationsUseCaseImpl implements GetRadioStationsUseCase {
  final RadioRepository _repository;

  GetRadioStationsUseCaseImpl(this._repository);

  @override
  Future<List<RadioStationEntity>> execute() {
    return _repository.getRadioStations();
  }
}
