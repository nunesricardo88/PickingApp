import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:n6picking_flutterapp/models/document_line_model.dart';
import 'package:n6picking_flutterapp/models/document_model.dart';
import 'package:n6picking_flutterapp/models/location_model.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:n6picking_flutterapp/utilities/helper.dart';
import 'package:provider/provider.dart';

class DocumentLineTile extends StatefulWidget {
  final DocumentLine documentLine;
  final Location? location;
  final Function(
    DocumentLine,
    Location? location,
  ) callDocumentLineScreen;
  const DocumentLineTile({
    required this.documentLine,
    this.location,
    required this.callDocumentLineScreen,
  });

  @override
  _DocumentLineTileState createState() => _DocumentLineTileState();
}

class _DocumentLineTileState extends State<DocumentLineTile> {
  GlobalKey containerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  Color getTileBackgroundColor() {
    final pickingTask = Provider.of<PickingTask>(context, listen: false);
    if (pickingTask.stockMovement == StockMovement.inventory) {
      if (widget.documentLine.quantity == widget.documentLine.totalQuantity) {
        return kInactiveColor;
      }
    }
    return kWhiteBackground;
  }

  void fetchData() {
    final PickingTask pickingTask =
        Provider.of<PickingTask>(context, listen: false);

    //Quantities
    DocumentLine? sourceDocumentLine;
    double quantityPicked = 0.0;
    if (widget.documentLine.linkedLineErpId != null &&
        widget.documentLine.linkedLineErpId!.trim().isNotEmpty) {
      // Get SourceDocumentLine
      for (final Document sourceDocument in pickingTask.sourceDocuments) {
        for (final DocumentLine documentLine in sourceDocument.lines) {
          if (documentLine.erpId!.trim() ==
              widget.documentLine.linkedLineErpId!.trim()) {
            sourceDocumentLine = documentLine;
            quantityPicked = documentLine.quantityPicked;
            break;
          }
        }
      }

      if (sourceDocumentLine != null) {
        final double totalQuantity = sourceDocumentLine.totalQuantity;
        final double quantityToPick = sourceDocumentLine.quantityToPick;

        //Get quantityPicked from all documentLines with the same linkedLineErpId
        for (final DocumentLine documentLine in pickingTask.document!.lines) {
          if (documentLine.linkedLineErpId != null &&
              documentLine.linkedLineErpId!.trim().isNotEmpty &&
              documentLine.linkedLineErpId!.trim() ==
                  widget.documentLine.linkedLineErpId!.trim()) {
            quantityPicked += documentLine.quantity;
          }
        }

        //Update Quantities
        widget.documentLine.quantityPicked = quantityPicked;
        widget.documentLine.totalQuantity = totalQuantity;
        widget.documentLine.quantityToPick = quantityToPick;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final PickingTask pickingTask = context.watch<PickingTask>();
    fetchData();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.5),
      child: Material(
        color: getTileBackgroundColor(),
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: MaterialButton(
          padding: EdgeInsets.zero,
          color: getTileBackgroundColor(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          highlightColor: kPrimaryColorLight.withOpacity(0.5),
          onPressed: () {
            widget.callDocumentLineScreen(
              widget.documentLine,
              widget.location,
            );
          },
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          widget.documentLine.product.designation,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          widget.documentLine.product.reference,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (widget.documentLine.product.isBatchTracked)
                          const SizedBox(
                            height: 5.0,
                          ),
                        if (widget.documentLine.product.isBatchTracked &&
                            widget.documentLine.quantity > 0)
                          Opacity(
                            opacity:
                                widget.documentLine.batch == null ? 0.8 : 0.5,
                            child: Text(
                              widget.documentLine.batch == null
                                  ? 'Lote: Não definido'
                                  : 'Lote: ${widget.documentLine.batch?.batchNumber}',
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: widget.documentLine.batch == null
                                        ? Colors.red
                                        : kPrimaryColorDark,
                                  ),
                            ),
                          ),
                        if (widget.documentLine.destinationLocation != null)
                          const SizedBox(
                            height: 5.0,
                          ),
                        if (widget.documentLine.destinationLocation != null)
                          Opacity(
                            opacity:
                                widget.documentLine.destinationLocation == null
                                    ? 0.8
                                    : 0.5,
                            child: Row(
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.warehouse,
                                  size: 10.0,
                                  color: kPrimaryColorDark,
                                ),
                                const SizedBox(
                                  width: 5.0,
                                ),
                                Text(
                                  '${widget.documentLine.destinationLocation?.name}',
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        fontWeight: FontWeight.w400,
                                        color: kPrimaryColorDark,
                                      ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${Helper.removeDecimalZeroFormat(widget.documentLine.quantity)} ${widget.documentLine.product.unit}',
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                          if (pickingTask.stockMovement !=
                                  StockMovement.inventory &&
                              widget.documentLine.linkedLineErpId != null &&
                              widget.documentLine.linkedLineErpId!
                                  .trim()
                                  .isNotEmpty)
                            Row(
                              children: [
                                Text(
                                  Helper.removeDecimalZeroFormat(
                                    widget.documentLine.quantityPicked,
                                  ),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  ' / ${Helper.removeDecimalZeroFormat(widget.documentLine.totalQuantity)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
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
