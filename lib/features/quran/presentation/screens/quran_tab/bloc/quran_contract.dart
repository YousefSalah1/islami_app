import '../../../../domain/entities/surah_entity.dart';

class QuranState {
  final bool isLoading;
  final List<SurahEntity> allSurahs;
  final SurahEntity? lastReadSurah;

  QuranState({
    this.isLoading = false,
    this.allSurahs = const [],
    this.lastReadSurah,
  });

  QuranState copyWith({
    bool? isLoading,
    List<SurahEntity>? allSurahs,
    SurahEntity? lastReadSurah,
  }) {
    return QuranState(
      isLoading: isLoading ?? this.isLoading,
      allSurahs: allSurahs ?? this.allSurahs,
      lastReadSurah: lastReadSurah, // intentional replace or null
    );
  }
}

abstract class QuranEvent {}

class LoadQuranEvent extends QuranEvent {}

class SaveLastReadSurahEvent extends QuranEvent {
  final int index;
  SaveLastReadSurahEvent(this.index);
}
