import '../entities/hadith_entity.dart';

abstract class GetAhadithUseCase {
  Future<List<HadithEntity>> execute();
}
