import '../../domain/entities/hadith_entity.dart';
import '../../domain/repository/hadith_repository.dart';
import '../data_source/local/hadith_local_data_source.dart';

class HadithRepositoryImpl implements HadithRepository {
  final HadithLocalDataSource _dataSource;

  HadithRepositoryImpl(this._dataSource);

  @override
  Future<List<HadithEntity>> getAllHadith() {
    return _dataSource.loadAllHadith();
  }
}
