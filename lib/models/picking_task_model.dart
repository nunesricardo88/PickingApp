import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:http/http.dart' as http;
import 'package:n6picking_flutterapp/models/address_model.dart';
import 'package:n6picking_flutterapp/models/batch_model.dart';
import 'package:n6picking_flutterapp/models/document_line_model.dart';
import 'package:n6picking_flutterapp/models/document_model.dart';
import 'package:n6picking_flutterapp/models/document_type_model.dart';
import 'package:n6picking_flutterapp/models/entity_model.dart';
import 'package:n6picking_flutterapp/models/product_model.dart';
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

  Map<String, dynamic> toJson() => {
        PickingTaskFields.id: id.toString(),
        PickingTaskFields.erpId: erpId,
        PickingTaskFields.accessId: accessId,
        PickingTaskFields.userErpId: userErpId,
        PickingTaskFields.group: group,
        PickingTaskFields.name: name,
        PickingTaskFields.description: description,
        PickingTaskFields.stockMovement: stockMovement.index,
        PickingTaskFields.document: document!.toJson(),
        PickingTaskFields.customOptions: customOptions,
      };

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

  DocumentLine createDocumentLineByProduct({
    required Product product,
    Batch? batch,
  }) {
    return DocumentLine(
      id: Guid.newGuid,
      documentId: document!.id,
      documentErpId: document!.erpId,
      product: product,
      designation: product.designation,
      quantity: 0,
      quantityPicked: 0,
      quantityToPick: 0,
      totalQuantity: 0,
      unit: product.unit,
      alternativeQuantity: 0,
      alternativeQuantityPicked: 0,
      alternativeQuantityToPick: 0,
      alternativeTotalQuantity: 0,
      alternativeUnit: product.alternativeUnit,
      batch: batch,
    );
  }

  TaskOperation addToDocumentLineQuantity(
    DocumentLine documentLine,
    double quantity,
  ) {
    final TaskOperation taskOperation = TaskOperation(
      success: true,
      errorCode: ErrorCode.none,
      message: '',
    );

    //TODO - Check if the quantity is valid

    //TODO - Check if the quantity is valid for the stock movement

    //TODO - Check if the quantity is valid for the document line

    documentLine.quantity += quantity;

    //Change all quantityFields of the documentLine
    final DocumentLine? sourceDocumentLine =
        getSourceDocumentLine(documentLine);
    if (sourceDocumentLine != null) {
      documentLine.quantityPicked =
          sourceDocumentLine.quantityPicked + documentLine.quantity;
    }
    if (documentLine.product.conversionFactor != 0) {
      documentLine.alternativeQuantity =
          documentLine.quantity * documentLine.product.conversionFactor;
      documentLine.alternativeQuantityPicked =
          documentLine.quantityPicked * documentLine.product.conversionFactor;
    }

    //Remove from Document if it has no quantity and no linkedLineErpId
    if (documentLine.quantity == 0) {
      if (documentLine.linkedLineErpId == null) {
        document!.lines.remove(documentLine);
      } else {
        //Remove from Document if there are more lines with the same linkedLineErpId
        final DocumentLine? lineWithSameErpId =
            document!.lines.firstWhereOrNull(
          (element) =>
              element.linkedLineErpId != null &&
              element.id != documentLine.id &&
              element.linkedLineErpId!.trim() ==
                  documentLine.linkedLineErpId!.trim(),
        );

        if (lineWithSameErpId != null) {
          document!.lines.remove(documentLine);
        }
      }
    }

    notifyListeners();
    return taskOperation;
  }

  //Entity
  Future<void> setEntity(Entity? entity) async {
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
        if (stockMovement == StockMovement.inventory) {
          documentLines.add(
            sourceDocumentLine.copyWith(
              linkedLineErpId: sourceDocumentLine.erpId,
              quantity: sourceDocumentLine.quantityPicked,
            ),
          );
        } else {
          documentLines.add(
            sourceDocumentLine.copyWith(
              linkedLineErpId: sourceDocumentLine.erpId,
            ),
          );
        }
      }
      document!.name = sourceDocument.name;
      document!.erpId = sourceDocument.erpId;
    }
    document!.lines = documentLines;
  }

  DocumentLine? getSourceDocumentLine(DocumentLine documentLine) {
    DocumentLine? sourceDocumentLine;
    for (final Document sourceDocument in sourceDocuments) {
      sourceDocumentLine = sourceDocument.lines.firstWhereOrNull(
        (element) => element.erpId == documentLine.erpId,
      );
      if (sourceDocumentLine != null) {
        break;
      }
    }
    return sourceDocumentLine;
  }

  Future<TaskOperation> printLabel(
    DocumentLine documentLine,
    int labelsToPrint,
  ) async {
    try {
      final TaskOperation taskOperation = TaskOperation(
        success: true,
        errorCode: ErrorCode.none,
        message: 'Pedido enviado para a impressora',
      );

      final DocumentLine line = documentLine.copyWith(
        alternativeQuantity: labelsToPrint.toDouble(),
        order: 1,
      );

      final Map<String, dynamic> documentLineJsonBody = line.toJson();
      String postPutUrl = '';
      http.Response response;
      final String jsonBody = json.encode(documentLineJsonBody);

      postPutUrl = ApiEndPoint.printDocumentLineLabel();
      final NetworkHelper networkHelper = NetworkHelper(postPutUrl);
      response = await networkHelper.postData(
        json: jsonBody,
        seconds: 30,
      ) as http.Response;

      final Map<String, dynamic> responseBody =
          jsonDecode(response.body) as Map<String, dynamic>;
      final Map<String, dynamic> result =
          responseBody['result'] as Map<String, dynamic>;
      final int statusCode = result['statusCode'] as int;
      final String message = result['message'] as String;

      if (statusCode == 201 || statusCode == 200) {
        return taskOperation;
      } else {
        return TaskOperation(
          success: false,
          errorCode: ErrorCode.unknownError,
          message: message,
        );
      }
    } catch (e) {
      return TaskOperation(
        success: false,
        errorCode: ErrorCode.unknownError,
        message: 'Erro ao imprimir a etiqueta',
      );
    }
  }

  Future<TaskOperation> postNewBarcode(
    DocumentLine documentLine,
    String barcode,
  ) async {
    try {
      final TaskOperation taskOperation = TaskOperation(
        success: true,
        errorCode: ErrorCode.none,
        message: 'Código de barras criado com sucesso',
      );

      final Product productPost = documentLine.product.copy(
        barcode: [],
      );
      productPost.barcode.add(barcode);

      final Map<String, dynamic> documentLineJsonBody = productPost.toJson();
      String postPutUrl = '';
      http.Response response;
      final String jsonBody = json.encode(documentLineJsonBody);

      postPutUrl = ApiEndPoint.postNewBarcode();
      final NetworkHelper networkHelper = NetworkHelper(postPutUrl);
      response = await networkHelper.postData(
        json: jsonBody,
        seconds: 30,
      ) as http.Response;

      final Map<String, dynamic> responseBody =
          jsonDecode(response.body) as Map<String, dynamic>;
      final Map<String, dynamic> result =
          responseBody['result'] as Map<String, dynamic>;
      final int statusCode = result['statusCode'] as int;
      final String message = result['message'] as String;

      if (statusCode == 201 || statusCode == 200) {
        for (final Product product in ProductApi.instance.allProducts) {
          if (product.erpId == documentLine.product.erpId) {
            product.barcode.add(barcode);
            break;
          }
        }
        return taskOperation;
      } else {
        return TaskOperation(
          success: false,
          errorCode: ErrorCode.unknownError,
          message: message,
        );
      }
    } catch (e) {
      return TaskOperation(
        success: false,
        errorCode: ErrorCode.unknownError,
        message: 'Erro ao criar o código de barras',
      );
    }
  }

  Future<TaskOperation> saveToServer() async {
    try {
      final TaskOperation taskOperation = TaskOperation(
        success: true,
        errorCode: ErrorCode.none,
        message: '',
      );

      final List<DocumentLine> originalDocumentLines = document!.lines.toList();
      final List<DocumentLine> documentLines = document!.lines.toList();

      //Remove extra lines
      if (stockMovement == StockMovement.inventory) {
        documentLines.removeWhere(
          (element) => element.quantity == element.totalQuantity,
        );
      }

      if (stockMovement == StockMovement.transfer) {
        documentLines.removeWhere(
          (element) =>
              element.originLocation == null ||
              element.destinationLocation == null,
        );
      }

      //Check if lines that need a batch have a batch
      for (final DocumentLine documentLine in documentLines) {
        if (documentLine.product.isBatchTracked &&
            documentLine.batch == null &&
            documentLine.quantity > 0) {
          taskOperation.success = false;
          taskOperation.errorCode = ErrorCode.errorSavingDocument;
          taskOperation.message = 'Há produtos sem o lote preenchido';
          return taskOperation;
        }
      }

      int lineOrder = 0;
      if (stockMovement == StockMovement.inventory) {
        for (final DocumentLine documentLine in documentLines) {
          if (documentLine.erpId != null) {
            lineOrder = documentLine.order ?? lineOrder;
          } else {
            lineOrder += 1000;
          }
          documentLine.order = lineOrder;
        }
      } else {
        for (final DocumentLine documentLine in documentLines) {
          if (documentLine.quantity > 0) {
            lineOrder += 1000;
            documentLine.order = lineOrder;
          }
        }
      }

      //Delete all documentLines with quantity = 0
      if (stockMovement != StockMovement.inventory) {
        documentLines.removeWhere(
          (element) => element.quantity <= 0,
        );
      }

      //Don't save if there are no lines
      if (documentLines.isEmpty) {
        taskOperation.success = false;
        taskOperation.errorCode = ErrorCode.errorSavingDocument;
        taskOperation.message = 'Não encontrei linhas com quantidade.';
        return taskOperation;
      }

      //Clean not needed fields
      userErpId = System.instance.activeUser!.erpId;
      document!.number = 0;
      document!.entity!.addresses = [];

      //Set the new documentLines to the document
      document!.lines = documentLines;

      final Map<String, dynamic> documentJsonBody = toJson();
      String postPutUrl = '';
      http.Response response;
      final String jsonBody = json.encode(documentJsonBody);

      //Reset the old documentLines to the document
      document!.lines = originalDocumentLines;

      postPutUrl = ApiEndPoint.postPickingTask();
      final NetworkHelper networkHelper = NetworkHelper(postPutUrl);

      //Helper.printDebug(jsonBody);

      response = await networkHelper.postData(
        json: jsonBody,
        seconds: 30,
      ) as http.Response;

      final Map<String, dynamic> responseBody =
          jsonDecode(response.body) as Map<String, dynamic>;
      final Map<String, dynamic> result =
          responseBody['result'] as Map<String, dynamic>;
      final int statusCode = result['statusCode'] as int;
      final String message = result['message'] as String;

      if (statusCode == 201 || statusCode == 200) {
        return taskOperation;
      } else {
        return TaskOperation(
          success: false,
          errorCode: ErrorCode.errorSavingDocument,
          message: message,
        );
      }
    } catch (e) {
      return TaskOperation(
        success: false,
        errorCode: ErrorCode.errorSavingDocument,
        message: 'Erro ao salvar o documento',
      );
    }
  }

  void clear() {
    document = null;
    sourceDocuments.clear();
    notifyListeners();
  }
}

mixin PickingTaskApi {
  static Future<List<PickingTask>> getByAccessId(int accessId) async {
    List<PickingTask> pickingTasksList = [];
    final String url = ApiEndPoint.getTasksByAccessId(accessId);
    final NetworkHelper networkHelper = NetworkHelper(url);
    final http.Response response =
        await networkHelper.getData(seconds: 10) as http.Response;

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      if (jsonBody['result'] != null) {
        final Iterable l = jsonBody['result'] as Iterable;

        pickingTasksList = List<PickingTask>.from(
          l.map((model) => PickingTask.fromJson(model as Map<String, dynamic>)),
        );
      }
    }

    pickingTasksList.sort((a, b) => a.group.compareTo(b.group));

    return pickingTasksList;
  }
}
