mixin LocationTypeFields {
  static final List<String> allValues = [
    name,
    isStockLocation,
  ];

  static const String name = 'Name';
  static const String isStockLocation = 'IsStockLocation';
}

class LocationType {
  String name;
  bool isStockLocation;

  LocationType({
    required this.name,
    required this.isStockLocation,
  });
}
