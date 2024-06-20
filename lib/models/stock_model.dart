import 'dart:convert';

import 'package:flutter_guid/flutter_guid.dart';
import 'package:http/http.dart' as http;
import 'package:n6picking_flutterapp/models/batch_model.dart';
import 'package:n6picking_flutterapp/models/location_model.dart';
import 'package:n6picking_flutterapp/models/product_model.dart';
import 'package:n6picking_flutterapp/services/api_endpoint.dart';
import 'package:n6picking_flutterapp/services/networking.dart';

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
  Batch? batch;
  Guid locationId;
  double quantity;

  Stock({
    required this.product,
    this.batch,
    required this.locationId,
    required this.quantity,
  });

  factory Stock.fromJson(Map<String, dynamic> json) => Stock(
        product: Product.fromJson(
          json[StockFields.product] as Map<String, dynamic>,
        ),
        batch: json[StockFields.batch] != null
            ? Batch.fromJson(json[StockFields.batch] as Map<String, dynamic>)
            : null,
        locationId: Guid(json[StockFields.locationId] as String),
        quantity: json[StockFields.quantity] as double,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        StockFields.product: product.toJson(),
        StockFields.batch: batch?.toJson(),
        StockFields.locationId: locationId.toString(),
        StockFields.quantity: quantity,
      };

  Stock copy({
    Product? product,
    Batch? batch,
    Guid? locationId,
    double? quantity,
  }) =>
      Stock(
        product: product ?? this.product,
        batch: batch ?? this.batch,
        locationId: locationId ?? this.locationId,
        quantity: quantity ?? this.quantity,
      );
}

mixin StockApi {
  static Future<List<Stock>> getByLocation(Location location) async {
    List<Stock> stockList = [];
    final String url = ApiEndPoint.getStockByLocation(location.erpId);
    final NetworkHelper networkHelper = NetworkHelper(url);
    final http.Response response =
        await networkHelper.getData(seconds: 10) as http.Response;

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      if (jsonBody['result'] != null) {
        final Iterable l = jsonBody['result'] as Iterable;

        stockList = List<Stock>.from(
          l.map((model) => Stock.fromJson(model as Map<String, dynamic>)),
        );

        //replace the stock locationId with the location Id
        for (final Stock stock in stockList) {
          stock.locationId = location.id;
        }
      }
    }

    return stockList;
  }
}
