import 'package:flutter/material.dart';
import '../../../data/models/zikr_model.dart';
import '../../../data/repositories/azkar_repository.dart';

class SebhaProvider extends ChangeNotifier {
  final AzkarRepository _repository = AzkarRepository();

  Map<String, List<ZikrModel>> allAzkar = {};
  List<String> categories = [];
  int selectedCategoryIndex = 0;
  int currentZikrIndex = 0;
  int tapCount = 0;
  bool isLoading = true;

  SebhaProvider() {
    _load();
  }

  Future<void> _load() async {
    allAzkar = await _repository.loadAzkar();
    categories = allAzkar.keys.toList();
    isLoading = false;
    notifyListeners();
  }

  List<ZikrModel> get currentCategoryZikr {
    if (categories.isEmpty) return [];
    return allAzkar[categories[selectedCategoryIndex]] ?? [];
  }

  ZikrModel? get currentZikr {
    final list = currentCategoryZikr;
    if (list.isEmpty || currentZikrIndex >= list.length) return null;
    return list[currentZikrIndex];
  }

  int get targetCount {
    final raw = int.tryParse(currentZikr?.count ?? '1') ?? 1;
    return raw <= 0 ? 1 : raw;
  }

  void tap() {
    if (tapCount < targetCount) {
      tapCount++;
      notifyListeners();
      if (tapCount >= targetCount) {
        Future.delayed(const Duration(milliseconds: 600), nextZikr);
      }
    }
  }

  void nextZikr() {
    final list = currentCategoryZikr;
    currentZikrIndex = (currentZikrIndex + 1) % list.length;
    tapCount = 0;
    notifyListeners();
  }

  void reset() {
    tapCount = 0;
    notifyListeners();
  }

  void selectCategory(int index) {
    selectedCategoryIndex = index;
    currentZikrIndex = 0;
    tapCount = 0;
    notifyListeners();
  }
}
