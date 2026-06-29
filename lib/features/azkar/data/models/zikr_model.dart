import '../../domain/entities/zikr_entity.dart';

class ZikrModel extends ZikrEntity {
  const ZikrModel({
    required super.category,
    required super.count,
    required super.description,
    required super.reference,
    required super.content,
  });

  factory ZikrModel.fromJson(Map<String, dynamic> json) {
    return ZikrModel(
      category: json['category'] ?? '',
      count: json['count'] ?? '0',
      description: json['description'] ?? '',
      reference: json['reference'] ?? '',
      content: json['content'] ?? '',
    );
  }
}
