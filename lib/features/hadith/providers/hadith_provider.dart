import 'package:flutter/material.dart';
import '../../../data/models/hadith_model.dart';
import '../../../data/repositories/hadith_repository.dart';

class HadithProvider extends ChangeNotifier {
  final HadithRepository _repository = HadithRepository();

  List<HadithModel> ahadith = [];
  bool isLoading = true;
  String? errorMessage;

  HadithProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      isLoading = true;
      notifyListeners();
      ahadith = await _repository.loadAllHadith();
    } catch (_) {
      errorMessage = 'Failed to load Hadith';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
