import 'package:flutter/material.dart';
import 'package:n6picking_flutterapp/models/stock_model.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:n6picking_flutterapp/utilities/helper.dart';

class StockTile extends StatefulWidget {
  final Stock stock;
  final bool startsSelected;
  final Function(Stock, double) onStockChanged;

  const StockTile({
    required this.stock,
    required this.startsSelected,
    required this.onStockChanged,
  });

  @override
  _StockTileState createState() => _StockTileState();
}

class _StockTileState extends State<StockTile> {
  bool alreadyValidated = false;
  bool isExiting = false;
  bool showSpinner = false;

  TextEditingController quantityController = TextEditingController();
  late bool _isValid;

  late double _quantity;
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.startsSelected;
    _quantity = widget.startsSelected ? widget.stock.quantity : 0.0;
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  void _onQuantityChanged(double quantity) {
    setState(() {
      _quantity = quantity;
    });

    widget.onStockChanged(widget.stock, _quantity);
  }

  void _onStockSelected() {
    bool isSelected;
    double quantity;

    isSelected = !_isSelected;

    if (isSelected) {
      quantity = widget.stock.quantity;
    } else {
      quantity = 0.0;
    }
    setState(() {
      _isSelected = isSelected;
      _quantity = quantity;
    });

    widget.onStockChanged(widget.stock, _quantity);
  }

  Future<void> validate() async {
    await isDataValid();
  }

  Future<void> isDataValid() async {
    setState(() {
      showSpinner = true;
    });

    bool isValid = true;

    //Check if the quantity is not empty
    if (quantityController.text.trim().isEmpty ||
        double.parse(quantityController.text) == 0) {
      isValid = false;
    } else {
      if (double.parse(quantityController.text) > widget.stock.quantity) {
        isValid = false;
      }
    }

    setState(() {
      showSpinner = false;
    });

    if (isExiting) {
      return;
    }
    setState(() {
      alreadyValidated = true;
      _isValid = isValid;
      if (isValid) {
        _quantity = double.parse(quantityController.text);
      }
    });
  }

  Future<void> _changeQuantity() async {
    if (!_isSelected) {
      _onStockSelected();
    }

    quantityController.text = _quantity.toStringAsFixed(2);

    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: kWhiteBackground,
          actionsPadding: const EdgeInsets.only(
            right: 10.0,
            bottom: 5.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          contentPadding: const EdgeInsets.only(
            top: 20.0,
            left: 20.0,
            right: 20.0,
            bottom: 5.0,
          ),
          content: SingleChildScrollView(
            child: isExiting
                ? const SizedBox(height: 100.0)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.stock.product.designation,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 20.0),
                      Column(
                        children: [
                          TextField(
                            autofocus: quantityController.text.isEmpty,
                            onTap: () {
                              quantityController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: quantityController.text.length,
                              );
                            },
                            controller: quantityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Quantidade',
                              labelStyle:
                                  Theme.of(context).textTheme.labelMedium,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              suffix: Text(
                                widget.stock.product.unit,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          actions: [
            MaterialButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancelar',
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: kPrimaryColor.withOpacity(0.8),
                    ),
              ),
            ),
            MaterialButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                await validate();
                if (!_isValid) {
                  return;
                }
                Navigator.pop(context);
                _onQuantityChanged(_quantity);
              },
              child: showSpinner
                  ? const SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(kPrimaryColor),
                      ),
                    )
                  : Text(
                      'Submeter',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 7.5),
      child: Material(
        color: kWhiteBackground,
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: MaterialButton(
          padding: EdgeInsets.zero,
          color: kWhiteBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          highlightColor: kPrimaryColorLight.withOpacity(0.5),
          onPressed: _onStockSelected,
          child: Card(
            color: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Row(
                children: [
                  Checkbox(
                    value: _isSelected,
                    onChanged: (value) {
                      _onStockSelected();
                    },
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                widget.stock.product.designation,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                widget.stock.product.reference,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Visibility(
                                visible: widget.stock.product.isBatchTracked,
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 5.0,
                                    ),
                                    Text(
                                      'Lote: ${widget.stock.batch}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Stock: ${Helper.removeDecimalZeroFormat(widget.stock.quantity)} ${widget.stock.product.unit}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        GestureDetector(
                          onTap: _changeQuantity,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${Helper.removeDecimalZeroFormat(_quantity)} ${widget.stock.product.unit}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
