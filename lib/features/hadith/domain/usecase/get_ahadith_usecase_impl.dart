import '../entities/hadith_entity.dart';
import '../repository/hadith_repository.dart';
import 'get_ahadith_usecase.dart';

class GetAhadithUseCaseImpl implements GetAhadithUseCase {
  final HadithRepository _repository;

  GetAhadithUseCaseImpl(this._repository);

  @override
  Future<List<HadithEntity>> execute() {
    return _repository.getAllHadith();
  }
}
