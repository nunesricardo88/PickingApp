import 'dart:convert';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:http/http.dart' as http;
import 'package:n6picking_flutterapp/models/location_type_model.dart';
import 'package:n6picking_flutterapp/models/stock_model.dart';
import 'package:n6picking_flutterapp/services/api_endpoint.dart';
import 'package:n6picking_flutterapp/services/networking.dart';

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

  Map<String, dynamic> toJson() => <String, dynamic>{
        LocationFields.id: id.toString(),
        LocationFields.erpId: erpId,
        LocationFields.locationType: locationType.toJson(),
        LocationFields.name: name,
        LocationFields.barcode: barcode,
        LocationFields.locations:
            List<dynamic>.from(locations.map((e) => e.toJson())),
        LocationFields.stocks:
            List<dynamic>.from(stocks.map((e) => e.toJson())),
      };
}

class LocationApi {
  List<Location> allLocations = [];

  static LocationApi instance = LocationApi._init();

  LocationApi._init() {
    initialize();
  }

  Future<void> initialize() async {
    allLocations = await syncAllLocations();
  }

  Future<List<Location>> syncAllLocations() async {
    return fetchFromApi();
  }

  static Future<List<Location>> fetchFromApi() async {
    List<Location> locationList = [];
    final String getUrl = ApiEndPoint.getAllLocations();

    final NetworkHelper networkHelper = NetworkHelper(getUrl);
    final http.Response response =
        await networkHelper.getData(seconds: 60) as http.Response;

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      final Iterable l = jsonBody['result'] as Iterable;

      locationList = List<Location>.from(
        l.map((model) => Location.fromJson(model as Map<String, dynamic>)),
      );
    }
    return locationList;
  }

  static Location? getByErpId(String erpId, List<Location> locations) {
    Location? location;
    for (final Location child in locations) {
      if (location != null) {
        break;
      }
      if (child.erpId.trim() == erpId.trim()) {
        location = child;
      } else if (child.locations.isNotEmpty) {
        location = getByErpId(erpId, child.locations);
      }
    }
    return location;
  }

  static Future<List<Location>> getByParentErpId(String parentErpId) async {
    return instance.allLocations
        .where(
          (element) => element.erpId == parentErpId,
        )
        .toList();
  }
}
