import '../entities/surah_entity.dart';

abstract class QuranRepository {
  List<SurahEntity> getAllSurahs();
  Future<List<String>> getSurahVerses(int index);
}
