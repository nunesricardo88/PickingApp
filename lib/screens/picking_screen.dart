// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:n6picking_flutterapp/components/bottom_app_bar.dart';
import 'package:n6picking_flutterapp/components/document_line_dialog.dart';
import 'package:n6picking_flutterapp/components/document_line_tile.dart';
import 'package:n6picking_flutterapp/models/batch_model.dart';
import 'package:n6picking_flutterapp/models/document_line_model.dart';
import 'package:n6picking_flutterapp/models/document_model.dart';
import 'package:n6picking_flutterapp/models/location_model.dart';
import 'package:n6picking_flutterapp/models/misc_data_model.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';
import 'package:n6picking_flutterapp/models/product_model.dart';
import 'package:n6picking_flutterapp/screens/document_line_screen.dart';
import 'package:n6picking_flutterapp/screens/misc_data_screen.dart';
import 'package:n6picking_flutterapp/screens/source_documents_screen.dart';
import 'package:n6picking_flutterapp/screens/source_entity_screen.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:n6picking_flutterapp/utilities/helper.dart';
import 'package:n6picking_flutterapp/utilities/system.dart';
import 'package:n6picking_flutterapp/utilities/task_operation.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class PickingScreen extends StatefulWidget {
  static const String id = 'picking_screen_id';

  @override
  State<PickingScreen> createState() => _PickingScreenState();
}

class _PickingScreenState extends State<PickingScreen> {
  bool showSpinner = false;
  bool isSavingToServer = false;
  bool canPick = false;
  bool alreadyShowedPostOperationInput = false;
  DocumentLine? documentLineToScroll;

  //MiscData variables
  List<MiscData> miscDataList = [];
  bool _hasPreOperationInput = false;

  //Location variables
  //When the stock movement is not a Transfer, use only the destination location
  bool _useLocations = false;
  bool _canChangeOriginLocation = true;
  bool _canChangeDestinationLocation = true;
  bool _showOnlyOriginLocation = false;
  bool _showOnlyDestinationLocation = false;
  bool _showSingleLocation = false;
  bool _showBothLocations = false;
  bool _isPickingUp = true;
  bool _isDroppingOff = false;
  Location? _originLocation;
  Location? _destinationLocation;

  //Entity variables
  late bool _canChangeEntity;

  //TextControllers
  late TextEditingController _entityController;
  late TextEditingController _sourceDocumentsController;
  late TextEditingController _originLocationController;
  late TextEditingController _destinationLocationController;

  //ScrollControllers
  late ItemScrollController _listScrollController;

  //FutureBuilder DocumentLines
  List<Widget> documentLineTiles = [];
  Column documentTilesList = const Column();
  late Future<bool> listBuild;
  List<DocumentLine> documentLineList = [];

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  void dispose() {
    _entityController.dispose();
    _sourceDocumentsController.dispose();
    _originLocationController.dispose();
    _destinationLocationController.dispose();
    super.dispose();
  }

