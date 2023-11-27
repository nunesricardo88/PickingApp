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
