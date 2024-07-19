import 'package:flutter/material.dart';
import 'package:n6picking_flutterapp/components/document_line_tile.dart';
import 'package:n6picking_flutterapp/models/document_line_model.dart';
import 'package:n6picking_flutterapp/models/document_model.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:provider/provider.dart';

class GroupDocumentLineTile extends DocumentLineTile {
  final String groupName;
  final List<DocumentLine> documentLines;
  final LineGroupType lineGroupType;

  const GroupDocumentLineTile({
    super.key,
    required this.groupName,
    required this.documentLines,
    required this.lineGroupType,
  });

  @override
  _GroupDocumentLineTileState createState() => _GroupDocumentLineTileState();
}

class _GroupDocumentLineTileState
    extends DocumentLineTileState<GroupDocumentLineTile> {
  String? batchNumber;
  double quantity = 0;
  double quantityPicked = 0;
  double totalQuantity = 0;
  bool haveLinkedLineErpId = false;

  @override
  void didUpdateWidget(covariant GroupDocumentLineTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lineGroupType != oldWidget.lineGroupType ||
        widget.documentLines != oldWidget.documentLines) {
      setupData();
    }
  }

  @override
  void setupData() {
    double cQuantity = 0;
    double cQuantityPicked = 0;
    double cTotalQuantity = 0;
    bool haveLinkedLineErpId = false;

    final PickingTask pickingTask =
        Provider.of<PickingTask>(context, listen: false);
    bool addContainer = true;

    for (final DocumentLine line in widget.documentLines) {
      //Quantities
      DocumentLine? sourceDocumentLine;
      double quantityPicked = 0.0;
      if (line.linkedLineErpId != null &&
          line.linkedLineErpId!.trim().isNotEmpty) {
        // Get SourceDocumentLine
        for (final Document sourceDocument in pickingTask.sourceDocuments) {
          for (final DocumentLine documentLine in sourceDocument.lines) {
            if (documentLine.erpId!.trim() == line.linkedLineErpId!.trim()) {
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
                    line.linkedLineErpId!.trim()) {
              quantityPicked += documentLine.quantity;
            }
          }

          //Update Quantities
          line.quantityPicked = quantityPicked;
          line.totalQuantity = totalQuantity;
          line.quantityToPick = quantityToPick;
        }
      }

      // Only can sum the first line with an associated container
      final bool canSumLine =
          line.container == null || (addContainer && line.container != null);
      if (canSumLine) {
        cQuantityPicked += line.quantityPicked;
        cTotalQuantity += line.totalQuantity;

        if (addContainer && line.container != null) {
          addContainer = false;
        }
      }

      cQuantity += line.quantity;
      haveLinkedLineErpId |= line.linkedLineErpId != null &&
          line.linkedLineErpId!.trim().isNotEmpty;
    }

    if (widget.lineGroupType == LineGroupType.productBatch) {
      setState(() {
        batchNumber = widget.documentLines.first.batch?.batchNumber;
      });
    }

    setState(() {
      quantity = cQuantity;
      quantityPicked = cQuantityPicked;
      totalQuantity = cTotalQuantity;
      this.haveLinkedLineErpId = haveLinkedLineErpId;
    });
  }

  String _getDesignation() {
    switch (widget.lineGroupType) {
      case LineGroupType.product:
        return widget.documentLines.first.product.designation;
      case LineGroupType.productBatch:
        return widget.documentLines.first.product.designation;
      case LineGroupType.container:
        return widget.documentLines.first.container?.barcode ?? 'Sem container';
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return DocumentLineTileCard(
      designation: _getDesignation(),
      reference: widget.groupName,
      originLocation: widget.documentLines.first.originLocation,
      quantity: quantity,
      unit: widget.documentLines.first.product.unit,
      haveLinkedLineErpId: haveLinkedLineErpId,
      quantityPicked: quantityPicked,
      totalQuantity: totalQuantity,
      product: widget.documentLines.first.product,
      batch: widget.documentLines.first.batch,
      backgroundColor: getTileBackgroundColor(
        quantity,
        quantityPicked,
        totalQuantity,
        haveLinkedLineErpId,
      ),
    );
  }
}
