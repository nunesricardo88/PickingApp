import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:http/http.dart' as http;
import 'package:n6picking_flutterapp/models/address_model.dart';
import 'package:n6picking_flutterapp/models/document_line_model.dart';
import 'package:n6picking_flutterapp/models/document_model.dart';
import 'package:n6picking_flutterapp/models/document_type_model.dart';
import 'package:n6picking_flutterapp/models/entity_model.dart';
import 'package:n6picking_flutterapp/services/api_endpoint.dart';
import 'package:n6picking_flutterapp/services/networking.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:n6picking_flutterapp/utilities/helper.dart';
import 'package:n6picking_flutterapp/utilities/system.dart';
import 'package:n6picking_flutterapp/utilities/task_operation.dart';

mixin PickingTaskFields {
  static final List<String> allValues = [
    id,
    erpId,
    accessId,
    userErpId,
    group,
    name,
    description,
    stockMovement,
    document,
    originDocumentType,
    destinationDocumentType,
    customOptions,
  ];

  static const String id = 'id';
  static const String erpId = 'erpId';
  static const String accessId = 'accessId';
  static const String userErpId = 'userErpId';
  static const String group = 'group';
  static const String name = 'name';
  static const String description = 'description';
  static const String stockMovement = 'stockMovement';
  static const String document = 'document';
  static const String originDocumentType = 'originDocumentType';
  static const String destinationDocumentType = 'destinationDocumentType';
  static const String customOptions = 'customOptions';
}

class PickingTask extends ChangeNotifier {
  Guid id;
  String erpId;
  int accessId;
  String? userErpId;
  String group;
  String name;
  String description;
  StockMovement stockMovement;
  Document? document;
  DocumentType? originDocumentType;
  DocumentType destinationDocumentType;
  String customOptions;
  List<Document> sourceDocuments;

  PickingTask({
    required this.id,
    required this.erpId,
    required this.accessId,
    this.userErpId,
    required this.group,
    required this.name,
    required this.description,
    required this.stockMovement,
    this.document,
    this.originDocumentType,
    required this.destinationDocumentType,
    required this.customOptions,
    this.sourceDocuments = const [],
  });

  factory PickingTask.fromJson(Map<String, dynamic> json) => PickingTask(
        id: Guid(json[PickingTaskFields.id] as String),
        erpId: json[PickingTaskFields.erpId] as String,
        accessId: json[PickingTaskFields.accessId] as int,
        userErpId: json[PickingTaskFields.userErpId] as String?,
        group: json[PickingTaskFields.group] as String,
        name: json[PickingTaskFields.name] as String,
        description: json[PickingTaskFields.description] as String,
        stockMovement:
            StockMovement.values[json[PickingTaskFields.stockMovement] as int],
        document: json[PickingTaskFields.document] == null
            ? null
            : Document.fromJson(
                json[PickingTaskFields.document] as Map<String, dynamic>,
              ),
        originDocumentType: json[PickingTaskFields.originDocumentType] == null
            ? null
            : DocumentType.fromJson(
                json[PickingTaskFields.originDocumentType]
                    as Map<String, dynamic>,
              ),
        destinationDocumentType: DocumentType.fromJson(
          json[PickingTaskFields.destinationDocumentType]
              as Map<String, dynamic>,
        ),
        customOptions: json[PickingTaskFields.customOptions] as String,
        sourceDocuments: [],
      );

  PickingTask copy({
    Guid? id,
    String? erpId,
    int? accessId,
    String? userErpId,
    String? group,
    String? name,
    String? description,
    StockMovement? stockMovement,
    Document? document,
    DocumentType? originDocumentType,
    DocumentType? destinationDocumentType,
    String? customOptions,
    List<Document>? sourceDocuments,
  }) =>
      PickingTask(
        id: id ?? this.id,
        erpId: erpId ?? this.erpId,
        accessId: accessId ?? this.accessId,
        userErpId: userErpId ?? this.userErpId,
        group: group ?? this.group,
        name: name ?? this.name,
        description: description ?? this.description,
        stockMovement: stockMovement ?? this.stockMovement,
        document: document ?? this.document,
        originDocumentType: originDocumentType ?? this.originDocumentType,
        destinationDocumentType:
            destinationDocumentType ?? this.destinationDocumentType,
        customOptions: customOptions ?? this.customOptions,
        sourceDocuments: sourceDocuments ?? this.sourceDocuments,
      );

