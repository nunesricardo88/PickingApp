import 'package:flutter_guid/flutter_guid.dart';
import 'package:n6picking_flutterapp/models/address_model.dart';
import 'package:n6picking_flutterapp/models/document_line_model.dart';
import 'package:n6picking_flutterapp/models/document_type_model.dart';
import 'package:n6picking_flutterapp/models/entity_model.dart';

mixin DocumentFields {
  static final List<String> allValues = [
    id,
    erpId,
    documentType,
    number,
    name,
    entity,
    address,
    lines,
  ];

  static const String id = 'id';
  static const String erpId = 'erpId';
  static const String documentType = 'documentType';
  static const String number = 'number';
  static const String name = 'name';
  static const String entity = 'entity';
  static const String address = 'address';
  static const String lines = 'lines';
}

class Document {
  Guid id;
  String erpId;
  DocumentType documentType;
  String number;
  String name;
  Entity entity;
  Address address;
  List<DocumentLine> lines;

  Document({
    required this.id,
    required this.erpId,
    required this.documentType,
    required this.number,
    required this.name,
    required this.entity,
    required this.address,
    required this.lines,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
        id: Guid(json[DocumentFields.id] as String),
        erpId: json[DocumentFields.erpId] as String,
        documentType: DocumentType.fromJson(
          json[DocumentFields.documentType] as Map<String, dynamic>,
        ),
        number: json[DocumentFields.number] as String,
        name: json[DocumentFields.name] as String,
        entity: Entity.fromJson(
          json[DocumentFields.entity] as Map<String, dynamic>,
        ),
        address: Address.fromJson(
          json[DocumentFields.address] as Map<String, dynamic>,
        ),
        lines: (json[DocumentFields.lines] as List<dynamic>)
            .map((e) => DocumentLine.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
