import 'dart:convert';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:http/http.dart' as http;
import 'package:n6picking_flutterapp/models/batch_model.dart';
import 'package:n6picking_flutterapp/models/document_model.dart';
import 'package:n6picking_flutterapp/models/location_model.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';
import 'package:n6picking_flutterapp/models/product_model.dart';
import 'package:n6picking_flutterapp/services/api_endpoint.dart';
import 'package:n6picking_flutterapp/services/networking.dart';

mixin DocumentLineFields {
  static const List<String> allFields = [
    id,
    erpId,
    documentId,
    documentErpId,
    linkedLineErpId,
    order,
    product,
    designation,
    batch,
    quantity,
    quantityPicked,
    quantityToPick,
    totalQuantity,
    unit,
    alternativeQuantity,
    alternativeQuantityPicked,
    alternativeQuantityToPick,
    alternativeTotalQuantity,
    alternativeUnit,
    originLocation,
    destinationLocation,
    extraFields,
  ];

  static const String id = 'id';
  static const String erpId = 'erpId';
  static const String documentId = 'documentId';
  static const String documentErpId = 'documentErpId';
  static const String linkedLineErpId = 'linkedLineErpId';
  static const String order = 'order';
  static const String product = 'product';
  static const String designation = 'designation';
  static const String batch = 'batch';
  static const String quantity = 'quantity';
  static const String quantityPicked = 'quantityPicked';
  static const String quantityToPick = 'quantityToPick';
  static const String totalQuantity = 'totalQuantity';
  static const String unit = 'unit';
  static const String alternativeQuantity = 'alternativeQuantity';
  static const String alternativeQuantityPicked = 'alternativeQuantityPicked';
  static const String alternativeQuantityToPick = 'alternativeQuantityToPick';
  static const String alternativeTotalQuantity = 'alternativeTotalQuantity';
  static const String alternativeUnit = 'alternativeUnit';
  static const String originLocation = 'originLocation';
  static const String destinationLocation = 'destinationLocation';
  static const String extraFields = 'extraFields';
}

class DocumentLine {
  Guid id;
  String? erpId;
  Guid documentId;
  String? documentErpId;
  String? linkedLineErpId;
  int? order;
  Product product;
  String designation;
  Batch? batch;
  double quantity;
  double quantityPicked;
  double quantityToPick;
  double totalQuantity;
  String unit;
  double alternativeQuantity;
  double alternativeQuantityPicked;
  double alternativeQuantityToPick;
  double alternativeTotalQuantity;
  String alternativeUnit;
  Location? originLocation;
  Location? destinationLocation;
  String? extraFields;

  DocumentLine({
    required this.id,
    this.erpId,
    required this.documentId,
    this.documentErpId,
    this.linkedLineErpId,
    this.order,
    required this.product,
    required this.designation,
    this.batch,
    required this.quantity,
    required this.quantityPicked,
    required this.quantityToPick,
    required this.totalQuantity,
    required this.unit,
    required this.alternativeQuantity,
    required this.alternativeQuantityPicked,
    required this.alternativeQuantityToPick,
    required this.alternativeTotalQuantity,
    required this.alternativeUnit,
    this.originLocation,
    this.destinationLocation,
    this.extraFields,
  });

  factory DocumentLine.fromJson(Map<String, dynamic> json) => DocumentLine(
        id: Guid(json[DocumentLineFields.id] as String),
        erpId: json[DocumentLineFields.erpId] as String?,
        documentId: Guid(json[DocumentLineFields.documentId] as String),
        documentErpId: json[DocumentLineFields.documentErpId] as String?,
        linkedLineErpId: json[DocumentLineFields.linkedLineErpId] as String?,
        order: json[DocumentLineFields.order] as int?,
        product: Product.fromJson(
          json[DocumentLineFields.product] as Map<String, dynamic>,
        ),
        designation: json[DocumentLineFields.designation] as String,
        batch: json[DocumentLineFields.batch] == null
            ? null
            : Batch.fromJson(
                json[DocumentLineFields.batch] as Map<String, dynamic>,
              ),
        quantity: json[DocumentLineFields.quantity] as double,
        quantityPicked: json[DocumentLineFields.quantityPicked] as double,
        quantityToPick: json[DocumentLineFields.quantityToPick] as double,
        totalQuantity: json[DocumentLineFields.totalQuantity] as double,
        unit: json[DocumentLineFields.unit] as String,
        alternativeQuantity:
            json[DocumentLineFields.alternativeQuantity] as double,
        alternativeQuantityPicked:
            json[DocumentLineFields.alternativeQuantityPicked] as double,
        alternativeQuantityToPick:
            json[DocumentLineFields.alternativeQuantityToPick] as double,
        alternativeTotalQuantity:
            json[DocumentLineFields.alternativeTotalQuantity] as double,
        alternativeUnit: json[DocumentLineFields.alternativeUnit] as String,
        originLocation: json[DocumentLineFields.originLocation] == null
            ? null
            : Location.fromJson(
                json[DocumentLineFields.originLocation] as Map<String, dynamic>,
              ),
        destinationLocation:
            json[DocumentLineFields.destinationLocation] == null
                ? null
                : Location.fromJson(
                    json[DocumentLineFields.destinationLocation]
                        as Map<String, dynamic>,
                  ),
        extraFields: json[DocumentLineFields.extraFields] as String?,
      );

