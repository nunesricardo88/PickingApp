import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:n6picking_flutterapp/models/batch_model.dart';
import 'package:n6picking_flutterapp/models/location_model.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';
import 'package:n6picking_flutterapp/models/product_model.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:n6picking_flutterapp/utilities/helper.dart';
import 'package:provider/provider.dart';

abstract class DocumentLineTile extends StatefulWidget {
  const DocumentLineTile({super.key});
}

abstract class DocumentLineTileState<T extends DocumentLineTile>
    extends State<T> {
  @override
  void initState() {
    super.initState();
    setupData();
  }

  void setupData() {}

  Color getTileBackgroundColor(
    double quantity,
    double quantityPicked,
    double totalQuantity,
    bool haveLinkedLineErpId,
  ) {
    final pickingTask = Provider.of<PickingTask>(context, listen: false);

    final bool hasOrigin = haveLinkedLineErpId;
    final bool isSatisfied = quantityPicked == totalQuantity;
    final bool isEmpty = quantityPicked == 0.0;
    final bool isPartial =
        quantityPicked > 0.0 && quantityPicked < totalQuantity;
    final bool isOverPicked = quantityPicked > totalQuantity;

    switch (pickingTask.stockMovement) {
      case StockMovement.none:
        return kWhiteBackground;
      case StockMovement.inbound:
        if (!hasOrigin) {
          return kWhiteBackground;
        }
        if (isSatisfied) {
          return kDocumentLineSatisfied;
        }
        if (isEmpty) {
          return kWhiteBackground;
        }
        if (isPartial) {
          return kDocumentLinePartial;
        }
        if (isOverPicked) {
          return kDocumentLineSatisfied;
        }

        return kWhiteBackground;
      case StockMovement.outbound:
        if (!hasOrigin) {
          return kWhiteBackground;
        }
        if (isSatisfied) {
          return kDocumentLineSatisfied;
        }
        if (isEmpty) {
          return kWhiteBackground;
        }
        if (isPartial) {
          return kDocumentLinePartial;
        }
        if (isOverPicked) {
          return kDocumentLineOverPicked;
        }
        return kWhiteBackground;
      case StockMovement.transfer:
        if (!hasOrigin) {
          return kWhiteBackground;
        }
        if (isSatisfied) {
          return kDocumentLineSatisfied;
        }
        if (isEmpty) {
          return kWhiteBackground;
        }
        if (isPartial) {
          return kDocumentLinePartial;
        }
        if (isOverPicked) {
          return kDocumentLineOverPicked;
        }
        return kWhiteBackground;
      case StockMovement.inventory:
        if (quantity == totalQuantity) {
          return kInactiveColor;
        }
        return kWhiteBackground;
      default:
        return kWhiteBackground;
    }
  }
}

class DocumentLineTileCard extends StatelessWidget {
  const DocumentLineTileCard({
    super.key,
    required this.designation,
    required this.reference,
    required this.originLocation,
    required this.quantity,
    required this.unit,
    required this.haveLinkedLineErpId,
    required this.quantityPicked,
    required this.totalQuantity,
    required this.product,
    required this.batch,
    required this.backgroundColor,
    this.onPressed,
  });

  final String designation;
  final String reference;
  final Location? originLocation;

  final double quantity;
  final String unit;
  final bool haveLinkedLineErpId;
  final double quantityPicked;
  final double totalQuantity;

  final Product? product;
  final Batch? batch;

