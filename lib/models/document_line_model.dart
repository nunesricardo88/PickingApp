import 'package:flutter_guid/flutter_guid.dart';
import 'package:n6picking_flutterapp/models/batch_model.dart';
import 'package:n6picking_flutterapp/models/location_model.dart';
import 'package:n6picking_flutterapp/models/product_model.dart';

mixin DocumentLineFields {
  static const List<String> allFields = <String>[
    id,
    erpId,
    documentId,
    linkedLineErpId,
    order,
    product,
    batch,
    quantity,
    quantityPicked,
    unit,
    alternativeQuantity,
    alternativeQuantityPicked,
    alternativeUnit,
    originLocation,
    destinationLocation,
  ];

  static const String id = 'id';
  static const String erpId = 'erpId';
  static const String documentId = 'documentId';
  static const String linkedLineErpId = 'linkedLineErpId';
  static const String order = 'order';
  static const String product = 'product';
  static const String batch = 'batch';
  static const String quantity = 'quantity';
  static const String quantityPicked = 'quantityPicked';
  static const String unit = 'unit';
  static const String alternativeQuantity = 'alternativeQuantity';
  static const String alternativeQuantityPicked = 'alternativeQuantityPicked';
  static const String alternativeUnit = 'alternativeUnit';
  static const String originLocation = 'originLocation';
  static const String destinationLocation = 'destinationLocation';
}

class DocumentLine {
  Guid id;
  String erpId;
  Guid documentId;
  String? linkedLineErpId;
  int order;
  Product product;
  Batch batch;
  double quantity;
  double quantityPicked;
  String unit;
  double alternativeQuantity;
  double alternativeQuantityPicked;
  String alternativeUnit;
  Location originLocation;
  Location destinationLocation;

  DocumentLine({
    required this.id,
    required this.erpId,
    required this.documentId,
    required this.linkedLineErpId,
    required this.order,
    required this.product,
    required this.batch,
    required this.quantity,
    required this.quantityPicked,
    required this.unit,
    required this.alternativeQuantity,
    required this.alternativeQuantityPicked,
    required this.alternativeUnit,
    required this.originLocation,
    required this.destinationLocation,
  });

  DocumentLine copyWith({
    Guid? id,
    String? erpId,
    Guid? documentId,
    String? linkedLineErpId,
    int? order,
    Product? product,
    Batch? batch,
    double? quantity,
    double? quantityPicked,
    String? unit,
    double? alternativeQuantity,
    double? alternativeQuantityPicked,
    String? alternativeUnit,
    Location? originLocation,
    Location? destinationLocation,
  }) {
    return DocumentLine(
      id: id ?? this.id,
      erpId: erpId ?? this.erpId,
      documentId: documentId ?? this.documentId,
      linkedLineErpId: linkedLineErpId ?? this.linkedLineErpId,
      order: order ?? this.order,
      product: product ?? this.product,
      batch: batch ?? this.batch,
      quantity: quantity ?? this.quantity,
      quantityPicked: quantityPicked ?? this.quantityPicked,
      unit: unit ?? this.unit,
      alternativeQuantity: alternativeQuantity ?? this.alternativeQuantity,
      alternativeQuantityPicked:
          alternativeQuantityPicked ?? this.alternativeQuantityPicked,
      alternativeUnit: alternativeUnit ?? this.alternativeUnit,
      originLocation: originLocation ?? this.originLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
    );
  }
}
