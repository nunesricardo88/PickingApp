import 'package:flutter_guid/flutter_guid.dart';

mixin ProductFields {
  static final List<String> allValues = [
    id,
    erpId,
    reference,
    designation,
    unit,
    alternativeUnit,
    conversionFactor,
    isBatchTracked,
    isSerialNumberTracked,
  ];

  static const String id = 'id';
  static const String erpId = 'erpId';
  static const String reference = 'reference';
  static const String designation = 'designation';
  static const String unit = 'unit';
  static const String alternativeUnit = 'alternativeUnit';
  static const String conversionFactor = 'conversionFactor';
  static const String isBatchTracked = 'isBatchTracked';
  static const String isSerialNumberTracked = 'isSerialNumberTracked';
}

class Product {
  Guid id;
  String erpId;
  String reference;
  String designation;
  String unit;
  String alternativeUnit;
  double conversionFactor;
  bool isBatchTracked;
  bool isSerialNumberTracked;

  Product({
    required this.id,
    required this.erpId,
    required this.reference,
    required this.designation,
    required this.unit,
    required this.alternativeUnit,
    required this.conversionFactor,
    required this.isBatchTracked,
    required this.isSerialNumberTracked,
  });
}
