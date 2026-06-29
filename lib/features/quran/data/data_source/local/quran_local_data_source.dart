import '../../models/surah_model.dart';

abstract class QuranLocalDataSource {
  List<SurahModel> getAllSurahs();
  Future<List<String>> getSurahVerses(int index);
}