  Future<void> setup() async {
    final PickingTask pickingTask =
        Provider.of<PickingTask>(context, listen: false);

    _entityController = TextEditingController();
    _sourceDocumentsController = TextEditingController();
    _originLocationController = TextEditingController();
    _destinationLocationController = TextEditingController();
    _listScrollController = ItemScrollController();

    loadDefaultLocations();

    loadMiscData();

    await getDocumentLinesList();

    //Set default entity if EntityType is internal
    if (pickingTask.destinationDocumentType.entityType == EntityType.interno) {
      await pickingTask.setEntity(System.instance.selfEntity);
      setState(() {
        _entityController.text = getEntityName();
        _canChangeEntity = false;
      });
    } else {
      setState(() {
        _canChangeEntity = true;
      });
    }

    _destinationLocationController.text = getLocationName(_destinationLocation);
    _originLocationController.text = getLocationName(_originLocation);

    //Pre Operation Input
    if (_hasPreOperationInput) {
      final List<MiscData> miscDataPreOperationList =
          miscDataList.where((element) => element.preOperationInput).toList();
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MiscDataScreen(
            miscDataList: miscDataPreOperationList,
          ),
        ),
      ).then((value) async {
        if (value != null) {
          final List<MiscData> miscDataIncomingList = value as List<MiscData>;
          await _onMiscDataChanged(miscDataIncomingList);
        }
      });
    }

    allowPicking();
  }

  void loadDefaultLocations() {
    final PickingTask pickingTask = Provider.of<PickingTask>(
      context,
      listen: false,
    );

    bool useLocations = false;
    bool canChangeOriginLocation = true;
    bool canChangeDestinationLocation = true;
    bool showOnlyOriginLocation = false;
    bool showOnlyDestinationLocation = false;
    bool showSingleLocation = false;
    bool showBothLocations = false;
    bool isPickingUp = true;
    bool isDroppingOff = false;
    Location? fromLocation;
    Location? toLocation;

    final String customOptions = pickingTask.customOptions;
    if (customOptions.isNotEmpty) {
      final Map<String, dynamic> customOptionsJSON =
          jsonDecode(customOptions) as Map<String, dynamic>;

      if (customOptionsJSON.containsKey('LocationsOptions')) {
        final Map<String, dynamic> locationsOptionsJSON =
            customOptionsJSON['LocationsOptions'] as Map<String, dynamic>;

        if (locationsOptionsJSON.isNotEmpty) {
          useLocations = locationsOptionsJSON['UseLocations'] as bool;

          //Default Locations
          if (useLocations &&
              locationsOptionsJSON.containsKey('DefaultLocations')) {
            final List<dynamic> defaultLocationsJSON =
                locationsOptionsJSON['DefaultLocations'] as List<dynamic>;

            //cast List<dynamic> to Iterable<Map<String, dynamic>>
            final Iterable<Map<String, dynamic>> defaultLocationsIterable =
                defaultLocationsJSON.cast<Map<String, dynamic>>();

            for (final Map<String, dynamic> locationJSON
                in defaultLocationsIterable) {
              final String erpId = locationJSON['ErpId'] as String;
              final bool canBeChanged = locationJSON['CanBeChanged'] as bool;
              final String locationKind =
                  locationJSON['LocationKind'] as String;

              final Location? location = LocationApi.getByErpId(
                erpId,
                LocationApi.instance.allLocations,
              );

              if (location != null) {
                switch (locationKind) {
                  case 'Standard':
                    fromLocation = null;
                    toLocation = location;
                    canChangeOriginLocation = false;
                    canChangeDestinationLocation = canBeChanged;
                    showSingleLocation = true;
                    break;
                  case 'Origin':
                    fromLocation = location;
                    canChangeOriginLocation = canBeChanged;
                    break;
                  case 'Destination':
                    toLocation = location;
                    canChangeDestinationLocation = canBeChanged;
                    break;
                  default:
                    break;
                }
              }
            }
          }
        }
      }
    }

    //Handler if useLocations is false
    if (!useLocations) {
      fromLocation = null;
      toLocation = null;
      canChangeDestinationLocation = false;
      canChangeOriginLocation = false;
      showOnlyOriginLocation = false;
      showSingleLocation = false;
      showBothLocations = false;
    } else {
      if (pickingTask.stockMovement == StockMovement.transfer) {
        if (canChangeDestinationLocation && canChangeOriginLocation) {
          showBothLocations = true;
        } else {
          if (canChangeOriginLocation) {
            showOnlyOriginLocation = true;
            showSingleLocation = true;
          } else {
            showOnlyDestinationLocation = true;
            showSingleLocation = true;
          }
        }
      }
    }

    setState(() {
      _useLocations = useLocations;
      _canChangeOriginLocation = canChangeOriginLocation;
      _canChangeDestinationLocation = canChangeDestinationLocation;
      _originLocation = fromLocation;
      _destinationLocation = toLocation;
      _showOnlyOriginLocation = showOnlyOriginLocation;
      _showOnlyDestinationLocation = showOnlyDestinationLocation;
      _showSingleLocation = showSingleLocation;
      _showBothLocations = showBothLocations;
    });
  }

  void loadMiscData() {
    final PickingTask pickingTask = Provider.of<PickingTask>(
      context,
      listen: false,
    );

    final List<MiscData> miscData = MiscDataHelper.fromTask(pickingTask);

    final bool hasPreOperationInput = miscData.any(
      (element) => element.preOperationInput,
    );

    setState(() {
      _hasPreOperationInput = hasPreOperationInput;
      miscDataList = miscData;
    });
  }

  void allowPicking() {
    setState(() {
      canPick = true;
    });
  }

  void forbidPicking() {
    setState(() {
      canPick = false;
    });
  }

  void setToLocation(Location? location) {
    setState(() {
      _destinationLocation = location;
      _destinationLocationController.text =
          getLocationName(_destinationLocation);
    });
  }

  void setFromLocation(Location location) {
    setState(() {
      _originLocation = location;
      _originLocationController.text = getLocationName(_originLocation);
    });
  }

  String getLocationName(Location? location) {
    if (location == null) {
      return 'Sem localização';
    } else {
      return location.name;
    }
  }

  Future<void> getDocumentLinesList() async {
    listBuild = getDocumentLines();
  }

  Future<bool> getDocumentLines() async {
    documentLineTiles.clear();
    final PickingTask pickingTask =
        Provider.of<PickingTask>(context, listen: false);

    documentLineList = pickingTask.document!.lines;

    for (final DocumentLine documentLine in documentLineList) {
      documentLineTiles.add(
        Slidable(
          endActionPane: ActionPane(
            extentRatio: 0.15,
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                padding: const EdgeInsets.only(right: 10.0),
                backgroundColor: kGreyBackground,
                icon: FontAwesomeIcons.trashCan,
                foregroundColor: kPrimaryColorDark,
                onPressed: (BuildContext context) async {
                  setState(() => showSpinner = true);
                  await removeFromDocument(documentLine);
                  setState(() => showSpinner = false);
                },
              ),
            ],
          ),
          child: DocumentLineTile(
            documentLine: documentLine,
            location: _destinationLocation,
            callDocumentLineScreen: _onCallDocumentLineScreen,
          ),
        ),
      );
    }

    if (documentLineTiles.isNotEmpty) {
      documentLineTiles.add(
        const Row(
          children: [
            SizedBox(
              height: 25.0,
            ),
          ],
        ),
      );
    }

    documentTilesList = Column(
      children: documentLineTiles,
    );

    return true;
  }

  Future<void> _onCallDocumentLineScreen(
    DocumentLine documentLine,
    Location? location,
  ) async {
    setState(() {
      canPick = false;
      showSpinner = true;
      documentLineToScroll = null;
    });
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentLineScreen(
          documentLine: documentLine,
          location: location,
        ),
      ),
    ).then((value) async {
      if (value != null) {
        final List<double> batchData = value as List<double>;
        await _onSplitBatches(
          documentLine,
          batchData,
        );
      }
    });
    await getDocumentLinesList();
    setState(() {
      canPick = true;
      showSpinner = false;
    });
    _scrollToDocumentLine();
  }

  Future<void> _onSplitBatches(
    DocumentLine documentLine,
    List<double> batchData,
  ) async {
    await splitBatches(
      documentLine,
      batchData,
    );

    await getDocumentLinesList();
    _scrollToBottom();
    setState(() {});
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300)).then((value) {
      _listScrollController.scrollTo(
        index: documentLineTiles.length - 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _scrollToDocumentLine() {
    if (documentLineToScroll == null) {
      return;
    }
    bool alreadyScrolled = false;
    for (final Widget slidables in documentLineTiles) {
      if (!alreadyScrolled && slidables is Slidable) {
        if (slidables.child is DocumentLineTile) {
          final DocumentLineTile tile = slidables.child as DocumentLineTile;
          if (tile.documentLine.id == documentLineToScroll!.id) {
            final int index = documentLineTiles.indexOf(slidables);
            if (index >= documentLineTiles.length - 2) {
              alreadyScrolled = true;
              _scrollToBottom();
            } else {
              alreadyScrolled = true;
              Future.delayed(const Duration(milliseconds: 300)).then((value) {
                _listScrollController.scrollTo(
                  index: index,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              });
            }
          }
        }
      }
    }
  }

  // RRMP License
  Future<void> splitBatches(DocumentLine line, List<double> batchData) async {
    final double molhos = batchData[0];
    final double barras = batchData[1];
    final double comp = batchData[2];

    final PickingTask pickingTask =
        Provider.of<PickingTask>(context, listen: false);

    final List<Batch> newLines = await BatchApi.getSplitBatches(
      pickingTask.document!.entity!.number,
      line.product.reference,
      molhos,
      barras,
      comp,
    );

    //Increment the last 2 digits of the batch number if necessary
    String batchPrefix;
    String batchSuffix;
    int batchIndex;
    String lineBatchPrefix;
    String lineBatchSuffix;
    int lineBatchIndex;
    int maxLineBatchIndex;
    for (final Batch batch in newLines) {
      batchPrefix = batch.batchNumber.substring(
        0,
        batch.batchNumber.length - 2,
      );
      batchSuffix = batch.batchNumber.substring(
        batch.batchNumber.length - 2,
      );
      batchIndex = int.tryParse(batchSuffix) ?? 0;
      maxLineBatchIndex = -1;
      for (final DocumentLine documentLine in pickingTask.document!.lines) {
        if (documentLine.product.reference.trim() ==
                line.product.reference.trim() &&
            documentLine.batch != null &&
            documentLine.batch!.batchNumber.length > 2) {
          lineBatchPrefix = documentLine.batch!.batchNumber.substring(
            0,
            documentLine.batch!.batchNumber.length - 2,
          );
          lineBatchSuffix = documentLine.batch!.batchNumber.substring(
            documentLine.batch!.batchNumber.length - 2,
          );
          lineBatchIndex = int.tryParse(lineBatchSuffix) ?? 0;
          if (lineBatchPrefix == batchPrefix &&
              lineBatchIndex > maxLineBatchIndex) {
            maxLineBatchIndex = lineBatchIndex;
          }
        }
      }
      if (maxLineBatchIndex >= batchIndex) {
        batchIndex = maxLineBatchIndex + 1;
        batchSuffix = batchIndex.toString().padLeft(2, '0');
        batch.batchNumber = batchPrefix + batchSuffix;
      }
    }

    final DocumentLine oldDocumentLine = line.copyWith();

    //If the original line has no batch or quantity, remove it
    pickingTask.document!.lines.removeWhere(
      (element) =>
          element.id == line.id &&
          (element.batch == null || element.quantity == 0),
    );

    for (final Batch batch in newLines) {
      final double quantity = double.tryParse(batch.erpId!.trim()) ?? 0;

      addProduct(
        product: oldDocumentLine.product,
        destinationLocation: _destinationLocation,
        batch: batch,
        quantity: quantity,
      );

      final DocumentLine documentLine = pickingTask.document!.lines.last;
      documentLine.linkedLineErpId = oldDocumentLine.linkedLineErpId;
    }

    setState(() {});
  }

  Future<void> _onBarcodeScanned(String barcode) async {
    if (!canPick) {
      return;
    }
    setState(() {
      showSpinner = true;
      canPick = false;
    });

    documentLineToScroll = null;

    final TaskOperation taskOperation = await handleBarcode(barcode);

    if (!taskOperation.success) {
      Helper.showMsg(
        'Atenção',
        taskOperation.message,
        context,
      );
    } else {
      await getDocumentLinesList();
    }

    setState(() {
      showSpinner = false;
      canPick = true;
    });
    _scrollToDocumentLine();
  }

  Future<void> _onProductSelectedBottomBar(Product product) async {
    setState(() {
      showSpinner = true;
      canPick = false;
    });

    documentLineToScroll = null;

    final TaskOperation taskOperation = await addProduct(
      product: product,
      originLocation: _originLocation,
      destinationLocation: _destinationLocation,
    );

    if (!taskOperation.success) {
      Helper.showMsg(
        'Atenção',
        taskOperation.message,
        context,
      );
    } else {
      await getDocumentLinesList();
    }

    setState(() {
      showSpinner = false;
      canPick = true;
    });
    _scrollToDocumentLine();
  }

  Future<void> _onMiscDataChanged(List<MiscData> miscDataIncomingList) async {
    for (final MiscData miscData in miscDataIncomingList) {
      final int index = miscDataList.indexWhere(
        (element) => element.id == miscData.id,
      );
      if (index != -1) {
        miscDataList[index] = miscData;
      }
    }
  }

  Future<TaskOperation> handleBarcode(String barcode) async {
    final PickingTask pickingTask = Provider.of<PickingTask>(
      context,
      listen: false,
    );

    TaskOperation taskOperation = TaskOperation(
      success: true,
      errorCode: ErrorCode.none,
      message: '',
    );

    //Get barcode type
    final BarCodeType barCodeType = Helper.getBarCodeType(barcode);

    //Initialize variables
    final bool useOnlyCreatedBatches =
        pickingTask.stockMovement == StockMovement.outbound ||
            pickingTask.stockMovement == StockMovement.transfer;
    Product? product;
    Batch? batch;

    switch (barCodeType) {
      case BarCodeType.unknown:
        taskOperation = TaskOperation(
          success: false,
          errorCode: ErrorCode.invalidBarcode,
          message: 'Código de barras não é válido',
        );
        break;
      case BarCodeType.product:

        //Check if has location
        if (_useLocations) {}

        product = ProductHelper.getProduct(
          reference: barcode,
          barcode: barcode,
        );
        if (product == null) {
          taskOperation = TaskOperation(
            success: false,
            errorCode: ErrorCode.barcodeNotFound,
            message: 'Artigo não encontrado',
          );
        } else {
          taskOperation = await addProduct(
            product: product,
            originLocation: _originLocation,
            destinationLocation: _destinationLocation,
          );
        }
        break;
      case BarCodeType.batch:
        final Map<String, dynamic> json =
            jsonDecode(barcode) as Map<String, dynamic>;
        final String productRef = json['ref'] as String;
        final String batchNumber = json['lote'] as String;
        final String? barcodeQR = json['barcode'] as String?;

        product = ProductHelper.getProduct(
          reference: productRef,
          barcode: barcodeQR ?? '',
        );
        if (product == null) {
          taskOperation = TaskOperation(
            success: false,
            errorCode: ErrorCode.productNotFound,
            message: 'Artigo não encontrado',
          );
        } else {
          batch = await BatchApi.getByReferenceAndBatchNumber(
            productRef,
            batchNumber,
          );
          if (batch == null && useOnlyCreatedBatches) {
            taskOperation = TaskOperation(
              success: false,
              errorCode: ErrorCode.batchNotFound,
              message: 'Lote não encontrado',
            );
          } else {
            batch ??= Batch(
              id: Guid.newGuid,
              erpId: '',
              batchNumber: batchNumber,
              expirationDate: DateTime(1900),
              usaMolho: product.usaMolho,
            );
            taskOperation = await addProduct(
              product: product,
              batch: batch,
              originLocation: _originLocation,
              destinationLocation: _destinationLocation,
            );
          }
        }

        break;
      case BarCodeType.container:
        break;
      case BarCodeType.location:

        //Non Transfers
        if (pickingTask.stockMovement != StockMovement.transfer) {
          if (!_canChangeDestinationLocation) {
            taskOperation = TaskOperation(
              success: false,
              errorCode: ErrorCode.cannotChangeLocation,
              message: 'Localização não pode ser alterada',
            );
            break;
          }
        }

        //Transfers
        if (pickingTask.stockMovement == StockMovement.transfer) {
          if (!_canChangeDestinationLocation && !_canChangeOriginLocation) {
            taskOperation = TaskOperation(
              success: false,
              errorCode: ErrorCode.cannotChangeLocation,
              message: 'Localização não pode ser alterada',
            );
            break;
          }
        }

        final Location? location = LocationApi.getByErpId(
          barcode,
          LocationApi.instance.allLocations,
        );
        if (location == null) {
          taskOperation = TaskOperation(
            success: false,
            errorCode: ErrorCode.locationNotFound,
            message: 'Localização não encontrada',
          );
        } else {
          //Transfers
          if (pickingTask.stockMovement == StockMovement.transfer) {
            //Forced locations
            if (!_canChangeDestinationLocation && !_canChangeOriginLocation) {
              taskOperation = TaskOperation(
                success: false,
                errorCode: ErrorCode.cannotChangeLocation,
                message: 'Localização não pode ser alterada',
              );
              break;
            }
            if (!_canChangeDestinationLocation && _canChangeOriginLocation) {
              setFromLocation(location);
            }
            if (_canChangeDestinationLocation && !_canChangeOriginLocation) {
              setToLocation(location);
            }

            //Standard Transfer
            if (_canChangeDestinationLocation && _canChangeOriginLocation) {
              taskOperation = TaskOperation(
                success: false,
                errorCode: ErrorCode.inDevelopment,
                message: 'Esta funcionalidade ainda não foi implementada',
              );
              break;
            }
          } else {
            setToLocation(location);
          }
        }
        break;
      case BarCodeType.document:
        //delete the first two characters
        final String parsedBarcode = barcode.substring(2);
        final Document? document =
            await DocumentApi.getPendingFromBarcode(pickingTask, parsedBarcode);
        if (document == null) {
          taskOperation = TaskOperation(
            success: false,
            errorCode: ErrorCode.documentNotFound,
            message: 'Documento não encontrado',
          );
        } else {
          if (document.documentType.erpId !=
              pickingTask.originDocumentType!.erpId) {
            taskOperation = TaskOperation(
              success: false,
              errorCode: ErrorCode.documentNotSuitable,
              message: 'O documento não é adequado para esta tarefa',
            );
          } else {
            await pickingTask.setEntity(document.entity);
            final List<Document> documentList = [];
            documentList.add(document);
            await pickingTask.setSourceDocumentsFromList(documentList);
            taskOperation = TaskOperation(
              success: true,
              errorCode: ErrorCode.none,
              message: '',
            );

            setState(() {
              _entityController.text = getEntityName();
              _sourceDocumentsController.text = getSourceDocumentsName();
            });
          }
        }
        break;
    }

    return taskOperation;
  }

  Future<TaskOperation> addProduct({
    required Product product,
    Batch? batch,
    Location? originLocation,
    Location? destinationLocation,
    double quantity = 0,
  }) async {
    final PickingTask pickingTask = Provider.of<PickingTask>(
      context,
      listen: false,
    );

    bool gotQuantityFromDialog = false;

    //====CREATE A NEW DOCUMENT LINE====
    final DocumentLine documentLineToAdd =
        pickingTask.createDocumentLineByProduct(
      product: product,
      batch: batch,
    );
    documentLineToAdd.originLocation = originLocation;
    documentLineToAdd.destinationLocation = destinationLocation;

    //====GET THE BATCH AND QUANTITY====
    if (quantity == 0 || (batch == null && product.isBatchTracked)) {
      setState(() {
        showSpinner = false;
      });
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return DocumentLineDialog(
            documentLine: documentLineToAdd,
          );
        },
      );
      gotQuantityFromDialog = true;
      setState(() {
        showSpinner = true;
      });
    }

    //====GET THE CORRESPONDING DOCUMENT LINE====

    //Get a list of the document lines with the same product
    //and batch if applicable and location if applicable

    final List<DocumentLine> documentLinesWithSameProduct =
        pickingTask.document!.lines
            .where(
              (element) =>
                  element.product.reference.trim() ==
                  documentLineToAdd.product.reference.trim(),
            )
            .toList();

    final List<DocumentLine> documentLines = documentLinesWithSameProduct
        .where(
          (element) =>
              //Same product
              element.product.reference.trim() ==
                  documentLineToAdd.product.reference.trim() &&

              //Batch
              (
                  // Both not Batch tracked
                  (!product.isBatchTracked &&
                          element.batch == null &&
                          documentLineToAdd.batch == null)

                      // Batch tracked and same batch
                      ||
                      (product.isBatchTracked &&
                          documentLineToAdd.batch != null &&
                          element.batch != null &&
                          documentLineToAdd.batch!.batchNumber.trim() ==
                              element.batch!.batchNumber.trim())

                      // Both Batch tracked but element has no batch and documentLine has batch
                      ||
                      (product.isBatchTracked &&
                          documentLineToAdd.batch != null &&
                          element.batch == null)

                      // Both Batch tracked but neither have batch
                      ||
                      (product.isBatchTracked &&
                          documentLineToAdd.batch == null &&
                          element.batch == null)) &&
              //Location
              (
                  //Both without both locations
                  (documentLineToAdd.destinationLocation == null &&
                          element.destinationLocation == null &&
                          documentLineToAdd.originLocation == null &&
                          element.originLocation == null) ||

                      //Both in the same locations
                      (documentLineToAdd.destinationLocation != null &&
                          element.destinationLocation != null &&
                          documentLineToAdd.destinationLocation!.erpId ==
                              element.destinationLocation!.erpId &&
                          documentLineToAdd.originLocation != null &&
                          element.originLocation != null &&
                          documentLineToAdd.originLocation!.erpId ==
                              element.originLocation!.erpId) ||

                      //Element without locations and documentLine with locations
                      (documentLineToAdd.destinationLocation != null &&
                          element.destinationLocation == null &&
                          documentLineToAdd.originLocation != null &&
                          element.originLocation == null)),
        )
        .toList();

    //If there are no document lines with the same product,
    //add the new document line to the document
    //If not, use the first document line found to add the quantity
    //Give preference to the document line with the same batch and quantity < quantityPicked
    DocumentLine finalDocumentLine;
    double quantityToAdd;
    if (documentLines.isEmpty) {
      finalDocumentLine = documentLineToAdd;
      pickingTask.document!.lines.add(finalDocumentLine);
      quantityToAdd = gotQuantityFromDialog ? 0.0 : quantity;
      if (destinationLocation != null) {
        finalDocumentLine.destinationLocation = destinationLocation;
      }
    } else {
      finalDocumentLine = documentLines.firstWhereOrNull(
            (element) =>
                element.quantity + element.quantityPicked < element.quantity,
          ) ??
          documentLines.first;
      finalDocumentLine.batch = documentLineToAdd.batch;
      if (destinationLocation != null) {
        finalDocumentLine.destinationLocation = destinationLocation;
      }
      quantityToAdd = documentLineToAdd.quantity;
    }

    for (final DocumentLine documentLine in documentLines) {
      if (documentLine.id == finalDocumentLine.id) {
        documentLineToScroll = documentLine;
      }
    }
    documentLineToScroll ??= finalDocumentLine;

    return pickingTask.addToDocumentLineQuantity(
      finalDocumentLine,
      quantityToAdd,
    );
  }

  Future<TaskOperation> removeFromDocument(DocumentLine documentLine) async {
    final PickingTask pickingTask = Provider.of<PickingTask>(
      context,
      listen: false,
    );

    final TaskOperation taskOperation = pickingTask.addToDocumentLineQuantity(
      documentLine,
      -documentLine.quantity,
    );

    if (taskOperation.success) {
      documentLine.destinationLocation = null;
      documentLine.batch = null;
      await getDocumentLinesList();
    }

    return taskOperation;
  }

  Future<void> _onChangeEntity() async {
    forbidPicking();
    await Navigator.pushNamed(context, SourceEntityScreen.id);
    setState(() {
      _entityController.text = getEntityName();
      canPick = true;
    });
  }

  String getEntityName() {
    final PickingTask pickingTask =
        Provider.of<PickingTask>(context, listen: false);

    if (pickingTask.document!.entity == null) {
      return '';
    } else {
      return pickingTask.document!.entity!.name;
    }
  }

  Future<void> _onChangeSourceDocuments() async {
    forbidPicking();
    await Navigator.pushNamed(context, SourceDocumentsScreen.id);
    setState(() {
      _sourceDocumentsController.text = getSourceDocumentsName();
      canPick = true;
    });
    getDocumentLinesList();
  }

  String getSourceDocumentsName() {
    final PickingTask pickingTask =
        Provider.of<PickingTask>(context, listen: false);

    if (pickingTask.sourceDocuments.isEmpty) {
      return '';
    } else {
      if (pickingTask.sourceDocuments.length == 1) {
        if (pickingTask.stockMovement == StockMovement.inventory) {
          return pickingTask.sourceDocuments.first.name!;
        }
        final StringBuffer sb = StringBuffer();
        sb.write(pickingTask.sourceDocuments.first.documentType.name);
        sb.write(' nº ');
        sb.write(pickingTask.sourceDocuments.first.number.toString());
        return sb.toString();
      } else {
        final StringBuffer sb = StringBuffer();
        sb.write(pickingTask.sourceDocuments.first.documentType.name);
        sb.write(' (');
        for (int i = 0; i < pickingTask.sourceDocuments.length; i++) {
          sb.write(pickingTask.sourceDocuments[i].number.toString());
          if (i < pickingTask.sourceDocuments.length - 1) {
            sb.write(', ');
          }
        }
        sb.write(')');
        return sb.toString();
      }
    }
  }

  void exitPickingScreen() {
    final PickingTask pickingTask =
        Provider.of<PickingTask>(context, listen: false);
    pickingTask.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final PickingTask pickingTask = context.watch<PickingTask>();
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: kGreyBackground,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          leading: GestureDetector(
            onTap: () {
              exitPickingScreen();
            },
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.angleLeft,
                color: kPrimaryColorLight,
                size: 30.0,
              ),
            ),
          ),
          title: Text(
            pickingTask.name,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: kPrimaryColorLight,
                  fontWeight: FontWeight.w500,
                ),
          ),
          titleSpacing: 0.0,
          elevation: 10.0,
        ),
        body: LoadingOverlay(
          opacity: 0.0,
          isLoading: showSpinner,
          child: BarcodeKeyboardListener(
            onBarcodeScanned: _onBarcodeScanned,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _entityController,
                        style: Theme.of(context).textTheme.labelSmall,
                        decoration: kPickTextFieldsInputDecoration.copyWith(
                          hintText:
                              'Escolha um ${pickingTask.destinationDocumentType.entityType.name}',
                          prefixIcon: const Icon(
                            FontAwesomeIcons.userTie,
                            size: 15.0,
                            color: kPrimaryColorDark,
                          ),
                        ),
                        readOnly: true,
                        onTap: () async {
                          if (_canChangeEntity) {
                            await _onChangeEntity();
                          }
                        },
                      ),
                      if (pickingTask.originDocumentType != null)
                        Column(
                          children: [
                            const SizedBox(
                              height: 15.0,
                            ),
                            TextField(
                              style: Theme.of(context).textTheme.labelSmall,
                              decoration:
                                  kPickTextFieldsInputDecoration.copyWith(
                                hintText: 'Escolha os documentos de origem',
                                prefixIcon: const Icon(
                                  FontAwesomeIcons.book,
                                  size: 15.0,
                                  color: kPrimaryColorDark,
                                ),
                              ),
                              controller: _sourceDocumentsController,
                              readOnly: true,
                              onTap: () async {
                                await _onChangeSourceDocuments();
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  child: _useLocations && _showSingleLocation
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Divider(
                                height: 2.0,
                                color: kPrimaryColor.withOpacity(0.2),
                              ),
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            FaIcon(
                              FontAwesomeIcons.warehouse,
                              color: kPrimaryColor.withOpacity(0.8),
                              size: 13.0,
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              _showOnlyOriginLocation &&
                                      !_showOnlyDestinationLocation
                                  ? _originLocation != null
                                      ? _originLocation!.name
                                      : '(Sem localização)'
                                  : _destinationLocation != null
                                      ? _destinationLocation!.name
                                      : '(Sem localização)',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: Divider(
                                height: 2.0,
                                color: kPrimaryColor.withOpacity(0.2),
                              ),
                            ),
                          ],
                        )
                      : Divider(
                          height: 2.0,
                          color: kPrimaryColor.withOpacity(0.2),
                        ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Expanded(
                  child: FutureBuilder(
                    future: listBuild,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      List<Widget> noSnapshotWidgets;
                      if (snapshot.hasData) {
                        return documentTilesList.children.isEmpty
                            ? Column(
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 75.0,
                                          ),
                                          child: Center(
                                            child: Icon(
                                              FontAwesomeIcons.barsStaggered,
                                              color: kPrimaryColor
                                                  .withOpacity(0.15),
                                              size: 150,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Expanded(
                                    child: ScrollablePositionedList.builder(
                                      itemScrollController:
                                          _listScrollController,
                                      itemCount: documentLineTiles.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return documentLineTiles[index];
                                      },
                                    ),
                                  ),
                                ],
                              );
                      } else if (snapshot.hasError &&
                          snapshot.connectionState != ConnectionState.waiting) {
                        noSnapshotWidgets = [
                          Icon(
                            Icons.error_outline,
                            color: kPrimaryColor.withOpacity(0.6),
                            size: 50,
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                          ),
                        ];
                      } else {
                        noSnapshotWidgets = [
                          const Center(
                            child: CircularProgressIndicator(
                              color: kPrimaryColor,
                            ),
                          ),
                        ];
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: noSnapshotWidgets,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: () async {
            bool canSave = true;

            //Check if the entity is filled
            if (pickingTask.document!.entity == null) {
              await Helper.showMsg(
                'Atenção',
                'Escolha um ${pickingTask.destinationDocumentType.entityType.name}',
                context,
              );
              return;
            }

            //Check if there are any MiscData that are not filled
            final List<MiscData> miscDataNotFilled =
                alreadyShowedPostOperationInput
                    ? miscDataList
                        .where(
                          (element) =>
                              element.isMandatory && element.value.isEmpty,
                        )
                        .toList()
                    : miscDataList
                        .where(
                          (element) =>
                              element.postOperationInput ||
                              (element.preOperationInput &&
                                  element.isMandatory &&
                                  element.value.isEmpty),
                        )
                        .toList();
            if (miscDataNotFilled.isNotEmpty) {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MiscDataScreen(
                    miscDataList: miscDataNotFilled,
                  ),
                ),
              ).then((value) async {
                alreadyShowedPostOperationInput = true;
                if (value != null) {
                  final List<MiscData> miscDataIncomingList =
                      value as List<MiscData>;
                  await _onMiscDataChanged(miscDataIncomingList);
                }
              });
              return;
            }

            //If it's Inventory, get the name of the document from the user
            if (pickingTask.stockMovement == StockMovement.inventory &&
                (pickingTask.sourceDocuments.isEmpty)) {
              final TextEditingController inventoryNameController =
                  TextEditingController();
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    surfaceTintColor: kWhiteBackground,
                    title: const Text('Nome do inventário'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    actionsPadding: const EdgeInsets.only(
                      right: 10.0,
                      bottom: 5.0,
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          autofocus: true,
                          controller: inventoryNameController,
                          style: Theme.of(context).textTheme.labelSmall,
                          decoration: kPickTextFieldsInputDecoration.copyWith(
                            hintText: 'Nome',
                            prefixIcon: const Icon(
                              FontAwesomeIcons.fileWord,
                              size: 15.0,
                              color: kPrimaryColorDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      MaterialButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          canSave = false;
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancelar',
                          style:
                              Theme.of(context).textTheme.labelSmall!.copyWith(
                                    color: kPrimaryColor.withOpacity(0.8),
                                  ),
                        ),
                      ),
                      MaterialButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Submeter',
                          style:
                              Theme.of(context).textTheme.labelSmall!.copyWith(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ],
                  );
                },
              );
              pickingTask.document!.name = inventoryNameController.text;
            }

            if (!canSave) {
              return;
            }

            //Replace task customOptions with miscDataList JSON
            MiscDataHelper.toTask(pickingTask, miscDataList);

            setState(() {
              isSavingToServer = true;
              showSpinner = true;
            });

            final TaskOperation taskOperation =
                await pickingTask.saveToServer();

            if (!taskOperation.success) {
              await Helper.showMsg(
                'Atenção',
                taskOperation.message,
                context,
              );
            } else {
              await Helper.showMsg(
                'Operação concluída',
                'Documento guardado com sucesso',
                context,
              );
            }

            setState(() {
              isSavingToServer = false;
              showSpinner = false;
            });

            if (taskOperation.success) {
              exitPickingScreen();
            }
          },
          backgroundColor: kPrimaryColor,
          child: FaIcon(
            isSavingToServer
                ? FontAwesomeIcons.hourglass
                : FontAwesomeIcons.solidFloppyDisk,
            color: kPrimaryColorLight,
          ),
        ),
        bottomNavigationBar: AppBottomBar(
          onBarcodeScan: _onBarcodeScanned,
          onProductSelected: _onProductSelectedBottomBar,
          onMiscDataChanged: _onMiscDataChanged,
          miscDataList: miscDataList,
        ),
      ),
    );
  }
}
