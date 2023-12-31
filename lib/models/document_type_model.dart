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

  factory DocumentType.fromJson(Map<String, dynamic> json) => DocumentType(
        id: Guid(json[DocumentTypeFields.id] as String),
        erpId: json[DocumentTypeFields.erpId] as String,
        number: json[DocumentTypeFields.number] as int,
        name: json[DocumentTypeFields.name] as String,
        entityType:
            EntityType.values[json[DocumentTypeFields.entityType] as int],
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        DocumentTypeFields.id: id.toString(),
        DocumentTypeFields.erpId: erpId,
        DocumentTypeFields.number: number,
        DocumentTypeFields.name: name,
        DocumentTypeFields.entityType: entityType.index,
      };
}
