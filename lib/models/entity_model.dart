import 'dart:convert';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:http/http.dart' as http;
import 'package:n6picking_flutterapp/models/address_model.dart';
import 'package:n6picking_flutterapp/services/api_endpoint.dart';
import 'package:n6picking_flutterapp/services/networking.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';

mixin EntityFields {
  static final List<String> allValues = [
    id,
    erpId,
    entityType,
    number,
    name,
    facility,
    addresses,
  ];

  static const String id = 'id';
  static const String erpId = 'erpId';
  static const String entityType = 'entityType';
  static const String number = 'number';
  static const String name = 'name';
  static const String facility = 'facility';
  static const String addresses = 'addresses';
}

class Entity {
  Guid id;
  String erpId;
  EntityType entityType;
  int number;
  String name;
  int facility;
  List<Address>? addresses;

  Entity({
    required this.id,
    required this.erpId,
    required this.entityType,
    required this.number,
    required this.name,
    required this.facility,
    this.addresses,
  });

  factory Entity.fromJson(Map<String, dynamic> json) => Entity(
        id: Guid(json[EntityFields.id] as String),
        erpId: json[EntityFields.erpId] as String,
        entityType: EntityType.values[json[EntityFields.entityType] as int],
        number: json[EntityFields.number] as int,
        name: json[EntityFields.name] as String,
        facility: json[EntityFields.facility] as int,
        addresses: (json[EntityFields.addresses] as List<dynamic>)
            .map((e) => Address.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        EntityFields.id: id.toString(),
        EntityFields.erpId: erpId,
        EntityFields.entityType: entityType.index,
        EntityFields.number: number,
        EntityFields.name: name,
        EntityFields.facility: facility,
        EntityFields.addresses: addresses!.map((e) => e.toJson()).toList(),
      };
}

mixin EntityApi {
  static Future<List<Entity>> getByType(EntityType entityType) async {
    List<Entity> entitiesList = [];
    final String url = ApiEndPoint.getEntitiesByType(entityType);
    final NetworkHelper networkHelper = NetworkHelper(url);
    final http.Response response =
        await networkHelper.getData(seconds: 10) as http.Response;

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      if (jsonBody['result'] != null) {
        final Iterable l = jsonBody['result'] as Iterable;

        entitiesList = List<Entity>.from(
          l.map((model) => Entity.fromJson(model as Map<String, dynamic>)),
        );
      }
    }

    return entitiesList;
  }

  static Future<Entity?> getSelfEntity() async {
    final String url = ApiEndPoint.getSelfEntity();
    final NetworkHelper networkHelper = NetworkHelper(url);
    final http.Response response =
        await networkHelper.getData(seconds: 10) as http.Response;

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      final Map<String, dynamic> result =
          jsonBody['result'] as Map<String, dynamic>;

      return Entity.fromJson(result);
    }
    return null;
  }
}
