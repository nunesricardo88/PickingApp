import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:http/http.dart' as http;
import 'package:n6picking_flutterapp/models/document_line_model.dart';
import 'package:n6picking_flutterapp/models/document_model.dart';
import 'package:n6picking_flutterapp/models/document_type_model.dart';
import 'package:n6picking_flutterapp/models/entity_model.dart';
import 'package:n6picking_flutterapp/services/api_endpoint.dart';
import 'package:n6picking_flutterapp/services/networking.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:n6picking_flutterapp/utilities/helper.dart';

mixin PickingTaskFields {
  static final List<String> allValues = [
    id,
    erpId,
    accessId,
    userErpId,
    group,
    name,
    description,
    taskType,
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
  static const String taskType = 'taskType';
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
  PickingTaskType taskType;
  Document? document;
  DocumentType? originDocumentType;
  DocumentType destinationDocumentType;
  String customOptions;
  List<Document> sourceDocuments;
  List<Document> sourceDocumentsTemp;

  PickingTask({
    required this.id,
    required this.erpId,
    required this.accessId,
    this.userErpId,
    required this.group,
    required this.name,
    required this.description,
    required this.taskType,
    this.document,
    this.originDocumentType,
    required this.destinationDocumentType,
    required this.customOptions,
    this.sourceDocuments = const [],
    this.sourceDocumentsTemp = const [],
  });

  factory PickingTask.fromJson(Map<String, dynamic> json) => PickingTask(
        id: Guid(json[PickingTaskFields.id] as String),
        erpId: json[PickingTaskFields.erpId] as String,
        accessId: json[PickingTaskFields.accessId] as int,
        userErpId: json[PickingTaskFields.userErpId] as String?,
        group: json[PickingTaskFields.group] as String,
        name: json[PickingTaskFields.name] as String,
        description: json[PickingTaskFields.description] as String,
        taskType:
            PickingTaskType.values[json[PickingTaskFields.taskType] as int],
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
        sourceDocumentsTemp: [],
      );

  PickingTask copy({
    Guid? id,
    String? erpId,
    int? accessId,
    String? userErpId,
    String? group,
    String? name,
    String? description,
    PickingTaskType? taskType,
    Document? document,
    DocumentType? originDocumentType,
    DocumentType? destinationDocumentType,
    String? customOptions,
    List<Document>? sourceDocuments,
    List<Document>? sourceDocumentsTemp,
  }) =>
      PickingTask(
        id: id ?? this.id,
        erpId: erpId ?? this.erpId,
        accessId: accessId ?? this.accessId,
        userErpId: userErpId ?? this.userErpId,
        group: group ?? this.group,
        name: name ?? this.name,
        description: description ?? this.description,
        taskType: taskType ?? this.taskType,
        document: document ?? this.document,
        originDocumentType: originDocumentType ?? this.originDocumentType,
        destinationDocumentType:
            destinationDocumentType ?? this.destinationDocumentType,
        customOptions: customOptions ?? this.customOptions,
        sourceDocuments: sourceDocuments ?? this.sourceDocuments,
        sourceDocumentsTemp: sourceDocumentsTemp ?? this.sourceDocumentsTemp,
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
    taskType = pickingTask.taskType;
    document = pickingTask.document;
    originDocumentType = pickingTask.originDocumentType;
    destinationDocumentType = pickingTask.destinationDocumentType;
    customOptions = pickingTask.customOptions;
    sourceDocuments = pickingTask.sourceDocuments;
    sourceDocumentsTemp = pickingTask.sourceDocumentsTemp;

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

  //Entity
  void setEntity(Entity? entity) {
    final bool hasChanged = !Helper.isEntityEqual(entity, document!.entity);
    if (!hasChanged) {
      return;
    }

    clearDocumentLines();

    document!.entity = entity;

    if (entity != null) {
      document!.address =
          entity.addresses != null && entity.addresses!.isNotEmpty
              ? entity.addresses![0]
              : null;
    } else {
      document!.address = null;
    }

    notifyListeners();
  }

  //Source Documents
  void setSourceDocuments(List<Document> sourceDocuments) {
    this.sourceDocuments.clear();
    this.sourceDocuments.addAll(sourceDocuments);
    notifyListeners();
  }

  void addToSourceDocumentTempList(Document sourceDocument) {
    sourceDocumentsTemp.add(sourceDocument);
    notifyListeners();
  }

  void removeFromSourceDocumentTempList(Document sourceDocument) {
    sourceDocumentsTemp
        .removeWhere((document) => document.id == sourceDocument.id);
    notifyListeners();
  }

  void clearTemporaryBoList() {
    sourceDocumentsTemp = [];
    notifyListeners();
  }

  void saveSourceDocumentsFromTemp() {
    sourceDocuments.clear();
    clearDocumentLines();
    sourceDocuments = List.from(sourceDocumentsTemp);
    sourceDocumentsTemp = [];

    //copy all documentLines from sourceDocuments to Document
    for (final Document sourceDocument in sourceDocuments) {
      for (final DocumentLine sourceDocumentLine in sourceDocument.lines) {
        final DocumentLine documentLine = sourceDocumentLine.copyWith(
          id: Guid.newGuid,
          erpId: '',
          documentId: document!.id,
          linkedLineErpId: sourceDocumentLine.erpId,
          order: 0,
        );
        document!.lines.add(documentLine);
      }
    }

    notifyListeners();
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
