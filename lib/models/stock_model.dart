import 'package:flutter_guid/flutter_guid.dart';
import 'package:n6picking_flutterapp/models/batch_model.dart';
import 'package:n6picking_flutterapp/models/product_model.dart';

mixin StockFields {
  static final List<String> allValues = [
    product,
    batch,
    locationId,
    quantity,
  ];

  static const String product = 'product';
  static const String batch = 'batch';
  static const String locationId = 'locationId';
  static const String quantity = 'quantity';
}

class Stock {
  Product product;
  Batch batch;
  Guid locationId;
  double quantity;

  Stock({
    required this.product,
    required this.batch,
    required this.locationId,
    required this.quantity,
  });

  factory Stock.fromJson(Map<String, dynamic> json) => Stock(
        product: Product.fromJsonAPI(
          json[StockFields.product] as Map<String, dynamic>,
        ),
        batch: Batch.fromJson(json[StockFields.batch] as Map<String, dynamic>),
        locationId: Guid(json[StockFields.locationId] as String),
        quantity: json[StockFields.quantity] as double,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        StockFields.product: product.toJsonAPI(),
        StockFields.batch: batch.toJson(),
        StockFields.locationId: locationId.toString(),
        StockFields.quantity: quantity,
      };
}
