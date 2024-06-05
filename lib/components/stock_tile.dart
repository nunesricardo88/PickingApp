import 'package:flutter/material.dart';
import 'package:n6picking_flutterapp/models/stock_model.dart';

class StockTile extends StatefulWidget {
  final Stock stock;
  final Function onStockSelected;

  const StockTile({required this.stock, required this.onStockSelected});

  @override
  _StockTileState createState() => _StockTileState();
}

class _StockTileState extends State<StockTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