  final Color backgroundColor;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.5),
      child: Material(
        color: backgroundColor,
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: MaterialButton(
          padding: EdgeInsets.zero,
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          highlightColor: kPrimaryColorLight.withOpacity(0.5),
          onPressed: onPressed,
          child: Card(
            color: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GroupInfoWidget(
                    designation: designation,
                    reference: reference,
                    originLocation: originLocation,
                    quantity: quantity,
                    product: product,
                    batch: batch,
                  ),
                  const SizedBox(width: 5.0),
                  QuantityInfoWidget(
                    quantity: quantity,
                    unit: unit,
                    haveLinkedLineErpId: haveLinkedLineErpId,
                    quantityPicked: quantityPicked,
                    totalQuantity: totalQuantity,
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

class GroupInfoWidget extends StatefulWidget {
  const GroupInfoWidget({
    super.key,
    required this.designation,
    required this.reference,
    required this.originLocation,
    required this.quantity,
    required this.product,
    required this.batch,
  });

  final String designation;
  final String reference;
  final Location? originLocation;
  final double quantity;
  final Product? product;
  final Batch? batch;

  @override
  _GroupInfoWidgetState createState() => _GroupInfoWidgetState();
}

class _GroupInfoWidgetState extends State<GroupInfoWidget> {
  Location? stockLocation;
  bool isExiting = false;

  @override
  void initState() {
    super.initState();
    fetchLocation();
  }

  @override
  void dispose() {
    isExiting = true;
    super.dispose();
  }

  Future<void> fetchLocation() async {
    final PickingTask pickingTask =
        Provider.of<PickingTask>(context, listen: false);

    //Get Stock Location
    Location? newStockLocation;
    if (pickingTask.stockMovement == StockMovement.transfer) {
      if (widget.originLocation == null && widget.product != null) {
        newStockLocation = await LocationApi.getLocationByProductWithStock(
          widget.product!,
          widget.batch,
        );
      } else {
        newStockLocation = null;
      }
    }

    if (!isExiting) {
      setState(() {
        stockLocation = newStockLocation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final PickingTask pickingTask = context.watch<PickingTask>();
    final bool isTransfer = pickingTask.stockMovement == StockMovement.transfer;

    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.designation,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 5.0),
          Text(
            widget.reference,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (widget.product != null && widget.product!.isBatchTracked)
            const SizedBox(height: 5.0),
          if (widget.product != null &&
              widget.product!.isBatchTracked &&
              widget.quantity > 0)
            Opacity(
              opacity: widget.batch == null ? 0.8 : 0.5,
              child: Text(
                widget.batch == null
                    ? 'Lote: Não definido'
                    : 'Lote: ${widget.batch?.batchNumber}',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.w700,
                      color:
                          widget.batch == null ? Colors.red : kPrimaryColorDark,
                    ),
              ),
            ),
          if (isTransfer) const SizedBox(height: 5.0),
          if (isTransfer)
            Opacity(
              opacity: 0.5,
              child: Column(
                children: [
                  if (widget.originLocation == null)
                    Row(
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.warehouse,
                          size: 10.0,
                          color: kPrimaryColor,
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          stockLocation != null
                              ? 'Sugestão: ${stockLocation?.name}'
                              : '(Sem stock)',
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontWeight: FontWeight.w400,
                                    color: kPrimaryColorDark,
                                  ),
                        ),
                      ],
                    ),
                  if (widget.originLocation != null)
                    Row(
                      children: [
                        const Stack(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.warehouse,
                              size: 10.0,
                              color: kOutboundStockMovement,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 15.0,
                              ),
                              child: FaIcon(
                                FontAwesomeIcons.arrowRight,
                                size: 10.0,
                                color: kOutboundStockMovement,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          '${widget.originLocation != null ? widget.originLocation?.name : '(Sem origem)'}',
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontWeight: FontWeight.w400,
                                    color: kPrimaryColorDark,
                                  ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class QuantityInfoWidget extends StatelessWidget {
  const QuantityInfoWidget({
    super.key,
    required this.quantity,
    required this.unit,
    required this.haveLinkedLineErpId,
    required this.quantityPicked,
    required this.totalQuantity,
  });

  final double quantity;
  final String unit;
  final bool haveLinkedLineErpId;
  final double quantityPicked;
  final double totalQuantity;

  @override
  Widget build(BuildContext context) {
    final PickingTask pickingTask = context.watch<PickingTask>();

    return Column(
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${Helper.removeDecimalZeroFormat(quantity)} $unit',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (pickingTask.stockMovement != StockMovement.inventory &&
                    haveLinkedLineErpId)
                  Row(
                    children: [
                      Text(
                        Helper.removeDecimalZeroFormat(
                          quantityPicked,
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        ' / ${Helper.removeDecimalZeroFormat(totalQuantity)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
