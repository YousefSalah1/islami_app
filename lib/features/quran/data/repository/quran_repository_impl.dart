import '../../domain/entities/surah_entity.dart';
import '../../domain/repository/quran_repository.dart';
import '../data_source/local/quran_local_data_source.dart';

class QuranRepositoryImpl implements QuranRepository {
  final QuranLocalDataSource _dataSource;

  QuranRepositoryImpl(this._dataSource);

  @override
  List<SurahEntity> getAllSurahs() {
    return _dataSource.getAllSurahs();
  }

  @override
  Future<List<String>> getSurahVerses(int index) {
    return _dataSource.getSurahVerses(index);
  }
}
