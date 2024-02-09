import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:http/http.dart' as http;
import 'package:n6picking_flutterapp/services/api_endpoint.dart';
import 'package:n6picking_flutterapp/services/networking.dart';
import 'package:n6picking_flutterapp/utilities/system.dart';

const String tableProduct = 'product';
mixin ProductFields {
  static final List<String> allValues = [
    id,
    erpId,
    reference,
    designation,
    barcode,
    unit,
    alternativeUnit,
    conversionFactor,
    isBatchTracked,
    isSerialNumberTracked,
    usaMolho,
  ];

  static const String id = 'id';
  static const String erpId = 'erpId';
  static const String reference = 'reference';
  static const String designation = 'designation';
  static const String barcode = 'barcode';
  static const String unit = 'unit';
  static const String alternativeUnit = 'alternativeUnit';
  static const String conversionFactor = 'conversionFactor';
  static const String isBatchTracked = 'isBatchTracked';
  static const String isSerialNumberTracked = 'isSerialNumberTracked';
  static const String usaMolho = 'usaMolho';
}

class Product {
  Guid id;
  String erpId;
  String reference;
  String designation;
  List<String> barcode;
  String unit;
  String alternativeUnit;
  double conversionFactor;
  bool isBatchTracked;
  bool isSerialNumberTracked;
  bool usaMolho;

  Product({
    required this.id,
    required this.erpId,
    required this.reference,
    required this.designation,
    required this.barcode,
    required this.unit,
    required this.alternativeUnit,
    required this.conversionFactor,
    required this.isBatchTracked,
    required this.isSerialNumberTracked,
    required this.usaMolho,
  });

  factory Product.fromJsonAPI(Map<String, dynamic> json) => Product(
        id: Guid(json[ProductFields.id] as String),
        erpId: json[ProductFields.erpId] as String,
        reference: json[ProductFields.reference] as String,
        designation: json[ProductFields.designation] as String,
        barcode: (json[ProductFields.barcode] as String).split(','),
        unit: json[ProductFields.unit] as String,
        alternativeUnit: json[ProductFields.alternativeUnit] as String,
        conversionFactor: json[ProductFields.conversionFactor] as double,
        isBatchTracked: json[ProductFields.isBatchTracked] as bool,
        isSerialNumberTracked:
            json[ProductFields.isSerialNumberTracked] as bool,
        usaMolho: json[ProductFields.usaMolho] as bool,
      );

  Map<String, Object?> toJson() => {
        ProductFields.id: id.toString(),
        ProductFields.erpId: erpId,
        ProductFields.reference: reference,
        ProductFields.designation: designation,
        ProductFields.barcode: barcode.join(','),
        ProductFields.unit: unit,
        ProductFields.alternativeUnit: alternativeUnit,
        ProductFields.conversionFactor: conversionFactor,
        ProductFields.isBatchTracked: isBatchTracked,
        ProductFields.isSerialNumberTracked: isSerialNumberTracked,
        ProductFields.usaMolho: usaMolho,
      };

  Product copy({
    Guid? id,
    int? appId,
    String? erpId,
    String? reference,
    String? designation,
    List<String>? barcode,
    String? unit,
    String? alternativeUnit,
    double? conversionFactor,
    bool? isBatchTracked,
    bool? isSerialNumberTracked,
    bool? usaMolho,
  }) =>
      Product(
        id: id ?? this.id,
        erpId: erpId ?? this.erpId,
        reference: reference ?? this.reference,
        designation: designation ?? this.designation,
        barcode: barcode ?? this.barcode,
        unit: unit ?? this.unit,
        alternativeUnit: alternativeUnit ?? this.alternativeUnit,
        conversionFactor: conversionFactor ?? this.conversionFactor,
        isBatchTracked: isBatchTracked ?? this.isBatchTracked,
        isSerialNumberTracked:
            isSerialNumberTracked ?? this.isSerialNumberTracked,
        usaMolho: usaMolho ?? this.usaMolho,
      );
}

class ProductApi {
  List<Product> allProducts = [];

  static ProductApi instance = ProductApi._init();

  bool isInitialized = false;

  ProductApi._init() {
    if (!isInitialized) {
      isInitialized = true;
      initialize();
    }
  }

  Future<void> initialize() async {
    allProducts = await syncAllProducts();
  }

  Future<List<Product>> syncAllProducts() async {
    return fetchFromApi();
  }

  static Future<List<Product>> fetchFromApi() async {
    List<Product> productList = [];
    final DateTime lastSyncDate =
        System.instance.apiConnection!.lastConnection ?? DateTime(1900);
    final String getUrl = ApiEndPoint.getAllProducts(lastSyncDate);

    final NetworkHelper networkHelper = NetworkHelper(getUrl);
    final http.Response response =
        await networkHelper.getData(seconds: 120) as http.Response;

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      final Iterable l = jsonBody['result'] as Iterable;

      productList = List<Product>.from(
        l.map((model) => Product.fromJsonAPI(model as Map<String, dynamic>)),
      );
    }
    return productList;
  }
}

mixin ProductHelper {
  static Product? getProduct({String reference = '', String barcode = ''}) {
    Product? product;
    if (reference.isNotEmpty) {
      product = ProductApi.instance.allProducts.firstWhereOrNull(
        (element) => element.reference.trim() == reference.trim(),
      );
      product ??= ProductApi.instance.allProducts.firstWhereOrNull(
        (element) => element.barcode.contains(reference.trim()),
      );
      product ??= ProductApi.instance.allProducts.firstWhereOrNull(
        (element) => element.barcode.contains(barcode.trim()),
      );
    } else if (barcode.isNotEmpty) {
      product = ProductApi.instance.allProducts.firstWhereOrNull(
        (element) => element.barcode.contains(barcode.trim()),
      );
    }
    return product;
  }
}
