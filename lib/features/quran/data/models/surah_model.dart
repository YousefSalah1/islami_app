import '../../domain/entities/surah_entity.dart';

class SurahModel extends SurahEntity {
  const SurahModel({
    required super.index,
    required super.arabicName,
    required super.englishName,
    required super.versesCount,
  });
}
