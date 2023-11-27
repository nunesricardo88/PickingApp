import 'package:flutter_guid/flutter_guid.dart';

mixin BatchFields {
  static final List<String> allValues = [
    id,
    erpId,
    batchNumber,
    expirationDate
  ];

  static const String id = 'Id';
  static const String erpId = 'ErpId';
  static const String batchNumber = 'BatchNumber';
  static const String expirationDate = 'ExpirationDate';
}

class Batch {
  Guid id;
  String erpId;
  String batchNumber;
  DateTime expirationDate;

  Batch({
    required this.id,
    required this.erpId,
    required this.batchNumber,
    required this.expirationDate,
  });
}
