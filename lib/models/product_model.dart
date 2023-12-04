import 'dart:convert';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:http/http.dart' as http;
import 'package:n6picking_flutterapp/services/api_endpoint.dart';
import 'package:n6picking_flutterapp/services/networking.dart';

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

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: Guid(json[ProductFields.id] as String),
        erpId: json[ProductFields.erpId] as String,
        reference: json[ProductFields.reference] as String,
        designation: json[ProductFields.designation] as String,
        unit: json[ProductFields.unit] as String,
        alternativeUnit: json[ProductFields.alternativeUnit] as String,
        conversionFactor: json[ProductFields.conversionFactor] as double,
        isBatchTracked: json[ProductFields.isBatchTracked] as bool,
        isSerialNumberTracked:
            json[ProductFields.isSerialNumberTracked] as bool,
      );
}

class ProductApi {
  List<Product> allProducts = [];

  static ProductApi instance = ProductApi._init();

  bool isInitialized = false;

  ProductApi._init() {
    initialize();
  }

  Future<void> initialize() async {
    allProducts = await getAll();
    isInitialized = true;
  }

  static Future<List<Product>> getAll() async {
    List<Product> productList = [];
    final String getUrl = ApiEndPoint.getAllProducts();

    final NetworkHelper networkHelper = NetworkHelper(getUrl);
    final http.Response response =
        await networkHelper.getData(seconds: 30) as http.Response;

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      final Iterable l = jsonBody['result'] as Iterable;

      productList = List<Product>.from(
        l.map((model) => Product.fromJson(model as Map<String, dynamic>)),
      );
    }
    return productList;
  }
}
