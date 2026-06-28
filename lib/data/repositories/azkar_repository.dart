import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/zikr_model.dart';

class AzkarRepository {
  Future<Map<String, List<ZikrModel>>> loadAzkar() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/azkar.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      final Map<String, List<ZikrModel>> categories = {};

      jsonData.forEach((key, value) {
        if (value is! List) return;

        final List<ZikrModel> zikrList = [];

        for (final item in value) {
          if (item is List) {
            // Handle nested arrays (e.g., first element of أذكار الصباح)
            for (final subItem in item) {
              final zikr = _parseItem(subItem);
              if (zikr != null) zikrList.add(zikr);
            }
          } else {
            final zikr = _parseItem(item);
            if (zikr != null) zikrList.add(zikr);
          }
        }

        if (zikrList.isNotEmpty) {
          categories[key] = zikrList;
        }
      });

      return categories;
    } catch (_) {
      return {};
    }
  }

  ZikrModel? _parseItem(dynamic item) {
    if (item is! Map<String, dynamic>) return null;
    final content = item['content'] as String? ?? '';
    final category = item['category'] as String? ?? '';
    // Filter out the "stop" sentinel entries
    if (content == 'stop' || category == 'stop' || content.isEmpty) {
      return null;
    }
    return ZikrModel.fromJson(item);
  }
}
