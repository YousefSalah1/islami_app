class RadioStationModel {
  final int id;
  final String name;
  final String url;

  RadioStationModel({
    required this.id,
    required this.name,
    required this.url,
  });

  factory RadioStationModel.fromJson(Map<String, dynamic> json) {
    return RadioStationModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
