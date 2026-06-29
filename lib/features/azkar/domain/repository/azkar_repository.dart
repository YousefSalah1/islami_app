import '../entities/zikr_entity.dart';

abstract class AzkarRepository {
  Future<Map<String, List<ZikrEntity>>> loadAzkar();
}
