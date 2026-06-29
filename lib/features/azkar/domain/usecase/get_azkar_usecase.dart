import '../entities/zikr_entity.dart';
import '../repository/azkar_repository.dart';

abstract class GetAzkarUseCase {
  Future<Map<String, List<ZikrEntity>>> execute();
}

class GetAzkarUseCaseImpl implements GetAzkarUseCase {
  final AzkarRepository _repository;

  GetAzkarUseCaseImpl(this._repository);

  @override
  Future<Map<String, List<ZikrEntity>>> execute() {
    return _repository.loadAzkar();
  }
}
