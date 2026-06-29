import '../../models/zikr_model.dart';

abstract class AzkarLocalDataSource {
  Future<Map<String, List<ZikrModel>>> loadAzkar();
}
