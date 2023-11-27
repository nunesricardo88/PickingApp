import 'package:flutter_guid/flutter_guid.dart';
import 'package:n6picking_flutterapp/models/location_type_model.dart';
import 'package:n6picking_flutterapp/models/stock_model.dart';

mixin LocationFields {
  static final List<String> allValues = [
    id,
    erpId,
    locationType,
    name,
    barcode,
    locations,
    stocks,
  ];

  static const String id = 'id';
  static const String erpId = 'erpId';
  static const String locationType = 'locationType';
  static const String name = 'name';
  static const String barcode = 'barcode';
  static const String locations = 'locations';
  static const String stocks = 'stocks';
}

class Location {
  Guid id;
  String erpId;
  LocationType locationType;
  String name;
  String barcode;
  List<Location> locations;
  List<Stock> stocks;

  Location({
    required this.id,
    required this.erpId,
    required this.locationType,
    required this.name,
    required this.barcode,
    required this.locations,
    required this.stocks,
  });
}
