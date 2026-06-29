import '../repository/times_repository.dart';

abstract class GetSavedLocationUseCase {
  Future<Map<String, String?>> execute();
}

class GetSavedLocationUseCaseImpl implements GetSavedLocationUseCase {
  final TimesRepository _repository;

  GetSavedLocationUseCaseImpl(this._repository);

  @override
  Future<Map<String, String?>> execute() {
    return _repository.getSavedLocation();
  }
}
