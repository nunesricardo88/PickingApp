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

  static const String id = 'Id';
  static const String erpId = 'ErpId';
  static const String reference = 'Reference';
  static const String designation = 'Designation';
  static const String unit = 'Unit';
  static const String alternativeUnit = 'AlternativeUnit';
  static const String conversionFactor = 'ConversionFactor';
  static const String isBatchTracked = 'IsBatchTracked';
  static const String isSerialNumberTracked = 'IsSerialNumberTracked';
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
