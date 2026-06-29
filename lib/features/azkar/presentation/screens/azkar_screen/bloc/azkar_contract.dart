import '../../../../domain/entities/zikr_entity.dart';

class AzkarState {
  final bool isLoading;
  final Map<String, List<ZikrEntity>> allAzkar;
  final List<String> categories;
  final int selectedCategoryIndex;
  final int currentZikrIndex;
  final int tapCount;

  AzkarState({
    this.isLoading = false,
    this.allAzkar = const {},
    this.categories = const [],
    this.selectedCategoryIndex = 0,
    this.currentZikrIndex = 0,
    this.tapCount = 0,
  });

  AzkarState copyWith({
    bool? isLoading,
    Map<String, List<ZikrEntity>>? allAzkar,
    List<String>? categories,
    int? selectedCategoryIndex,
    int? currentZikrIndex,
    int? tapCount,
  }) {
    return AzkarState(
      isLoading: isLoading ?? this.isLoading,
      allAzkar: allAzkar ?? this.allAzkar,
      categories: categories ?? this.categories,
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
      currentZikrIndex: currentZikrIndex ?? this.currentZikrIndex,
      tapCount: tapCount ?? this.tapCount,
    );
  }

  List<ZikrEntity> get currentCategoryZikr {
    if (categories.isEmpty) return [];
    return allAzkar[categories[selectedCategoryIndex]] ?? [];
  }

  ZikrEntity? get currentZikr {
    final list = currentCategoryZikr;
    if (list.isEmpty || currentZikrIndex >= list.length) return null;
    return list[currentZikrIndex];
  }

  int get targetCount {
    final raw = int.tryParse(currentZikr?.count ?? '1') ?? 1;
    return raw <= 0 ? 1 : raw;
  }
}

abstract class AzkarEvent {}

class LoadAzkarEvent extends AzkarEvent {}

class SelectCategoryEvent extends AzkarEvent {
  final int index;
  SelectCategoryEvent(this.index);
}

class TapZikrEvent extends AzkarEvent {}

class NextZikrEvent extends AzkarEvent {}

class ResetZikrEvent extends AzkarEvent {}