  Map<String, dynamic> toJson() => {
        DocumentLineFields.id: id.toString(),
        DocumentLineFields.erpId: erpId,
        DocumentLineFields.documentId: documentId.toString(),
        DocumentLineFields.documentErpId: documentErpId,
        DocumentLineFields.linkedLineErpId: linkedLineErpId,
        DocumentLineFields.order: order,
        DocumentLineFields.product: product.toJson(),
        DocumentLineFields.designation: designation,
        DocumentLineFields.batch: batch?.toJson(),
        DocumentLineFields.quantity: quantity,
        DocumentLineFields.quantityPicked: quantityPicked,
        DocumentLineFields.quantityToPick: quantityToPick,
        DocumentLineFields.totalQuantity: totalQuantity,
        DocumentLineFields.unit: unit,
        DocumentLineFields.alternativeQuantity: alternativeQuantity,
        DocumentLineFields.alternativeQuantityPicked: alternativeQuantityPicked,
        DocumentLineFields.alternativeQuantityToPick: alternativeQuantityToPick,
        DocumentLineFields.alternativeTotalQuantity: alternativeTotalQuantity,
        DocumentLineFields.alternativeUnit: alternativeUnit,
        DocumentLineFields.originLocation: originLocation?.toJson(),
        DocumentLineFields.destinationLocation: destinationLocation?.toJson(),
        DocumentLineFields.extraFields: extraFields,
      };

  DocumentLine copyWith({
    Guid? id,
    String? erpId,
    Guid? documentId,
    String? documentErpId,
    String? linkedLineErpId,
    int? order,
    Product? product,
    String? designation,
    Batch? batch,
    double? quantity,
    double? quantityPicked,
    double? quantityToPick,
    double? totalQuantity,
    String? unit,
    double? alternativeQuantity,
    double? alternativeQuantityPicked,
    double? alternativeQuantityToPick,
    double? alternativeTotalQuantity,
    String? alternativeUnit,
    Location? originLocation,
    Location? destinationLocation,
    String? extraFields,
  }) {
    return DocumentLine(
      id: id ?? this.id,
      erpId: erpId ?? this.erpId,
      documentId: documentId ?? this.documentId,
      documentErpId: documentErpId ?? this.documentErpId,
      linkedLineErpId: linkedLineErpId ?? this.linkedLineErpId,
      order: order ?? this.order,
      product: product ?? this.product,
      designation: designation ?? this.designation,
      batch: batch ?? this.batch,
      quantity: quantity ?? this.quantity,
      quantityPicked: quantityPicked ?? this.quantityPicked,
      quantityToPick: quantityToPick ?? this.quantityToPick,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      unit: unit ?? this.unit,
      alternativeQuantity: alternativeQuantity ?? this.alternativeQuantity,
      alternativeQuantityPicked:
          alternativeQuantityPicked ?? this.alternativeQuantityPicked,
      alternativeQuantityToPick:
          alternativeQuantityToPick ?? this.alternativeQuantityToPick,
      alternativeTotalQuantity:
          alternativeTotalQuantity ?? this.alternativeTotalQuantity,
      alternativeUnit: alternativeUnit ?? this.alternativeUnit,
      originLocation: originLocation ?? this.originLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      extraFields: extraFields ?? this.extraFields,
    );
  }
}

mixin DocumentLineApi {
  static Future<List<DocumentLine>> getFromDocuments(
    PickingTask task,
    List<Document> documents,
  ) async {
    List<DocumentLine> documentLines = [];
    final String url = ApiEndPoint.getLinesFromDocuments(task, documents);
    final NetworkHelper networkHelper = NetworkHelper(url);
    final http.Response response =
        await networkHelper.getData(seconds: 30) as http.Response;

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      if (jsonBody['result'] != null) {
        final Iterable l = jsonBody['result'] as Iterable;
        documentLines = List<DocumentLine>.from(
          l.map(
            (model) => DocumentLine.fromJson(model as Map<String, dynamic>),
          ),
        );
        documentLines.sort((a, b) => a.order!.compareTo(b.order!));
      }
    }

    return documentLines;
  }
}
