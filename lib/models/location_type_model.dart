mixin LocationTypeFields {
  static final List<String> allValues = [
    name,
    isStockLocation,
  ];

  static const String name = 'name';
  static const String isStockLocation = 'isStockLocation';
}

class LocationType {
  String name;
  bool isStockLocation;

  LocationType({
    required this.name,
    required this.isStockLocation,
  });

  factory LocationType.fromJson(Map<String, dynamic> json) => LocationType(
        name: json[LocationTypeFields.name] as String,
        isStockLocation: json[LocationTypeFields.isStockLocation] as bool,
      );
}
