import 'package:flutter/services.dart';
import '../models/hadith_model.dart';

class HadithRepository {
  Future<List<HadithModel>> loadAllHadith() async {
    List<Future<HadithModel?>> tasks = [];
    
    for (int i = 1; i <= 50; i++) {
      tasks.add(_loadSingleHadith(i));
    }
    
    // Load all in parallel instead of sequentially
    final results = await Future.wait(tasks);
    
    // Filter out nulls and return
    return results.where((element) => element != null).cast<HadithModel>().toList();
  }

  Future<HadithModel?> _loadSingleHadith(int index) async {
    try {
      String data = await rootBundle.loadString('assets/hadeth/h$index.txt');
      List<String> lines = data.trim().split('\n');
      if (lines.isNotEmpty) {
        String title = lines.first.trim();
        String content = lines.skip(1).join('\n').trim();
        return HadithModel(title: title, content: content);
      }
    } catch (_) {
      // Return null on failure, we'll filter it out
    }
    return null;
  }
}
