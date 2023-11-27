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

  static const String id = 'Id';
  static const String erpId = 'ErpId';
  static const String number = 'Number';
  static const String name = 'Name';
  static const String entityType = 'EntityType';
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
