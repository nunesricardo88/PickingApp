import 'package:n6picking_flutterapp/models/batch_model.dart';
import 'package:n6picking_flutterapp/models/product_model.dart';

mixin StockFields {
  static final List<String> allValues = [
    product,
    batch,
    quantity,
  ];

  static const String product = 'product';
  static const String batch = 'batch';
  static const String quantity = 'quantity';
}

class Stock {
  Product product;
  Batch batch;
  double quantity;

  Stock({
    required this.product,
    required this.batch,
    required this.quantity,
  });
}
