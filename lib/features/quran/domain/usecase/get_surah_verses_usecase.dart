import '../repository/quran_repository.dart';

abstract class GetSurahVersesUseCase {
  Future<List<String>> execute(int index);
}

class GetSurahVersesUseCaseImpl implements GetSurahVersesUseCase {
  final QuranRepository _repository;

  GetSurahVersesUseCaseImpl(this._repository);

  @override
  Future<List<String>> execute(int index) {
    return _repository.getSurahVerses(index);
  }
}
