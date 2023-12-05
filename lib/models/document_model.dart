import 'dart:convert';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:http/http.dart' as http;
import 'package:n6picking_flutterapp/models/address_model.dart';
import 'package:n6picking_flutterapp/models/document_line_model.dart';
import 'package:n6picking_flutterapp/models/document_type_model.dart';
import 'package:n6picking_flutterapp/models/entity_model.dart';
import 'package:n6picking_flutterapp/services/api_endpoint.dart';
import 'package:n6picking_flutterapp/services/networking.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';

mixin DocumentFields {
  static final List<String> allValues = [
    id,
    erpId,
    documentType,
    number,
    entity,
    address,
    lines,
  ];

  static const String id = 'id';
  static const String erpId = 'erpId';
  static const String documentType = 'documentType';
  static const String number = 'number';
  static const String entity = 'entity';
  static const String address = 'address';
  static const String lines = 'lines';
}

class Document {
  Guid id;
  String? erpId;
  DocumentType documentType;
  int? number;
  Entity? entity;
  Address? address;
  List<DocumentLine> lines = [];

  Document({
    required this.id,
    this.erpId,
    required this.documentType,
    this.number,
    this.entity,
    this.address,
    required this.lines,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
        id: Guid(json[DocumentFields.id] as String),
        erpId: json[DocumentFields.erpId] as String,
        documentType: DocumentType.fromJson(
          json[DocumentFields.documentType] as Map<String, dynamic>,
        ),
        number: json[DocumentFields.number] as int?,
        entity: Entity.fromJson(
          json[DocumentFields.entity] as Map<String, dynamic>,
        ),
        address: json[DocumentFields.address] == null
            ? null
            : Address.fromJson(
                json[DocumentFields.address] as Map<String, dynamic>,
              ),
        lines: (json[DocumentFields.lines] as List<dynamic>)
            .map((e) => DocumentLine.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

mixin DocumentApi {
  static Future<List<Document>> getPendingDocuments(
    PickingTaskType pickingTaskType,
    EntityType? entityType,
    Entity? entity,
  ) async {
    List<Document> documentsList = [];
    final String url =
        ApiEndPoint.getPendingDocuments(pickingTaskType, entityType, entity);
    final NetworkHelper networkHelper = NetworkHelper(url);
    final http.Response response =
        await networkHelper.getData(seconds: 10) as http.Response;

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      final Iterable l = jsonBody['result'] as Iterable;

      documentsList = List<Document>.from(
        l.map((model) => Document.fromJson(model as Map<String, dynamic>)),
      );
    }

    return documentsList;
  }
}
