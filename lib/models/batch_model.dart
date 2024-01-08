import 'dart:convert';

import 'package:flutter_guid/flutter_guid.dart';
import 'package:http/http.dart' as http;
import 'package:n6picking_flutterapp/services/api_endpoint.dart';
import 'package:n6picking_flutterapp/services/networking.dart';

mixin BatchFields {
  static final List<String> allValues = [
    id,
    erpId,
    batchNumber,
    expirationDate,
    usaMolho,
    idMolho,
    numBarras,
    compBarra,
  ];

  static const String id = 'id';
  static const String erpId = 'erpId';
  static const String batchNumber = 'batchNumber';
  static const String expirationDate = 'expirationDate';
  static const String usaMolho = 'usaMolho';
  static const String idMolho = 'idMolho';
  static const String numBarras = 'numBarras';
  static const String compBarra = 'compBarra';
}

class Batch {
  Guid id;
  String? erpId;
  String batchNumber;
  DateTime expirationDate;
  bool usaMolho;
  Guid? idMolho;
  double numBarras;
  double compBarra;

  Batch({
    required this.id,
    this.erpId,
    required this.batchNumber,
    required this.expirationDate,
    this.usaMolho = false,
    this.idMolho,
    this.numBarras = 0.0,
    this.compBarra = 0.0,
  });

  factory Batch.fromJson(Map<String, dynamic> json) => Batch(
        id: Guid(json[BatchFields.id] as String),
        erpId: json[BatchFields.erpId] as String,
        batchNumber: json[BatchFields.batchNumber] as String,
        expirationDate:
            DateTime.parse(json[BatchFields.expirationDate] as String),
        // ignore: avoid_bool_literals_in_conditional_expressions
        usaMolho: json[BatchFields.usaMolho] == null
            ? false
            : json[BatchFields.usaMolho] as bool,
        idMolho: json[BatchFields.idMolho] == null
            ? null
            : Guid(json[BatchFields.idMolho] as String),
        numBarras: json[BatchFields.numBarras] != null
            ? json[BatchFields.numBarras] is int
                ? (json[BatchFields.numBarras] as int).toDouble()
                : json[BatchFields.numBarras] as double
            : 0,
        compBarra: json[BatchFields.compBarra] != null
            ? json[BatchFields.compBarra] is int
                ? (json[BatchFields.compBarra] as int).toDouble()
                : json[BatchFields.compBarra] as double
            : 0,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        BatchFields.id: id.toString(),
        BatchFields.erpId: erpId,
        BatchFields.batchNumber: batchNumber,
        BatchFields.expirationDate: expirationDate.toIso8601String(),
        BatchFields.usaMolho: usaMolho,
        BatchFields.idMolho:
            idMolho != null ? idMolho.toString() : Guid.newGuid.toString(),
        BatchFields.numBarras: numBarras,
        BatchFields.compBarra: compBarra,
      };
}

mixin BatchApi {
  static Future<Batch?> getByReferenceAndBatchNumber(
    String productReference,
    String batchNumber,
  ) async {
    final String url = ApiEndPoint.getBatchByReferenceAndBatchNumber(
      productReference,
      batchNumber,
    );
    final NetworkHelper networkHelper = NetworkHelper(url);
    final http.Response response =
        await networkHelper.getData(seconds: 10) as http.Response;

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      if (jsonBody['result'] == null) {
        return null;
      }
      final Map<String, dynamic> result =
          jsonBody['result'] as Map<String, dynamic>;

      return Batch.fromJson(result);
    } else {
      return null;
    }
  }

  static Future<List<Batch>> getSplitBatches(
    int noFl,
    String reference,
    double numMolhos,
    double numBarras,
    double compBarra,
  ) async {
    final String url = ApiEndPoint.getSplitBatches(
      noFl,
      reference,
      numMolhos,
      numBarras,
      compBarra,
    );
    List<Batch> batches = [];
    final NetworkHelper networkHelper = NetworkHelper(url);
    final http.Response response =
        await networkHelper.getData(seconds: 10) as http.Response;

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      final Iterable l = jsonBody['result'] as Iterable;

      batches = List<Batch>.from(
        l.map((model) => Batch.fromJson(model as Map<String, dynamic>)),
      );
    }
    return batches;
  }
}
