import 'package:flutter_guid/flutter_guid.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';

mixin DocumentTypeFields {
  static final List<String> allValues = [
    id,
    erpId,
    number,
    name,
    entityType,
  ];

  static const String id = 'id';
  static const String erpId = 'erpId';
  static const String number = 'number';
  static const String name = 'name';
  static const String entityType = 'entityType';
}

class DocumentType {
  Guid id;
  String erpId;
  int number;
  String name;
  EntityType entityType;

  DocumentType({
    required this.id,
    required this.erpId,
    required this.number,
    required this.name,
    required this.entityType,
  });
}
