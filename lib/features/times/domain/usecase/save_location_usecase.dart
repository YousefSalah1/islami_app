import '../repository/times_repository.dart';

abstract class SaveLocationUseCase {
  Future<void> execute({required String country, required String city});
}

class SaveLocationUseCaseImpl implements SaveLocationUseCase {
  final TimesRepository _repository;

  SaveLocationUseCaseImpl(this._repository);

  @override
  Future<void> execute({required String country, required String city}) {
    return _repository.saveLocation(country: country, city: city);
  }
}
