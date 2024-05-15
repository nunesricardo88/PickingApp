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
import 'package:n6picking_flutterapp/models/container_model.dart'
    as container_model;
import 'package:n6picking_flutterapp/models/container_product_model.dart';
import 'package:n6picking_flutterapp/models/document_line_model.dart';
import 'package:n6picking_flutterapp/models/document_model.dart';
import 'package:n6picking_flutterapp/models/location_model.dart';
import 'package:n6picking_flutterapp/models/misc_data_model.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';
import 'package:n6picking_flutterapp/models/product_model.dart';
import 'package:n6picking_flutterapp/models/stock_model.dart';
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
  List<MiscData> documentExtraFieldsList = [];
  bool _hasPreOperationInput = false;

  //Location variables
  bool _useLocations = false;
  bool _canChangeOriginLocation = true;
  bool _canChangeDestinationLocation = true;
  bool _isPickingUp = true;
  bool _isDroppingOff = false;
  Location? _defaultOriginLocation;
  Location? _defaultDestinationLocation;
  Location? _currentLocation;
  List<Stock> stockList = [];

  //Save variables
  bool _ignoreNotUnloadedProducts = false;

  //Entity variables
  late bool _canChangeEntity;

  //TextControllers
  late TextEditingController _entityController;
  late TextEditingController _sourceDocumentsController;

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
    super.dispose();
  }

  Future<void> setup() async {
    final PickingTask pickingTask =
        Provider.of<PickingTask>(context, listen: false);

    _entityController = TextEditingController();
    _sourceDocumentsController = TextEditingController();
    _listScrollController = ItemScrollController();

    loadDocumentExtraFields();

    await getDocumentLinesList();

    await loadDefaultLocations();

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

    //Pre Operation Input
    if (_hasPreOperationInput) {
      final List<MiscData> miscDataPreOperationList = documentExtraFieldsList
          .where(
            (element) =>
                element.preOperationInput != null && element.preOperationInput!,
          )
          .toList();
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

  Future<void> loadDefaultLocations() async {
    final PickingTask pickingTask = Provider.of<PickingTask>(
      context,
      listen: false,
    );

    bool useLocations = false;
    bool canChangeOriginLocation = true;
    bool canChangeDestinationLocation = true;
    bool isPickingUp = false;
    bool isDroppingOff = false;
    Location? defaultFromLocation;
    Location? defaultToLocation;
    Location? currentLocation;

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
                    defaultFromLocation = null;
                    defaultToLocation = location;
                    currentLocation = location;
                    isPickingUp = false;
                    isDroppingOff = false;
                    canChangeOriginLocation = false;
                    canChangeDestinationLocation = canBeChanged;
                    break;
                  case 'Origin':
                    defaultFromLocation = location;
                    canChangeOriginLocation = canBeChanged;
                    break;
                  case 'Destination':
                    defaultToLocation = location;
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
      defaultFromLocation = null;
      defaultToLocation = null;
      isPickingUp = false;
      isDroppingOff = false;
      canChangeDestinationLocation = false;
      canChangeOriginLocation = false;
    } else {
      if (pickingTask.stockMovement == StockMovement.transfer) {
        if (canChangeDestinationLocation && canChangeOriginLocation) {
          isPickingUp = true;
          isDroppingOff = false;
          currentLocation = defaultFromLocation;
        } else {
          if (canChangeOriginLocation) {
            isPickingUp = true;
            isDroppingOff = true;
            currentLocation = defaultFromLocation;
          } else {
            isPickingUp = true;
            isDroppingOff = true;
            currentLocation = defaultToLocation;
          }
        }
      }
    }

    setDefaultFromLocation(defaultFromLocation);
    setDefaultToLocation(defaultToLocation);

    setState(() {
      _useLocations = useLocations;
      _canChangeOriginLocation = canChangeOriginLocation;
      _canChangeDestinationLocation = canChangeDestinationLocation;
      _isPickingUp = isPickingUp;
      _isDroppingOff = isDroppingOff;
    });

    await setLocation(currentLocation);
  }

  Location? _onGetCurrentOriginLocation() {
    final PickingTask pickingTask = Provider.of<PickingTask>(
      context,
      listen: false,
    );
    if (_useLocations) {
      if (_canChangeOriginLocation) {
        if ((pickingTask.stockMovement == StockMovement.transfer &&
                _isPickingUp) ||
            pickingTask.stockMovement == StockMovement.outbound) {
          return _currentLocation;
        } else {
          return _defaultOriginLocation;
        }
      } else {
        return _defaultOriginLocation;
      }
    } else {
      return null;
    }
  }

  void loadDocumentExtraFields() {
    final PickingTask pickingTask = Provider.of<PickingTask>(
      context,
      listen: false,
    );

    final List<MiscData> miscData =
        MiscDataHelper.getDocumentExtraData(pickingTask);

    final bool hasPreOperationInput = miscData.any(
      (element) =>
          element.preOperationInput != null && element.preOperationInput!,
    );

    setState(() {
      _hasPreOperationInput = hasPreOperationInput;
      documentExtraFieldsList = miscData;
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

  void setDefaultToLocation(Location? location) {
    setState(() {
      _defaultDestinationLocation = location;
    });
  }

  void setDefaultFromLocation(Location? location) {
    setState(() {
      _defaultOriginLocation = location;
    });

    updateStockList();
  }

  Future<void> setLocation(Location? location) async {
    await updateStockList();

    setState(() {
      _currentLocation = location;
    });
  }

  Future<void> updateStockList() async {
    final PickingTask pickingTask = Provider.of<PickingTask>(
      context,
      listen: false,
    );

    final StockMovement stockMovement = pickingTask.stockMovement;
    bool showStockLocation = false;
    Location? locationToUse;

    switch (stockMovement) {
      case StockMovement.inbound:
        showStockLocation = false;
        locationToUse = null;
        break;
      case StockMovement.outbound:
        showStockLocation = true;
        locationToUse = getOriginLocation();
        break;
      case StockMovement.inventory:
        showStockLocation = true;
        locationToUse = null;
        break;
      case StockMovement.transfer:
        if (_isPickingUp) {
          showStockLocation = true;
          locationToUse = getOriginLocation();
        } else {
          if (!_canChangeOriginLocation) {
            showStockLocation = true;
            locationToUse = getOriginLocation();
          } else {
            showStockLocation = false;
            locationToUse = null;
          }
        }
        break;
      default:
        showStockLocation = false;
        locationToUse = null;
        break;
    }

    setState(() {
      showSpinner = true;
    });

    //Set the stockList according to the location
    List<Stock> listStock = [];
    if (showStockLocation) {
      listStock = await getStockList(locationToUse);
    } else {
      listStock = [];
    }

    setState(() {
      stockList = listStock;
      showSpinner = false;
    });
  }

  String getLocationName(Location? location) {
    if (location == null) {
      return 'Sem localização';
    } else {
      return location.name;
    }
  }

  StockMovement getCurrentLocationStockMovementType() {
    final PickingTask pickingTask = Provider.of<PickingTask>(
      context,
      listen: false,
    );

    switch (pickingTask.stockMovement) {
      case StockMovement.inbound:
        return StockMovement.inbound;
      case StockMovement.outbound:
        return StockMovement.outbound;
      case StockMovement.transfer:
        if (_canChangeDestinationLocation && _canChangeOriginLocation) {
          if (_isPickingUp) {
            return StockMovement.outbound;
          } else {
            return StockMovement.inbound;
          }
        } else {
          if (_canChangeOriginLocation) {
            return StockMovement.outbound;
          } else {
            return StockMovement.inbound;
          }
        }

      case StockMovement.inventory:
        return StockMovement.inventory;
      default:
        return StockMovement.inbound;
    }
  }

  Future<List<Stock>> getStockList(Location? location) async {
    final PickingTask pickingTask = Provider.of<PickingTask>(
      context,
      listen: false,
    );

    List<Stock> listStock = [];

    if (location == null) {
      listStock = [];
    } else {
      listStock = await StockApi.getByLocation(location);

      //remove quantities from stock list that are with the same origin location in documentLines
      if (pickingTask.document != null) {
        for (final DocumentLine documentLine in pickingTask.document!.lines) {
          final Product product = documentLine.product;
          final Stock? stock = listStock.firstWhereOrNull(
            (stock) =>
                stock.product.reference == product.reference &&
                stock.batch == documentLine.batch &&
                stock.locationId == location.id,
          );
          if (stock != null) {
            if (stock.quantity > documentLine.quantity) {
              stock.quantity -= documentLine.quantity;
            } else {
              listStock.remove(stock);
            }
          }
        }
      }
    }
    return listStock;
  }

  List<Stock> _onStockListCallBack() {
    return stockList;
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
            location: _defaultDestinationLocation,
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
          onGetOriginLocation: getOriginLocation,
          onGetDestinationLocation: getDestinationLocation,
        ),
      ),
    ).then((value) async {
      if (value != null) {
        final List<double> returnData = value as List<double>;
        if (System.instance.activeLicense == License.rrmp) {
          await _onSplitBatches(
            documentLine,
            returnData,
          );
        }

        if (System.instance.activeLicense == License.techsysflui) {
          await _onSplitContainer(
            documentLine,
            returnData,
          );
        }
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

  Future<void> _onSplitContainer(
    DocumentLine documentLine,
    List<double> containerData,
  ) async {
    final double containersCount = containerData[0];
    final double productCount = containerData[1];
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

    for (final Batch batch in newLines) {
      final double quantity = double.tryParse(batch.erpId!.trim()) ?? 0;

      final TaskOperation taskOperation = await addProduct(
        product: oldDocumentLine.product,
        documentLine: oldDocumentLine,
        batch: batch,
        quantity: quantity,
      );
      if (taskOperation.success) {
        final Guid id = Guid(taskOperation.message);
        final DocumentLine newDocumentLine = pickingTask.document!.lines
            .firstWhere((element) => element.id == id);
        newDocumentLine.linkedLineErpId = oldDocumentLine.linkedLineErpId;
      }
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

  Future<void> _onStockSelectedBottomBar(Stock stock) async {
    setState(() {
      showSpinner = true;
      canPick = false;
    });

    documentLineToScroll = null;

    final TaskOperation taskOperation = await addProduct(
      product: stock.product,
      batch: stock.batch,
      quantity: stock.quantity,
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
      final int index = documentExtraFieldsList.indexWhere(
        (element) => element.id == miscData.id,
      );
      if (index != -1) {
        documentExtraFieldsList[index] = miscData;
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
        if (_useLocations) {
          if (_currentLocation == null) {
            taskOperation = TaskOperation(
              success: false,
              errorCode: ErrorCode.locationNotSet,
              message: 'Defina primeiro uma localização',
            );
            break;
          }
        }

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
          taskOperation = await addProduct(product: product);
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

            taskOperation = await addProduct(product: product, batch: batch);
          }
        }

        break;
      case BarCodeType.container:
        //Check if has location
        if (_useLocations) {
          if (_currentLocation == null) {
            taskOperation = TaskOperation(
              success: false,
              errorCode: ErrorCode.locationNotSet,
              message: 'Defina primeiro uma localização',
            );
            break;
          }
        }

        final String containerBarcode = barcode.substring(2);
        final container_model.Container? container =
            await container_model.ContainerApi.getByBarcode(
          containerBarcode,
        );

        if (container == null) {
          taskOperation = TaskOperation(
            success: false,
            errorCode: ErrorCode.containerNotFound,
            message: 'Contentor não encontrado',
          );
          break;
        } else {
          List<ContainerProduct> containerProducts = [];
          containerProducts =
              await ContainerProductApi.getByContainerErpId(container.erpId!);

          for (final ContainerProduct containerProduct in containerProducts) {
            final Product product = containerProduct.product;
            final double quantity = containerProduct.quantity;

            taskOperation = await addProduct(
              product: product,
              quantity: quantity,
            );
          }
        }

        break;
      case BarCodeType.location:
        if (!_useLocations) {
          taskOperation = TaskOperation(
            success: false,
            errorCode: ErrorCode.cannotChangeLocation,
            message: 'Localização não pode ser alterada',
          );
          break;
        }

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
          await setLocation(location);
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
    DocumentLine? documentLine,
    Batch? batch,
    double quantity = 0,
    container_model.Container? container,
  }) async {
    final PickingTask pickingTask = Provider.of<PickingTask>(
      context,
      listen: false,
    );

    //Control Objects
    DocumentLine? sameProductSourceDocumentLine;
    double quantityToAdd = quantity;
    double defaultQuantity = 0.0;

    //====CREATE A NEW DOCUMENT LINE====
    final DocumentLine documentLineToAdd =
        pickingTask.createDocumentLineByProduct(
      product: product,
      batch: batch,
    );
    documentLineToAdd.container = container;

    //====SET THE LOCATIONS====
    Location? originLocation;
    Location? destinationLocation;

    if (_useLocations) {
      switch (pickingTask.stockMovement) {
        case StockMovement.inbound:
          originLocation = null;
          destinationLocation = _currentLocation;
          break;
        case StockMovement.outbound:
          originLocation = null;
          destinationLocation = _currentLocation;
          break;
        case StockMovement.transfer:
          if (_canChangeOriginLocation && _canChangeDestinationLocation) {
            if (_isPickingUp) {
              originLocation = _currentLocation;
              destinationLocation = _defaultDestinationLocation;
            } else {
              originLocation = _defaultOriginLocation;
              destinationLocation = _currentLocation;
            }
          } else {
            if (_canChangeOriginLocation) {
              originLocation = _currentLocation;
              destinationLocation = _defaultDestinationLocation;
            } else {
              originLocation = _defaultOriginLocation;
              destinationLocation = _currentLocation;
            }
          }
          break;
        case StockMovement.inventory:
          originLocation = null;
          destinationLocation = _currentLocation;
          break;
        default:
          originLocation = null;
          destinationLocation = null;
          break;
      }
    } else {
      originLocation = null;
      destinationLocation = null;
    }

    //Check if it has a location before adding the product
    if (_useLocations) {
      if (_currentLocation == null) {
        return TaskOperation(
          success: false,
          errorCode: ErrorCode.locationNotSet,
          message: 'Defina primeiro uma localização',
        );
      }
    }

    documentLineToAdd.originLocation = originLocation;
    documentLineToAdd.destinationLocation = destinationLocation;

    //====GET THE FITTING DOCUMENT LINE====
    DocumentLine? fittingDocumentLine =
        getFittingDocumentLine(documentLine, documentLineToAdd);

    //If there is no fittingDocumentLine, search for a SourceDocumentLine with the same product
    //and set the linkedLineErpId
    if (pickingTask.sourceDocuments.isNotEmpty) {
      for (final Document sourceDocument in pickingTask.sourceDocuments) {
        sameProductSourceDocumentLine = sourceDocument.lines.firstWhereOrNull(
          (element) =>
              element.product.reference.trim() ==
              documentLineToAdd.product.reference.trim(),
        );
        if (sameProductSourceDocumentLine != null) {
          break;
        }
      }
    }

    //Default Quantity (RRMP)
    final License license = System.instance.activeLicense;
    if (license == License.rrmp) {
      if (product.usaMolho && batch != null) {
        if (pickingTask.stockMovement == StockMovement.outbound ||
            (pickingTask.stockMovement == StockMovement.transfer &&
                _isPickingUp)) {
          Location location;
          if (pickingTask.stockMovement == StockMovement.outbound) {
            location = _currentLocation!;
          } else {
            if (_canChangeOriginLocation && _isPickingUp) {
              location = _currentLocation!;
            } else {
              location = _defaultOriginLocation!;
            }
          }
          defaultQuantity = await getStockInLocation(location, product, batch);
        }
      }
    }

    //TODO - TechsysFlui Default QTT
    if (license == License.techsysflui &&
        pickingTask.stockMovement == StockMovement.inbound &&
        fittingDocumentLine != null) {
      defaultQuantity = fittingDocumentLine.quantityToPick;
    }

    if (pickingTask.stockMovement == StockMovement.transfer &&
        _isDroppingOff &&
        fittingDocumentLine != null) {
      defaultQuantity = fittingDocumentLine.quantity;
    }

    //====GET THE BATCH AND QUANTITY====
    if (quantityToAdd == 0 || (batch == null && product.isBatchTracked)) {
      setState(() {
        showSpinner = false;
      });
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return DocumentLineDialog(
            documentLine: documentLineToAdd,
            defaultQuantity: defaultQuantity,
          );
        },
      );
      batch = documentLineToAdd.batch;
      quantityToAdd = documentLineToAdd.quantity;
      documentLineToAdd.quantity = 0.0;
      if (quantityToAdd == 0) {
        return TaskOperation(
          success: true,
          errorCode: ErrorCode.quantityZero,
          message: 'A quantidade não pode ser zero',
        );
      }
      setState(() {
        showSpinner = true;
      });
    }

    //====CHECK THE STOCK====
    if (_useLocations) {
      if (pickingTask.stockMovement == StockMovement.outbound ||
          (pickingTask.stockMovement == StockMovement.transfer &&
              _isPickingUp)) {
        Location location;
        if (pickingTask.stockMovement == StockMovement.outbound) {
          location = _currentLocation!;
        } else {
          if (_canChangeOriginLocation && _isPickingUp) {
            location = _currentLocation!;
          } else {
            location = _defaultOriginLocation!;
          }
        }

        final bool hasStock = await checkLocationStock(
          location,
          product,
          batch,
          quantityToAdd,
        );
        if (!hasStock) {
          return TaskOperation(
            success: false,
            errorCode: ErrorCode.insuficientStock,
            message: 'Não há stock suficiente',
          );
        }
      }
    }

    fittingDocumentLine =
        getFittingDocumentLine(documentLine, documentLineToAdd);

    //If there is no fittingDocumentLine, search for a SourceDocumentLine with the same product
    //and set the linkedLineErpId
    if (pickingTask.sourceDocuments.isNotEmpty) {
      for (final Document sourceDocument in pickingTask.sourceDocuments) {
        sameProductSourceDocumentLine = sourceDocument.lines.firstWhereOrNull(
          (element) =>
              element.product.reference.trim() ==
              documentLineToAdd.product.reference.trim(),
        );
        if (sameProductSourceDocumentLine != null) {
          break;
        }
      }
    }

    //If it's a transfer and the user is unloading
    if (pickingTask.stockMovement == StockMovement.transfer &&
        _isDroppingOff &&
        _canChangeDestinationLocation &&
        _canChangeOriginLocation) {
      if (fittingDocumentLine == null) {
        return TaskOperation(
          success: false,
          errorCode: ErrorCode.insuficientStock,
          message: 'Este artigo não foi carregado',
        );
      }

      //Check loaded quantity
      if (fittingDocumentLine.quantity < quantityToAdd) {
        return TaskOperation(
          success: false,
          errorCode: ErrorCode.quantityAboveMax,
          message:
              'A quantidade carregada é maior que a quantidade a descarregar',
        );
      }

      //If the quantity is the same, just set the destinationLocation
      if (fittingDocumentLine.quantity == quantityToAdd) {
        DocumentLine finalDocumentLine;
        finalDocumentLine = fittingDocumentLine;
        finalDocumentLine.batch = documentLineToAdd.batch;
        finalDocumentLine.destinationLocation =
            documentLineToAdd.destinationLocation;

        //Prepare the scroll to the document line
        documentLineToScroll = finalDocumentLine;

        return TaskOperation(
          success: true,
          errorCode: ErrorCode.none,
          message: '',
        );
      } else {
        //If the quantity is different, subtract the quantity from the fittingDocumentLine
        //and copy the fittingDocumentLine to the new documentLine with the new quantity
        pickingTask.addToDocumentLineQuantity(
          fittingDocumentLine,
          -quantityToAdd,
        );
        final DocumentLine finalDocumentLine = fittingDocumentLine.copyWith(
          id: Guid.newGuid,
          quantity: quantityToAdd,
          destinationLocation: _currentLocation,
        );
        pickingTask.document!.lines.add(finalDocumentLine);
        if (sameProductSourceDocumentLine != null) {
          finalDocumentLine.linkedLineErpId =
              sameProductSourceDocumentLine.erpId;
        }

        //Prepare the scroll to the document line
        documentLineToScroll = finalDocumentLine;

        return TaskOperation(
          success: true,
          errorCode: ErrorCode.none,
          message: '',
        );
      }
    } else {
      //Proceed normally

      // Add new documentLine or change existent documentLine
      DocumentLine finalDocumentLine;
      if (fittingDocumentLine == null) {
        finalDocumentLine = documentLineToAdd;
        pickingTask.document!.lines.add(finalDocumentLine);
        if (sameProductSourceDocumentLine != null) {
          finalDocumentLine.linkedLineErpId =
              sameProductSourceDocumentLine.erpId;
        }
      } else {
        finalDocumentLine = fittingDocumentLine;
        finalDocumentLine.originLocation = documentLineToAdd.originLocation;
        finalDocumentLine.destinationLocation =
            documentLineToAdd.destinationLocation;
        finalDocumentLine.batch = documentLineToAdd.batch;
      }

      if (pickingTask.document!.lines.isEmpty) {
        setState(() {
          _isPickingUp = true;
          _isDroppingOff = false;
        });
      }

      //Prepare the scroll to the document line
      documentLineToScroll = finalDocumentLine;

      final TaskOperation taskOperation = pickingTask.addToDocumentLineQuantity(
        finalDocumentLine,
        quantityToAdd,
      );

      if (taskOperation.success) {
        return TaskOperation(
          success: true,
          errorCode: ErrorCode.none,
          message: finalDocumentLine.id.toString(),
        );
      } else {
        return taskOperation;
      }
    }
  }

  Future<bool> checkLocationStock(
    Location location,
    Product product,
    Batch? batch,
    double quantity,
  ) async {
    bool hasStock = true;

    if (_useLocations) {
      final double stock =
          await LocationApi.getProductStockByLocation(location, product, batch);

      if (stock < quantity) {
        hasStock = false;
      }
    }

    return hasStock;
  }

  Future<double> getStockInLocation(
    Location location,
    Product product,
    Batch? batch,
  ) async {
    double stock = 0;
    if (_useLocations) {
      stock =
          await LocationApi.getProductStockByLocation(location, product, batch);
    }

    return stock;
  }

  DocumentLine? getFittingDocumentLine(
    DocumentLine? originalDocumentLine,
    DocumentLine documentLine,
  ) {
    final PickingTask pickingTask = Provider.of<PickingTask>(
      context,
      listen: false,
    );

    //Lists
    List<DocumentLine> documentLinesWithFittingProduct = [];
    List<DocumentLine> documentLinesWithFittingBatch = [];
    List<DocumentLine> documentLinesWithFittingLocation = [];
    List<DocumentLine> finalFittingDocumentLines = [];

    //Find the document lines with the same product
    documentLinesWithFittingProduct = pickingTask.document!.lines
        .where(
          (element) =>
              element.product.reference.trim() ==
              documentLine.product.reference.trim(),
        )
        .toList();
    if (documentLinesWithFittingProduct.isEmpty) {
      return null;
    }

    //Find the document lines with the fitting batch
    if (documentLine.batch != null) {
      documentLinesWithFittingBatch = documentLinesWithFittingProduct
          .where(
            (element) =>
                //Same batch
                (element.batch != null &&
                    element.batch!.batchNumber.trim() ==
                        documentLine.batch!.batchNumber.trim()) ||

                //Element and line without batch
                (element.batch == null && documentLine.batch == null) ||

                //Element without batch and line with batch
                (element.batch == null && documentLine.batch != null),
          )
          .toList();
    } else {
      documentLinesWithFittingBatch = documentLinesWithFittingProduct;
    }

    //Find the document lines with the fitting location
    if (_useLocations) {
      documentLinesWithFittingLocation = documentLinesWithFittingBatch
          .where(
            (element) =>

                // No Transfers
                (pickingTask.stockMovement != StockMovement.transfer &&
                    //No Destination Location on both
                    ((element.destinationLocation == null &&
                            documentLine.destinationLocation == null) ||
                        //Element without Destination Location and line with Destination Location
                        (element.destinationLocation == null &&
                            documentLine.destinationLocation != null) ||
                        //Both with the same Destination Location
                        (element.destinationLocation != null &&
                            documentLine.destinationLocation != null &&
                            element.destinationLocation!.erpId.trim() ==
                                documentLine.destinationLocation!.erpId
                                    .trim()))) ||

                //Transfers
                (pickingTask.stockMovement == StockMovement.transfer &&
                    //Load Product
                    //Element without both locations and line only with Origin Location
                    ((element.originLocation == null &&
                            element.destinationLocation == null &&
                            documentLine.originLocation != null &&
                            documentLine.destinationLocation == null) ||

                        //Load more Product
                        //Element with only Origin Location and line with the same Origin Location
                        (element.originLocation != null &&
                            element.destinationLocation == null &&
                            documentLine.originLocation != null &&
                            documentLine.destinationLocation == null &&
                            element.originLocation!.erpId.trim() ==
                                documentLine.originLocation!.erpId.trim()) ||

                        //Unload Product
                        //Element with only Origin Location and line with a Destination Location
                        (element.originLocation != null &&
                            element.destinationLocation == null &&
                            documentLine.originLocation == null &&
                            documentLine.destinationLocation != null) ||

                        //Unload more Product
                        //Both with the same Locations
                        (element.originLocation != null &&
                            element.destinationLocation != null &&
                            documentLine.originLocation == null &&
                            documentLine.destinationLocation != null &&
                            element.destinationLocation!.erpId.trim() ==
                                documentLine.destinationLocation!.erpId
                                    .trim()))),
          )
          .toList();
    } else {
      documentLinesWithFittingLocation = documentLinesWithFittingBatch;
    }

    finalFittingDocumentLines = documentLinesWithFittingLocation;

    //Check if originalDocumentLine is in the list
    DocumentLine? finalFittingDocumentLine;
    if (originalDocumentLine != null) {
      finalFittingDocumentLine = finalFittingDocumentLines.firstWhereOrNull(
        (element) => element.id == originalDocumentLine.id,
      );
    }

    return finalFittingDocumentLine ??= finalFittingDocumentLines.firstOrNull;
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

      if (pickingTask.document!.lines.isEmpty &&
          pickingTask.stockMovement == StockMovement.transfer) {
        setState(() {
          _isPickingUp = true;
          _isDroppingOff = false;
        });
      }

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
      _entityController.text = getEntityName();
      canPick = true;
    });
    getDocumentLinesList();
  }

  Location? getDestinationLocation() {
    final PickingTask pickingTask =
        Provider.of<PickingTask>(context, listen: false);

    Location? destinationLocation;

    if (_useLocations) {
      switch (pickingTask.stockMovement) {
        case StockMovement.inbound:
          destinationLocation = _currentLocation;
          break;
        case StockMovement.outbound:
          destinationLocation = _currentLocation;
          break;
        case StockMovement.transfer:
          if (_canChangeOriginLocation && _canChangeDestinationLocation) {
            if (_isPickingUp) {
              destinationLocation = _defaultDestinationLocation;
            } else {
              destinationLocation = _currentLocation;
            }
          } else {
            if (_canChangeOriginLocation) {
              destinationLocation = _defaultDestinationLocation;
            } else {
              destinationLocation = _currentLocation;
            }
          }
          break;
        case StockMovement.inventory:
          destinationLocation = _currentLocation;
          break;
        default:
          destinationLocation = null;
          break;
      }
    } else {
      destinationLocation = null;
    }

    return destinationLocation;
  }

  Location? getOriginLocation() {
    final PickingTask pickingTask =
        Provider.of<PickingTask>(context, listen: false);

    Location? originLocation;

    if (_useLocations) {
      switch (pickingTask.stockMovement) {
        case StockMovement.inbound:
          originLocation = null;
          break;
        case StockMovement.outbound:
          originLocation = null;
          break;
        case StockMovement.transfer:
          if (_canChangeOriginLocation && _canChangeDestinationLocation) {
            if (_isPickingUp) {
              originLocation = _currentLocation;
            } else {
              originLocation = _defaultOriginLocation;
            }
          } else {
            if (_canChangeOriginLocation) {
              originLocation = _currentLocation;
            } else {
              originLocation = _defaultOriginLocation;
            }
          }
          break;
        case StockMovement.inventory:
          originLocation = null;
          break;
        default:
          originLocation = null;
          break;
      }
    } else {
      originLocation = null;
    }

    return originLocation;
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

    //If it's a transfer, remove the products that were unloaded
    if (pickingTask.stockMovement == StockMovement.transfer &&
        _ignoreNotUnloadedProducts) {
      //Get the products that were unloaded
      final List<DocumentLine> unloadedProducts = pickingTask.document!.lines
          .where(
            (element) =>
                element.destinationLocation != null &&
                element.originLocation != null,
          )
          .toList();

      //Remove the products that were unloaded
      for (final DocumentLine documentLine in unloadedProducts) {
        final DocumentLine? documentLineToRemove =
            pickingTask.document!.lines.firstWhereOrNull(
          (element) => element.id == documentLine.id,
        );
        if (documentLineToRemove != null) {
          removeFromDocument(documentLineToRemove);
        }
      }
      setState(() {
        _ignoreNotUnloadedProducts = false;
      });
    } else {
      pickingTask.clear();
      Navigator.pop(context);
    }
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
                  child: _useLocations
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
                            GestureDetector(
                              onTap: () {
                                //IF it's a transfer, the user can change if it's picking up or dropping off
                                if (pickingTask.stockMovement ==
                                        StockMovement.transfer &&
                                    _canChangeDestinationLocation &&
                                    _canChangeOriginLocation) {
                                  //Only swap if there are documentLines
                                  if (pickingTask.document!.lines.isNotEmpty) {
                                    setState(() {
                                      _isPickingUp = !_isPickingUp;
                                      _isDroppingOff = !_isDroppingOff;
                                      _currentLocation = _isPickingUp
                                          ? _defaultOriginLocation
                                          : _defaultDestinationLocation;
                                    });
                                  }
                                }
                              },
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.warehouse,
                                        size: 13.0,
                                        color: getCurrentLocationStockMovementType() ==
                                                StockMovement.outbound
                                            ? kOutboundStockMovement
                                            : getCurrentLocationStockMovementType() ==
                                                    StockMovement.inbound
                                                ? kInboundStockMovement
                                                : kPrimaryColor
                                                    .withOpacity(0.8),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 18.0,
                                          top: 1.0,
                                        ),
                                        child: FaIcon(
                                          getCurrentLocationStockMovementType() ==
                                                  StockMovement.outbound
                                              ? FontAwesomeIcons.arrowRight
                                              : FontAwesomeIcons.arrowLeft,
                                          size: 13.0,
                                          color: getCurrentLocationStockMovementType() ==
                                                  StockMovement.outbound
                                              ? kOutboundStockMovement
                                              : getCurrentLocationStockMovementType() ==
                                                      StockMovement.inbound
                                                  ? kInboundStockMovement
                                                  : kPrimaryColor
                                                      .withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    getLocationName(_currentLocation),
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              ),
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

            //Check if there are any DocumentLines
            if (pickingTask.document!.lines.isEmpty) {
              await Helper.showMsg(
                'Atenção',
                'Não encontrei linhas para guardar',
                context,
              );
              return;
            }

            //Check if it's a transfer and there are lines with no destinationLocation
            final List<DocumentLine> linesWithoutDestinationLocation =
                pickingTask.document!.lines
                    .where(
                      (element) =>
                          element.destinationLocation == null &&
                          element.quantity > 0,
                    )
                    .toList();

            if (pickingTask.stockMovement == StockMovement.transfer &&
                linesWithoutDestinationLocation.isNotEmpty) {
              _ignoreNotUnloadedProducts = await Helper.askQuestion(
                'Atenção',
                'Existem linhas ainda por descarregar.\n\nDeseja guardar apenas as linhas descarregadas e continuar o processo?',
                context,
              );
              if (!_ignoreNotUnloadedProducts) {
                return;
              }
            }

            //Check if there are any MiscData that are not filled
            final List<MiscData> miscDataNotFilled =
                alreadyShowedPostOperationInput
                    ? documentExtraFieldsList
                        .where(
                          (element) =>
                              element.isMandatory != null &&
                              element.isMandatory! &&
                              element.value.isEmpty,
                        )
                        .toList()
                    : documentExtraFieldsList
                        .where(
                          (element) =>
                              (element.postOperationInput != null &&
                                  element.postOperationInput!) ||
                              (element.preOperationInput != null &&
                                  element.preOperationInput! &&
                                  element.isMandatory != null &&
                                  element.isMandatory! &&
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

            //Container Creation
            final bool canCreateContainer = pickingTask.canCreateContainer();
            if (canCreateContainer) {
              final bool createContainer = await Helper.askQuestion(
                'Criar contentor?',
                'Deseja criar um contentor para as linhas?',
                context,
              );
              if (!createContainer) {
                pickingTask.setOffCanCreateContainer();
              }
            }

            //Replace task customOptions with miscDataList JSON
            MiscDataHelper.setDocumentExtraData(
              pickingTask,
              documentExtraFieldsList,
            );

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

            bool keepPicking = false;
            if (taskOperation.success) {
              //Check if there are documentLines to pick (quantityToPick > 0)
              if (pickingTask.document!.lines
                  .any((element) => element.quantityToPick > 0)) {
                keepPicking = await Helper.askQuestion(
                  'Continuar?',
                  'O documento ainda não está totalmente satisfeito.\n\nDeseja continuar?',
                  context,
                );
              }
              if (keepPicking) {
                setState(() {
                  showSpinner = true;
                });
                await pickingTask
                    .setSourceDocumentsFromList(pickingTask.sourceDocuments);
                await getDocumentLinesList();
                setState(() {
                  showSpinner = false;
                });
              } else {
                exitPickingScreen();
              }
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
          onStockSelected: _onStockSelectedBottomBar,
          onStockListCallBack: _onStockListCallBack,
          onMiscDataChanged: _onMiscDataChanged,
          onGetCurrentOriginLocation: _onGetCurrentOriginLocation,
          miscDataList: documentExtraFieldsList,
        ),
      ),
    );
  }
}
