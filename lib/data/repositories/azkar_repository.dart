import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/zikr_model.dart';

class AzkarRepository {
  Future<Map<String, List<ZikrModel>>> loadAzkar() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/azkar.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      
      Map<String, List<ZikrModel>> categories = {};
      
      jsonData.forEach((key, value) {
        if (value is List) {
          List<ZikrModel> zikrList = [];
          for (var item in value) {
            if (item is Map<String, dynamic>) {
              // Filter out the "stop" sentinel
              if (item['category'] != 'stop') {
                zikrList.add(ZikrModel.fromJson(item));
              }
            }
          }
          if (zikrList.isNotEmpty) {
            categories[key] = zikrList;
          }
        }
      });
      return categories;
    } catch (e) {
      return {};
    }
  }
}
