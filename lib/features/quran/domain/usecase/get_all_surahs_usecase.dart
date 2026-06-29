import '../entities/surah_entity.dart';
import '../repository/quran_repository.dart';

abstract class GetAllSurahsUseCase {
  List<SurahEntity> execute();
}

class GetAllSurahsUseCaseImpl implements GetAllSurahsUseCase {
  final QuranRepository _repository;

  GetAllSurahsUseCaseImpl(this._repository);

  @override
  List<SurahEntity> execute() {
    return _repository.getAllSurahs();
  }
}
