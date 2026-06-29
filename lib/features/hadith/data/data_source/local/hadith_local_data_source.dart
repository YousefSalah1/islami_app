import '../../models/hadith_model.dart';

abstract class HadithLocalDataSource {
  Future<List<HadithModel>> loadAllHadith();
}
