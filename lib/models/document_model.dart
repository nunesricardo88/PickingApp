import 'dart:convert';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:http/http.dart' as http;
import 'package:n6picking_flutterapp/models/address_model.dart';
import 'package:n6picking_flutterapp/models/document_line_model.dart';
import 'package:n6picking_flutterapp/models/document_type_model.dart';
import 'package:n6picking_flutterapp/models/entity_model.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';
import 'package:n6picking_flutterapp/services/api_endpoint.dart';
import 'package:n6picking_flutterapp/services/networking.dart';

mixin DocumentFields {
  static final List<String> allValues = [
    id,
    erpId,
    documentType,
    number,
    name,
    entity,
    loadingAddress,
    unloadingAddress,
    lines,
  ];

  static const String id = 'id';
  static const String erpId = 'erpId';
  static const String documentType = 'documentType';
  static const String number = 'number';
  static const String name = 'name';
  static const String entity = 'entity';
  static const String loadingAddress = 'loadingAddress';
  static const String unloadingAddress = 'unloadingAddress';
  static const String lines = 'lines';
}

class Document {
  Guid id;
  String? erpId;
  DocumentType documentType;
  int? number;
  String? name;
  Entity? entity;
  Address? loadingAddress;
  Address? unloadingAddress;
  List<DocumentLine> lines = [];

  Document({
    required this.id,
    this.erpId,
    required this.documentType,
    this.number,
    this.name,
    this.entity,
    this.loadingAddress,
    this.unloadingAddress,
    required this.lines,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
        id: Guid(json[DocumentFields.id] as String),
        erpId: json[DocumentFields.erpId] as String,
        documentType: DocumentType.fromJson(
          json[DocumentFields.documentType] as Map<String, dynamic>,
        ),
        number: json[DocumentFields.number] as int?,
        name: json[DocumentFields.name] as String?,
        entity: Entity.fromJson(
          json[DocumentFields.entity] as Map<String, dynamic>,
        ),
        loadingAddress: json[DocumentFields.loadingAddress] == null
            ? null
            : Address.fromJson(
                json[DocumentFields.loadingAddress] as Map<String, dynamic>,
              ),
        unloadingAddress: json[DocumentFields.unloadingAddress] == null
            ? null
            : Address.fromJson(
                json[DocumentFields.unloadingAddress] as Map<String, dynamic>,
              ),
        lines: json[DocumentFields.lines] == null
            ? []
            : List<DocumentLine>.from(
                (json[DocumentFields.lines] as List<dynamic>).map(
                  (model) => DocumentLine.fromJson(
                    model as Map<String, dynamic>,
                  ),
                ),
              ),
      );

  Map<String, dynamic> toJson() => {
        DocumentFields.id: id.toString(),
        DocumentFields.erpId: erpId,
        DocumentFields.documentType: documentType.toJson(),
        DocumentFields.number: number,
        DocumentFields.name: name,
        DocumentFields.entity: entity?.toJson(),
        DocumentFields.loadingAddress: loadingAddress?.toJson(),
        DocumentFields.unloadingAddress: unloadingAddress?.toJson(),
        DocumentFields.lines: List<dynamic>.from(lines.map((model) => model)),
      };
}

mixin DocumentApi {
  static Future<List<Document>> getPendingDocuments(PickingTask task) async {
    List<Document> documentsList = [];
    final String url = ApiEndPoint.getPendingDocuments(task);
    final NetworkHelper networkHelper = NetworkHelper(url);
    final http.Response response =
        await networkHelper.getData(seconds: 10) as http.Response;

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      if (jsonBody['result'] != null) {
        final Iterable l = jsonBody['result'] as Iterable;

        documentsList = List<Document>.from(
          l.map((model) => Document.fromJson(model as Map<String, dynamic>)),
        );
      }
    }

    return documentsList;
  }

  static Future<Document?> getPendingFromBarcode(
    PickingTask task,
    String barcode,
  ) async {
    Document? document;
    final String url = ApiEndPoint.getPendingDocumentByBarcode(task, barcode);
    final NetworkHelper networkHelper = NetworkHelper(url);
    final http.Response response =
        await networkHelper.getData(seconds: 10) as http.Response;

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      if (jsonBody['result'] != null) {
        document =
            Document.fromJson(jsonBody['result'] as Map<String, dynamic>);
      }
    }

    return document;
  }
}