  //PickingTask
  void update(PickingTask pickingTask) {
    id = pickingTask.id;
    erpId = pickingTask.erpId;
    accessId = pickingTask.accessId;
    userErpId = pickingTask.userErpId;
    group = pickingTask.group;
    name = pickingTask.name;
    description = pickingTask.description;
    stockMovement = pickingTask.stockMovement;
    document = pickingTask.document;
    originDocumentType = pickingTask.originDocumentType;
    destinationDocumentType = pickingTask.destinationDocumentType;
    customOptions = pickingTask.customOptions;
    sourceDocuments = pickingTask.sourceDocuments;

    if (document == null) {
      setNewDocument();
    }

    notifyListeners();
  }

  //Document
  void setNewDocument() {
    document = Document(
      id: Guid.newGuid,
      documentType: destinationDocumentType,
      lines: [],
    );
    notifyListeners();
  }

  //DocumentLines
  void clearDocumentLines() {
    if (document!.lines.isNotEmpty) {
      document!.lines.clear();
    }
    notifyListeners();
  }

  TaskOperation changeDocumentLineQuantity(
    DocumentLine documentLine,
    double quantity,
  ) {
    final TaskOperation taskOperation = TaskOperation(
      success: true,
      errorCode: ErrorCode.none,
      message: '',
    );

    //Check if the quantity is valid

    //Check if the quantity is valid for the stock movement

    //Check if the quantity is valid for the document line

    notifyListeners();
    return taskOperation;
  }

  //Entity
  void setEntity(Entity? entity) {
    final bool hasChanged = !Helper.isEntityEqual(entity, document!.entity);
    if (!hasChanged) {
      return;
    }
    clearDocumentLines();

    document!.entity = entity;

    setDefaultAddresses();

    notifyListeners();
  }

  //Addresses
  void setDefaultAddresses() {
    if (document == null || document!.entity == null) {
      return;
    }

    final List<Address> ownAddresses = System.instance.selfEntity!.addresses!;
    final List<Address> entityAddresses = document!.entity!.addresses!;

    switch (stockMovement) {
      case StockMovement.none:
        document!.loadingAddress = null;
        document!.unloadingAddress = null;
        break;
      case StockMovement.outbound:
        document!.loadingAddress =
            ownAddresses.firstWhereOrNull((element) => element.isDefault);
        document!.unloadingAddress =
            entityAddresses.firstWhereOrNull((element) => element.isDefault);
        break;
      case StockMovement.inbound:
        document!.loadingAddress =
            entityAddresses.firstWhereOrNull((element) => element.isDefault);
        document!.unloadingAddress =
            ownAddresses.firstWhereOrNull((element) => element.isDefault);
        break;
      case StockMovement.transfer:
      case StockMovement.inventory:
        document!.loadingAddress =
            ownAddresses.firstWhereOrNull((element) => element.isDefault);
        document!.unloadingAddress =
            ownAddresses.firstWhereOrNull((element) => element.isDefault);
    }
  }

  //SourceDocuments
  Future<void> setSourceDocumentsFromList(
    List<Document> sourceDocumentsList,
  ) async {
    //Get the DocumentLines for picking
    final List<DocumentLine> documentLines =
        await DocumentLineApi.getFromDocuments(
      this,
      sourceDocumentsList,
    );

    //Set the DocumentLines to the SourceDocuments
    for (final Document sourceDocument in sourceDocumentsList) {
      final List<DocumentLine> sourceDocumentLines = [];
      for (final DocumentLine documentLine in documentLines) {
        if (documentLine.documentErpId == sourceDocument.erpId) {
          sourceDocumentLines.add(documentLine);
        }
      }
      sourceDocument.lines = sourceDocumentLines;
    }
    sourceDocuments.clear();
    sourceDocuments = List.from(sourceDocumentsList);

    //Set the DocumentLines to the Document for picking
    setDocumentLinesFromSourceDocuments();

    notifyListeners();
  }

  void setDocumentLinesFromSourceDocuments() {
    document!.lines = [];
    final List<DocumentLine> documentLines = [];
    for (final Document sourceDocument in sourceDocuments) {
      for (final DocumentLine sourceDocumentLine in sourceDocument.lines) {
        documentLines.add(sourceDocumentLine);
      }
    }
    document!.lines = documentLines;
  }
}

mixin PickingTaskApi {
  static Future<List<PickingTask>> getByAccessId(int accessId) async {
    List<PickingTask> pickingTasksList = [];
    final String url = ApiEndPoint.getTasksByAccessId(accessId);
    final NetworkHelper networkHelper = NetworkHelper(url);
    final http.Response response =
        await networkHelper.getData(seconds: 5) as http.Response;

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      final Iterable l = jsonBody['result'] as Iterable;

      pickingTasksList = List<PickingTask>.from(
        l.map((model) => PickingTask.fromJson(model as Map<String, dynamic>)),
      );
    }

    return pickingTasksList;
  }
}
