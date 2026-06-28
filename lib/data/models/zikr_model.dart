class ZikrModel {
  final String category;
  final String count;
  final String description;
  final String reference;
  final String content;

  ZikrModel({
    required this.category,
    required this.count,
    required this.description,
    required this.reference,
    required this.content,
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
