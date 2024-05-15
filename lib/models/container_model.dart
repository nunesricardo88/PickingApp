import 'dart:convert';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:http/http.dart' as http;
import 'package:n6picking_flutterapp/models/location_model.dart';
import 'package:n6picking_flutterapp/services/api_endpoint.dart';
import 'package:n6picking_flutterapp/services/networking.dart';

mixin ContainerFields {
  static final List<String> allValues = [
    id,
    erpId,
    width,
    height,
    depth,
    barcode,
    location,
  ];

  static const String id = 'id';
  static const String erpId = 'erpId';
  static const String width = 'width';
  static const String height = 'height';
  static const String depth = 'depth';
  static const String barcode = 'barcode';
  static const String location = 'location';
}

class Container {
  Guid id;
  String? erpId;
  double width;
  double height;
  double depth;
  String barcode;
  Location location;

  Container({
    required this.id,
    this.erpId,
    this.width = 0,
    this.height = 0,
    this.depth = 0,
    this.barcode = '',
    required this.location,
  });

  factory Container.fromJson(Map<String, dynamic> json) => Container(
        id: Guid(json[ContainerFields.id] as String),
        erpId: json[ContainerFields.erpId] as String,
        width: json[ContainerFields.width] as double,
        height: json[ContainerFields.height] as double,
        depth: json[ContainerFields.depth] as double,
        barcode: json[ContainerFields.barcode] as String,
        location: Location.fromJson(
          json[ContainerFields.location] as Map<String, dynamic>,
        ),
      );

  Map<String, dynamic> toJson() => {
        ContainerFields.id: id.toString(),
        ContainerFields.erpId: erpId,
        ContainerFields.width: width,
        ContainerFields.height: height,
        ContainerFields.depth: depth,
        ContainerFields.barcode: barcode,
        ContainerFields.location: location.toJson(),
      };
}

mixin ContainerApi {
  static Future<Container?> getByBarcode(String barcode) async {
    final String url = ApiEndPoint.getContainerByBarcode(barcode);
    final NetworkHelper networkHelper = NetworkHelper(url);
    final http.Response response =
        await networkHelper.getData(seconds: 10) as http.Response;

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      if (jsonBody['result'] == null) {
        return null;
      }
      final Map<String, dynamic> result =
          jsonBody['result'] as Map<String, dynamic>;

      return Container.fromJson(result);
    } else {
      return null;
    }
  }
}
