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

  static const String id = 'Id';
  static const String erpId = 'ErpId';
  static const String entityType = 'EntityType';
  static const String number = 'Number';
  static const String name = 'Name';
  static const String facility = 'Facility';
  static const String addresses = 'Addresses';
}

class Entity {
  Guid id;
  String erpId;
  String entityType;
  String number;
  String name;
  String facility;
  List<Address> addresses;

  Entity({
    required this.id,
    required this.erpId,
    required this.entityType,
    required this.number,
    required this.name,
    required this.facility,
    required this.addresses,
  });
}
