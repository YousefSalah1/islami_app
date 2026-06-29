import '../../domain/entities/zikr_entity.dart';
import '../../domain/repository/azkar_repository.dart';
import '../data_source/local/azkar_local_data_source.dart';

class AzkarRepositoryImpl implements AzkarRepository {
  final AzkarLocalDataSource _dataSource;

  AzkarRepositoryImpl(this._dataSource);

  @override
  Future<Map<String, List<ZikrEntity>>> loadAzkar() async {
    return _dataSource.loadAzkar();
  }
}
