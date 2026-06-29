import '../../domain/entities/radio_station_entity.dart';
import '../../domain/repository/radio_repository.dart';
import '../data_source/remote/radio_remote_data_source.dart';

class RadioRepositoryImpl implements RadioRepository {
  final RadioRemoteDataSource _dataSource;

  RadioRepositoryImpl(this._dataSource);

  @override
  Future<List<RadioStationEntity>> getRadioStations() {
    return _dataSource.getRadioStations();
  }
}
