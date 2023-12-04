import 'package:flutter_guid/flutter_guid.dart';
import 'package:n6picking_flutterapp/models/address_model.dart';

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
  String entityType;
  String number;
  String name;
  String facility;
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
        entityType: json[EntityFields.entityType] as String,
        number: json[EntityFields.number] as String,
        name: json[EntityFields.name] as String,
        facility: json[EntityFields.facility] as String,
        addresses: (json[EntityFields.addresses] as List<dynamic>)
            .map((e) => Address.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
