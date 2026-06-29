import '../entities/hadith_entity.dart';

abstract class HadithRepository {
  Future<List<HadithEntity>> getAllHadith();
}
