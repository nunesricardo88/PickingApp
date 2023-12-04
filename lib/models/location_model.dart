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

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        id: Guid(json[LocationFields.id] as String),
        erpId: json[LocationFields.erpId] as String,
        locationType: LocationType.fromJson(
          json[LocationFields.locationType] as Map<String, dynamic>,
        ),
        name: json[LocationFields.name] as String,
        barcode: json[LocationFields.barcode] as String,
        locations: (json[LocationFields.locations] as List<dynamic>)
            .map((e) => Location.fromJson(e as Map<String, dynamic>))
            .toList(),
        stocks: (json[LocationFields.stocks] as List<dynamic>)
            .map((e) => Stock.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
