import 'package:flutter_guid/flutter_guid.dart';

mixin BatchFields {
  static final List<String> allValues = [
    id,
    erpId,
    batchNumber,
    expirationDate,
  ];

  static const String id = 'id';
  static const String erpId = 'erpId';
  static const String batchNumber = 'batchNumber';
  static const String expirationDate = 'expirationDate';
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

  factory Batch.fromJson(Map<String, dynamic> json) => Batch(
        id: Guid(json[BatchFields.id] as String),
        erpId: json[BatchFields.erpId] as String,
        batchNumber: json[BatchFields.batchNumber] as String,
        expirationDate:
            DateTime.parse(json[BatchFields.expirationDate] as String),
      );
}
