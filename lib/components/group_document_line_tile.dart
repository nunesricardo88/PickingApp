import 'package:flutter/material.dart';
import 'package:n6picking_flutterapp/models/document_line_model.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:n6picking_flutterapp/utilities/helper.dart';
import 'package:provider/provider.dart';

class GroupDocumentLineTile extends StatefulWidget {
  final String groupName;
  final List<DocumentLine> documentLines;
  final LineGroupType lineGroupType;

  const GroupDocumentLineTile({
    required this.groupName,
    required this.documentLines,
    required this.lineGroupType,
  });

  @override
  _GroupDocumentLineTileState createState() => _GroupDocumentLineTileState();
}

class _GroupDocumentLineTileState extends State<GroupDocumentLineTile> {
  bool isExiting = false;

  String? batchNumber;
  double quantity = 0;
  double quantityPicked = 0;
  double totalQuantity = 0;
  String unit = "";
  bool haveLinkedLineErpId = false;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  @override
  void didUpdateWidget(covariant GroupDocumentLineTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lineGroupType != oldWidget.lineGroupType ||
        widget.documentLines != oldWidget.documentLines) {
      _setup();
    }
  }

  void _setup() {
    double quantity = 0;
    double quantityPicked = 0;
    double totalQuantity = 0;
    bool haveLinkedLineErpId = false;

    for (final DocumentLine line in widget.documentLines) {
      quantity += line.quantity;
      quantityPicked += line.quantityPicked;
      totalQuantity += line.totalQuantity;
      haveLinkedLineErpId |= line.linkedLineErpId != null &&
          line.linkedLineErpId!.trim().isNotEmpty;
    }

    if (widget.lineGroupType == LineGroupType.productBatch) {
      setState(() {
        batchNumber = widget.documentLines.first.batch?.batchNumber;
      });
    }

    setState(() {
      this.quantity = quantity;
      this.quantityPicked = quantityPicked;
      this.totalQuantity = totalQuantity;
      this.haveLinkedLineErpId = haveLinkedLineErpId;
      unit = widget.documentLines.first.product.unit;
    });
  }

  @override
  void dispose() {
    isExiting = true;
    super.dispose();
  }

  Color _getTileBackgroundColor() {
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

  @override
  Widget build(BuildContext context) {
    final PickingTask pickingTask = context.watch<PickingTask>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.5),
      child: Material(
        color: _getTileBackgroundColor(),
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: MaterialButton(
          padding: EdgeInsets.zero,
          color: _getTileBackgroundColor(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          highlightColor: kPrimaryColorLight.withOpacity(0.5),
          onPressed: () {
            // Handle onPressed logic here
          },
          child: _buildCardContent(pickingTask),
        ),
      ),
    );
  }

  Widget _buildCardContent(PickingTask pickingTask) {
    return Card(
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildGroupInfo(),
            const SizedBox(width: 5.0),
            _buildQuantityInfo(pickingTask),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupInfo() {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.groupName,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 5.0),
          if (batchNumber != null)
            Text(
              batchNumber!,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Widget _buildQuantityInfo(PickingTask pickingTask) {
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
                        Helper.removeDecimalZeroFormat(quantityPicked),
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
