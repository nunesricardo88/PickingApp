import 'package:flutter_guid/flutter_guid.dart';

const String tableProductBarcode = 'product_barcode';

mixin ProductBarcodeFields {
  static final List<String> allValues = [
    id,
    erpId,
    productId,
    productErpId,
    code,
    quantity,
  ];

  static const String id = 'id';
  static const String erpId = 'erpId';
  static const String productId = 'productId';
  static const String productErpId = 'productErpId';
  static const String code = 'code';
  static const String quantity = 'quantity';
}

class ProductBarcode {
  Guid id;
  String erpId;
  Guid productId;
  String productErpId;
  String code;
  double quantity;

  ProductBarcode({
    required this.id,
    required this.erpId,
    required this.productId,
    required this.productErpId,
    required this.code,
    required this.quantity,
  });

  factory ProductBarcode.fromJson(Map<String, dynamic> json) => ProductBarcode(
        id: Guid(json[ProductBarcodeFields.id] as String),
        erpId: json[ProductBarcodeFields.erpId] as String,
        productId: Guid(json[ProductBarcodeFields.productId] as String),
        productErpId: json[ProductBarcodeFields.productErpId] as String,
        code: json[ProductBarcodeFields.code] as String,
        quantity: json[ProductBarcodeFields.quantity] as double,
      );

  Map<String, dynamic> toJson() => {
        ProductBarcodeFields.id: id.toString(),
        ProductBarcodeFields.erpId: erpId,
        ProductBarcodeFields.productId: productId.toString(),
        ProductBarcodeFields.productErpId: productErpId,
        ProductBarcodeFields.code: code,
        ProductBarcodeFields.quantity: quantity,
      };

  ProductBarcode copy({
    Guid? id,
    int? appId,
    String? erpId,
    Guid? productId,
    String? productErpId,
    String? code,
    double? quantity,
  }) =>
      ProductBarcode(
        id: id ?? this.id,
        erpId: erpId ?? this.erpId,
        productId: productId ?? this.productId,
        productErpId: productErpId ?? this.productErpId,
        code: code ?? this.code,
        quantity: quantity ?? this.quantity,
      );
}
