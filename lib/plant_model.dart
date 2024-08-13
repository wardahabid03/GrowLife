class Plant {
  final int id; // Add this line
  final String commonName;
  final List<String> scientificName;
  final String? type;
  final String cycle;
  final String watering;
  final String wateringPeriod;
  final List<String> sunlight;
  final List<String> propagation;
  final List<String> pruningMonth;
  final int seeds;
  final bool flowers;
  final String? floweringSeason;
  final bool edibleFruit;
  final String? imageUrl;

  Plant({
    required this.id, // Add this line
    required this.commonName,
    required this.scientificName,
    this.type,
    required this.cycle,
    required this.watering,
    required this.wateringPeriod,
    required this.sunlight,
    required this.propagation,
    required this.pruningMonth,
    required this.seeds,
    required this.flowers,
    this.floweringSeason,
    required this.edibleFruit,
    this.imageUrl,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'] ?? 0, // Add this line
      commonName: json['common_name'] ?? '',
      scientificName: List<String>.from(json['scientific_name'] ?? []),
      type: json['type'],
      cycle: json['cycle'] ?? '',
      watering: json['watering'] ?? '',
      wateringPeriod: json['watering_period'] ?? '',
      sunlight: List<String>.from(json['sunlight'] ?? []),
      propagation: List<String>.from(json['propagation'] ?? []),
      pruningMonth: List<String>.from(json['pruning_month'] ?? []),
      seeds: json['seeds'] ?? 0,
      flowers: json['flowers'] ?? false,
      floweringSeason: json['flowering_season'],
      edibleFruit: json['edible_fruit'] ?? false,
       imageUrl: json['default_image'] != null ? json['default_image']['regular_url'] : null,
    );
  }
}
