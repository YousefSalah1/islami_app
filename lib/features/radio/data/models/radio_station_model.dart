import '../../domain/entities/radio_station_entity.dart';

class RadioStationModel extends RadioStationEntity {
  const RadioStationModel({
    required super.id,
    required super.name,
    required super.url,
  });

  factory RadioStationModel.fromJson(Map<String, dynamic> json) {
    return RadioStationModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
    };
  }
}
