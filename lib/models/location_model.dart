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

  static const String id = 'Id';
  static const String erpId = 'ErpId';
  static const String locationType = 'LocationType';
  static const String name = 'Name';
  static const String barcode = 'Barcode';
  static const String locations = 'Locations';
  static const String stocks = 'Stocks';
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
