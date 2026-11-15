class Plot {
  final int id;
  final String name;
  final double areaHa;

  const Plot({required this.id, required this.name, required this.areaHa});

  factory Plot.fromJson(Map<String, dynamic> json) {
    return Plot(
      id: json['id'],
      name: json['name'],
      areaHa: double.parse(json['area_ha'].toString()),
    );
  }
}
