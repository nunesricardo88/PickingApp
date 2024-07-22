// ignore_for_file: use_build_context_synchronously
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:n6picking_flutterapp/components/bottom_app_bar.dart';
import 'package:n6picking_flutterapp/components/document_line_dialog.dart';
import 'package:n6picking_flutterapp/components/group_document_line_tile.dart';
import 'package:n6picking_flutterapp/components/loading_display.dart';
import 'package:n6picking_flutterapp/components/single_document_line_tile.dart';
import 'package:n6picking_flutterapp/components/stock_tile.dart';
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
  String spinnerMessage = 'Por favor, aguarde';
  bool isSavingToServer = false;
  bool canPick = false;
  bool alreadyShowedPostOperationInput = false;
  DocumentLine? documentLineToScroll;

  //MiscData variables
  List<MiscData> documentExtraFieldsList = [];
  bool _hasPreOperationInput = false;

  //Location variables
  bool _canChangeOriginLocation = true;
  bool _canChangeDestinationLocation = true;
  bool _mustPickOriginLocation = false;
  bool _mustPickDestinationLocation = false;
  Location? _defaultOriginLocation;
  Location? _defaultDestinationLocation;
  Location? _originLocation;
  Location? _destinationLocation;

  //Stock variables
  List<Stock> stockList = [];
  List<Stock> stockListSelected = [];

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

  //Group by document lines
  late LineGroupType groupDocumentLinesBy = LineGroupType.none;

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

    loadDefaultLocations();
    await setDefaultLocations();

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

  void loadDefaultLocations() {
    final PickingTask pickingTask = Provider.of<PickingTask>(
      context,
      listen: false,
    );

    bool canChangeOriginLocation = true;
    bool canChangeDestinationLocation = true;
    bool mustPickOriginLocation = false;
    bool mustPickDestinationLocation = false;
    Location? defaultFromLocation;
    Location? defaultToLocation;

    final String customOptions = pickingTask.customOptions;
    if (customOptions.isNotEmpty) {
      final Map<String, dynamic> customOptionsJSON =
          jsonDecode(customOptions) as Map<String, dynamic>;

      if (customOptionsJSON.containsKey('LocationsOptions')) {
        final Map<String, dynamic> locationsOptionsJSON =
            customOptionsJSON['LocationsOptions'] as Map<String, dynamic>;

        //Default Locations
        if (locationsOptionsJSON.containsKey('DefaultLocations')) {
          final List<dynamic> defaultLocationsJSON =
              locationsOptionsJSON['DefaultLocations'] as List<dynamic>;

          final Iterable<Map<String, dynamic>> defaultLocationsIterable =
              defaultLocationsJSON.cast<Map<String, dynamic>>();

          for (final Map<String, dynamic> locationJSON
              in defaultLocationsIterable) {
            final String erpId = locationJSON['ErpId'] as String;
            final bool canBeChanged = locationJSON['CanBeChanged'] as bool;
            final bool mustBePicked = locationJSON['RequiresPick'] as bool;
            final String locationKind = locationJSON['LocationKind'] as String;

            final Location? location = LocationApi.getByErpId(
              erpId,
              LocationApi.instance.allLocations,
            );

            if (location != null) {
              switch (locationKind) {
                case 'Origin':
                  defaultFromLocation = location;
                  canChangeOriginLocation = canBeChanged;
                  mustPickOriginLocation = mustBePicked;
                case 'Destination':
                  defaultToLocation = location;
                  canChangeDestinationLocation = canBeChanged;
                  mustPickDestinationLocation = mustBePicked;
                default:
                  break;
              }
            }
          }
        }
      }
    }

    setState(() {
      _canChangeOriginLocation = canChangeOriginLocation;
      _canChangeDestinationLocation = canChangeDestinationLocation;
      _mustPickOriginLocation = mustPickOriginLocation;
      _mustPickDestinationLocation = mustPickDestinationLocation;
      _defaultOriginLocation = defaultFromLocation;
      _defaultDestinationLocation = defaultToLocation;
    });
  }

  Future<void> setDefaultLocations() async {
    final PickingTask pickingTask = Provider.of<PickingTask>(
      context,
      listen: false,
    );

    Location? originLocation;
    Location? destinationLocation;

    switch (pickingTask.stockMovement) {
      case StockMovement.none:
        originLocation = null;
        destinationLocation = null;
      case StockMovement.inbound:
        originLocation = null;
        destinationLocation =
            _mustPickDestinationLocation ? null : _defaultDestinationLocation;
      case StockMovement.outbound:
        originLocation =
            _mustPickOriginLocation ? null : _defaultOriginLocation;
      case StockMovement.inventory:
        originLocation = null;
        destinationLocation =
            _mustPickDestinationLocation ? null : _defaultDestinationLocation;
      case StockMovement.transfer:
        originLocation =
            _mustPickOriginLocation ? null : _defaultOriginLocation;
        destinationLocation =
            _mustPickDestinationLocation ? null : _defaultDestinationLocation;
    }

    setState(() {
      _destinationLocation = destinationLocation;
    });

    await setOriginLocation(originLocation);
  }

  Future<void> setOriginLocation(Location? location) async {
    setState(() {
      _originLocation = location;
    });
  }

  Future<void> setDestinationLocation(Location? location) async {
    setState(() {
      _destinationLocation = location;
    });
  }

  bool needsLocation() {
    final PickingTask pickingTask = Provider.of<PickingTask>(
      context,
      listen: false,
    );

    switch (pickingTask.stockMovement) {
      case StockMovement.none:
        return false;
      case StockMovement.inbound:
        return _destinationLocation == null;
      case StockMovement.outbound:
        return _originLocation == null;
      case StockMovement.inventory:
        return _destinationLocation == null;
      case StockMovement.transfer:
        return _originLocation == null;
    }
  }

  Location? _onGetCurrentOriginLocation() {
    return _originLocation;
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

  void showLoadingDisplay(String message) {
    setState(() {
      canPick = false;
      showSpinner = true;
      spinnerMessage = message;
    });
  }

  void hideLoadingDisplay() {
    setState(() {
      canPick = true;
      showSpinner = false;
    });
  }

  Future<void> updateStockList() async {
    final PickingTask pickingTask = Provider.of<PickingTask>(
      context,
      listen: false,
    );

    bool showStockLocation = false;

    switch (pickingTask.stockMovement) {
      case StockMovement.none:
        showStockLocation = false;
      case StockMovement.inbound:
        showStockLocation = false;
      case StockMovement.outbound:
        showStockLocation = true;
      case StockMovement.inventory:
        showStockLocation = false;
      case StockMovement.transfer:
        showStockLocation = true;
    }

    showLoadingDisplay('A abrir localização');

    //Set the stockList according to the location
    List<Stock> listStock = [];
    if (showStockLocation) {
      listStock = await getStockList(_originLocation);
    } else {
      listStock = [];
    }

    setState(() {
      stockList = listStock;
    });

    hideLoadingDisplay();
  }

  String getCurrentLocationName() {
    final PickingTask pickingTask = Provider.of<PickingTask>(
      context,
      listen: false,
    );

    switch (pickingTask.stockMovement) {
      case StockMovement.none:
        return '';
      case StockMovement.inbound:
        return _destinationLocation?.name ?? 'Sem localização';
      case StockMovement.outbound:
        return _originLocation?.name ?? 'Sem localização';
      case StockMovement.inventory:
        return _destinationLocation?.name ?? 'Sem localização';
      case StockMovement.transfer:
        return _originLocation?.name ?? 'Sem localização';
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
    setState(() {
      listBuild = getDocumentLines();
    });
  }

  Map<String, List<DocumentLine>> groupByProductRef(
    List<DocumentLine> documentLineList,
  ) {
    final Map<String, List<DocumentLine>> groupedDocumentLines = {};

    for (final DocumentLine documentLine in documentLineList) {
      final ref = documentLine.product.reference;

      if (!groupedDocumentLines.containsKey(ref)) {
        groupedDocumentLines[ref] = [];
      }
      groupedDocumentLines[ref]!.add(documentLine);
    }

    return groupedDocumentLines;
  }

  Map<String, List<DocumentLine>> groupByProductRefAndBatch(
    List<DocumentLine> documentLineList,
  ) {
    final Map<String, List<DocumentLine>> groupedDocumentLines = {};

    for (final DocumentLine documentLine in documentLineList) {
      final ref = documentLine.product.reference.trim();
      final batch = documentLine.batch?.batchNumber.trim()[0] ?? '';

      if (!groupedDocumentLines.containsKey(ref + batch)) {
        groupedDocumentLines[ref + batch] = [];
      }
      groupedDocumentLines[ref + batch]!.add(documentLine);
    }

    return groupedDocumentLines;
  }

  Map<String, List<DocumentLine>> groupByContainerBarcode(
    List<DocumentLine> documentLineList,
  ) {
    final Map<String, List<DocumentLine>> groupedDocumentLines = {};

    for (final DocumentLine documentLine in documentLineList) {
      final containerBarcode = documentLine.container?.barcode.trim() ?? '';
      final unit = documentLine.product.unit;

      if (!groupedDocumentLines.containsKey(containerBarcode + unit)) {
        groupedDocumentLines[containerBarcode + unit] = [];
      }
      groupedDocumentLines[containerBarcode + unit]!.add(documentLine);
    }

    return groupedDocumentLines;
  }

  Future<bool> getDocumentLines() async {
    documentLineTiles.clear();
    final PickingTask pickingTask =
        Provider.of<PickingTask>(context, listen: false);

    documentLineList = pickingTask.document!.lines;

    if (groupDocumentLinesBy != LineGroupType.none) {
      // Agrupa as linhas de documentLineList (lista de listas)
      Map<String, List<DocumentLine>> groupedDocumentLines = {};

      if (groupDocumentLinesBy == LineGroupType.product) {
        groupedDocumentLines = groupByProductRef(documentLineList);
      } else if (groupDocumentLinesBy == LineGroupType.productBatch) {
        groupedDocumentLines = groupByProductRefAndBatch(documentLineList);
      } else if (groupDocumentLinesBy == LineGroupType.container) {
        groupedDocumentLines = groupByContainerBarcode(documentLineList);
      }

      groupedDocumentLines.forEach((key, lines) {
        documentLineTiles.add(
          GroupDocumentLineTile(
            groupName: key,
            documentLines: lines,
            lineGroupType: groupDocumentLinesBy,
          ),
        );
      });
    } else {
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
                    await removeFromDocument(documentLine);
                  },
                ),
              ],
            ),
            child: SingleDocumentLineTile(
              documentLine: documentLine,
              location: _defaultDestinationLocation,
              callDocumentLineScreen: _onCallDocumentLineScreen,
            ),
          ),
        );
      }
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
    final double lineQuantity = documentLine.quantity;
    final double remainingQuantity =
        lineQuantity - productCount * containersCount;

    final PickingTask pickingTask =
        Provider.of<PickingTask>(context, listen: false);

    //Create a DocumentLine for each container
    for (int i = 0; i < containersCount; i++) {
      final container_model.Container container = container_model.Container(
        id: Guid.newGuid,
        erpId: '',
        barcode: 'NEW',
        location: _originLocation ?? _destinationLocation!,
      );
      final DocumentLine newDocumentLine = documentLine.copyWith(
        id: Guid.newGuid,
        quantity: productCount,
        container: container,
      );
      pickingTask.document!.lines.add(newDocumentLine);
    }

    if (remainingQuantity > 0) {
      pickingTask.addToDocumentLineQuantity(
        documentLine,
        remainingQuantity - lineQuantity,
      );
    } else {
      await removeFromDocument(documentLine);
    }
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
        if (slidables.child is SingleDocumentLineTile) {
          final SingleDocumentLineTile tile =
              slidables.child as SingleDocumentLineTile;
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

    documentLineToScroll = null;

    showLoadingDisplay('');

    final TaskOperation taskOperation = await handleBarcode(barcode);

    hideLoadingDisplay();

    if (!taskOperation.success) {
      Helper.showMsg(
        'Atenção',
        taskOperation.message,
        context,
      );
    } else {
      await getDocumentLinesList();
    }

    _scrollToDocumentLine();
  }

  Future<void> _onProductSelectedBottomBar(Product product) async {
    documentLineToScroll = null;

    showLoadingDisplay('A adicionar artigo');

    final TaskOperation taskOperation = await addProduct(
      product: product,
    );

    hideLoadingDisplay();

    if (!taskOperation.success) {
      Helper.showMsg(
        'Atenção',
        taskOperation.message,
        context,
      );
    } else {
      await getDocumentLinesList();
    }
    _scrollToDocumentLine();
  }

  Future<void> _onStockChanged(Stock stock, double quantity) async {
    //Check if stock is in the list
    final int index = stockListSelected.indexWhere(
      (element) =>
          element.product.reference == stock.product.reference &&
          element.batch == stock.batch,
    );

    if (index != -1) {
      stockListSelected[index].quantity = quantity;
    } else {
      final Stock stockSelected = stock.copy(quantity: quantity);
      stockListSelected.add(stockSelected);
    }
  }

  Future<void> _onStockSubmitted() async {
    final int selectedStockCount = stockListSelected.length;
    int stockIndex = 0;

    showLoadingDisplay('A adicionar artigo(s)');

    documentLineToScroll = null;

    for (final Stock stock in stockListSelected) {
      stockIndex++;
      showLoadingDisplay(
        'A adicionar artigo(s)\n $stockIndex de $selectedStockCount',
      );
      final TaskOperation taskOperation = await addProduct(
        product: stock.product,
        batch: stock.batch,
        quantity: stock.quantity,
      );
      if (!taskOperation.success) {
        hideLoadingDisplay();
        Helper.showMsg(
          'Atenção',
          taskOperation.message,
          context,
        );
      }
    }

    stockListSelected.clear();

    hideLoadingDisplay();

    await getDocumentLinesList();
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
      case BarCodeType.product:

        //Check if has location
        if (needsLocation()) {
          taskOperation = TaskOperation(
            success: false,
            errorCode: ErrorCode.locationNotSet,
            message: 'Defina primeiro uma localização',
          );
          break;
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

      case BarCodeType.container:
        //Check if has location
        if (needsLocation()) {
          taskOperation = TaskOperation(
            success: false,
            errorCode: ErrorCode.locationNotSet,
            message: 'Defina primeiro uma localização',
          );
          break;
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

      case BarCodeType.location:
        switch (pickingTask.stockMovement) {
          case StockMovement.none:
            return TaskOperation(
              success: false,
              errorCode: ErrorCode.cannotChangeLocation,
              message: 'Erro na configuração da tarefa',
            );
          case StockMovement.inbound:
            if (!_canChangeDestinationLocation &&
                _destinationLocation != null) {
              return TaskOperation(
                success: false,
                errorCode: ErrorCode.cannotChangeLocation,
                message: 'A localização de destino não pode ser alterada',
              );
            }
          case StockMovement.inventory:
            break;
          case StockMovement.transfer:
          case StockMovement.outbound:
            if (!_canChangeOriginLocation && _originLocation != null) {
              return TaskOperation(
                success: false,
                errorCode: ErrorCode.cannotChangeLocation,
                message: 'A localização de origem não pode ser alterada',
              );
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
          switch (pickingTask.stockMovement) {
            case StockMovement.none:
              break;
            case StockMovement.inventory:
            case StockMovement.inbound:
              await setDestinationLocation(location);
            case StockMovement.outbound:
            case StockMovement.transfer:
              await setOriginLocation(location);
          }
        }
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

    //Control Vars
    DocumentLine? sameProductSourceDocumentLine;
    double quantityToAdd = quantity;

    // Handler - Check Location
    if (needsLocation()) {
      return TaskOperation(
        success: false,
        errorCode: ErrorCode.locationNotSet,
        message: 'Defina primeiro uma localização',
      );
    }

    // Create a new Document Line
    final DocumentLine documentLineToAdd =
        pickingTask.createDocumentLineByProduct(
      product: product,
      batch: batch,
    );
    documentLineToAdd.container = container;
    documentLineToAdd.originLocation = _originLocation;
    documentLineToAdd.destinationLocation = _destinationLocation;

    // If usaMolho - GetFull Location Stock
    if (product.usaMolho && batch != null && _originLocation != null) {
      final double stock = await LocationApi.getProductStockByLocation(
        _originLocation!,
        product,
        batch,
      );
      if (stock == 0) {
        return TaskOperation(
          success: false,
          errorCode: ErrorCode.insufficientStock,
          message: 'Não há stock suficiente',
        );
      } else {
        quantityToAdd = stock;
      }
    }

    // Get the fitting Document Line
    final DocumentLine? fittingDocumentLine =
        getFittingDocumentLine(documentLine, documentLineToAdd);
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

    // Get the Batch and Quantity
    if (quantityToAdd == 0 || (batch == null && product.isBatchTracked)) {
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return DocumentLineDialog(
            documentLine: documentLineToAdd,
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
    }

    //====CHECK THE STOCK====
    if (pickingTask.stockMovement == StockMovement.outbound ||
        (pickingTask.stockMovement == StockMovement.transfer)) {
      final bool hasStock = await checkLocationStock(
        _originLocation!,
        product,
        batch,
        quantityToAdd,
      );
      if (!hasStock) {
        return TaskOperation(
          success: false,
          errorCode: ErrorCode.insufficientStock,
          message: 'Não há stock suficiente',
        );
      }
    }

    // Add new documentLine or change existent documentLine
    DocumentLine finalDocumentLine;
    if (fittingDocumentLine == null) {
      finalDocumentLine = documentLineToAdd;
      pickingTask.document!.lines.add(finalDocumentLine);
      if (sameProductSourceDocumentLine != null) {
        finalDocumentLine.linkedLineErpId = sameProductSourceDocumentLine.erpId;
      }
    } else {
      finalDocumentLine = fittingDocumentLine;
      finalDocumentLine.originLocation = documentLineToAdd.originLocation;
      finalDocumentLine.destinationLocation =
          documentLineToAdd.destinationLocation;
      finalDocumentLine.batch = documentLineToAdd.batch;
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

  Future<void> showStockList() async {
    setState(() {
      canPick = false;
    });

    await updateStockList();

    stockListSelected.clear();

    await showModalBottomSheet(
      shape: const RoundedRectangleBorder(),
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) => FractionallySizedBox(
        heightFactor: 1,
        widthFactor: 1,
        child: Drawer(
          backgroundColor: kGreyBackground,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.warehouse,
                              size: 13.0,
                              color: kSecondaryTextColor,
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              getCurrentLocationName(),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(
                                    color: kSecondaryTextColor,
                                  ),
                            ),
                          ],
                        ),
                        //Select All Button
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (stockListSelected.length ==
                                  stockList.length) {
                                stockListSelected.clear();
                              } else {
                                stockListSelected = List.from(stockList);
                              }
                            });
                          },
                          child: Text(
                            stockListSelected.length == stockList.length
                                ? 'Limpar seleção'
                                : 'Selecionar tudo',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Divider(
                      color: kSecondaryTextColor,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Expanded(
                      child: stockList.isEmpty
                          ? Column(
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Center(
                                        child: Icon(
                                          FontAwesomeIcons.folderOpen,
                                          color:
                                              kPrimaryColor.withOpacity(0.15),
                                          size: 150,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20.0,
                                      ),
                                      Center(
                                        child: Text(
                                          'Localização Vazia',
                                          style: TextStyle(
                                            color:
                                                kPrimaryColor.withOpacity(0.4),
                                            fontSize: 20.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              key: ValueKey(stockListSelected.length),
                              itemCount: stockList.length,
                              itemBuilder: (BuildContext context, int index) {
                                final Stock stock = stockList[index];
                                final bool isSelected = stockListSelected.any(
                                  (element) =>
                                      element.product.reference ==
                                          stock.product.reference &&
                                      element.batch == stock.batch,
                                );
                                return StockTile(
                                  stock: stock,
                                  onStockChanged: _onStockChanged,
                                  startsSelected: isSelected,
                                );
                              },
                            ),
                    ),
                    const Divider(
                      color: kSecondaryTextColor,
                    ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            stockListSelected.clear();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancelar',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                                  color: kPrimaryColor.withOpacity(0.8),
                                ),
                          ),
                        ),
                        if (stockList.isNotEmpty)
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await _onStockSubmitted();
                              stockListSelected.clear();
                            },
                            child: Text(
                              'Confirmar seleção',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(
                                    color: stockList.isEmpty
                                        ? kPrimaryColor.withOpacity(0.8)
                                        : kPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    setState(() {
      canPick = true;
    });
  }

  Future<bool> checkLocationStock(
    Location location,
    Product product,
    Batch? batch,
    double quantity,
  ) async {
    bool hasStock = true;

    final double stock =
        await LocationApi.getProductStockByLocation(location, product, batch);

    if (stock < quantity) {
      hasStock = false;
    }

    return hasStock;
  }

  Future<double> getStockInLocation(
    Location location,
    Product product,
    Batch? batch,
  ) async {
    return LocationApi.getProductStockByLocation(location, product, batch);
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

    documentLinesWithFittingLocation = documentLinesWithFittingBatch;

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
      documentLine.originLocation = null;
      documentLine.destinationLocation = null;
      documentLine.batch = null;
      documentLine.container = null;

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
    return _destinationLocation;
  }

  Location? getOriginLocation() {
    return _originLocation;
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

  bool documentHasData() {
    final PickingTask pickingTask = Provider.of<PickingTask>(
      context,
      listen: false,
    );

    if (pickingTask.document == null) {
      return false;
    }

    //Check if document has entity
    if (pickingTask.document!.entity == null) {
      return false;
    }

    //Check if there are lines in the document with quantity
    if (pickingTask.document!.lines.isNotEmpty) {
      for (final DocumentLine documentLine in pickingTask.document!.lines) {
        if (documentLine.quantity > 0) {
          return true;
        }
      }
    }

    return false;
  }

  void exitPickingScreen() {
    final PickingTask pickingTask =
        Provider.of<PickingTask>(context, listen: false);

    pickingTask.clear();
    Navigator.pop(context);
  }

  Future<void> trySave(PickingTask pickingTask, bool canSave) async {
    if (!canSave) {
      return;
    }

    // Set destination location for all products
    if (pickingTask.stockMovement == StockMovement.transfer ||
        pickingTask.stockMovement == StockMovement.inbound) {
      bool isLinesDestinationLocationMissing = false;

      // Check if destination location is missing for at least one document line
      for (final DocumentLine line in pickingTask.document!.lines) {
        if (line.quantity > 0 && line.destinationLocation == null) {
          isLinesDestinationLocationMissing = true;
          break;
        }
      }

      if (isLinesDestinationLocationMissing) {
        final Location? location = await Helper.askLocation(
          'Destino',
          'Faça scan à localização de destino',
          context,
        );

        if (location == null) {
          return;
        }

        for (final DocumentLine line in pickingTask.document!.lines) {
          if (line.quantity > 0) {
            line.destinationLocation ??= location;
          }
        }
      }
    }

    //Check if there are any MiscData that are not filled
    final List<MiscData> miscDataNotFilled = alreadyShowedPostOperationInput
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
          final List<MiscData> miscDataIncomingList = value as List<MiscData>;
          await _onMiscDataChanged(miscDataIncomingList);
        }
      });
      return;
    }

    //Replace task customOptions with miscDataList JSON
    MiscDataHelper.setDocumentExtraData(
      pickingTask,
      documentExtraFieldsList,
    );

    setState(() {
      isSavingToServer = true;
    });

    showLoadingDisplay('A guardar documento');

    final TaskOperation taskOperation = await pickingTask.saveToServer();

    hideLoadingDisplay();

    setState(() {
      isSavingToServer = false;
    });

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

    bool keepPicking = false;
    if (taskOperation.success) {
      if (pickingTask.document!.lines
          .any((element) => element.quantityToPick > 0)) {
        keepPicking = await Helper.askQuestion(
          'Continuar?',
          'O documento ainda não está totalmente satisfeito.\n\nDeseja continuar?',
          context,
        );
      }
      if (keepPicking) {
        showLoadingDisplay('Por favor, aguarde');
        await pickingTask
            .setSourceDocumentsFromList(pickingTask.sourceDocuments);
        await getDocumentLinesList();
        hideLoadingDisplay();
      } else {
        exitPickingScreen();
      }
    }
  }

  Future<void> submitPicking(PickingTask pickingTask, bool canSave) async {
    setState(() {
      canPick = false;
    });
    await trySave(pickingTask, canSave);
    setState(() {
      canPick = true;
    });
  }

  Future<void> _onGroupByNone() async {
    groupDocumentLinesBy = LineGroupType.none;
    await getDocumentLinesList();
  }

  Future<void> _onGroupByProductRef() async {
    groupDocumentLinesBy = LineGroupType.product;
    await getDocumentLinesList();
  }

  Future<void> _onGroupByProductRefAndBatch() async {
    groupDocumentLinesBy = LineGroupType.productBatch;
    await getDocumentLinesList();
  }

  Future<void> _onGroupByContainerBarcode() async {
    groupDocumentLinesBy = LineGroupType.container;
    await getDocumentLinesList();
  }

  @override
  Widget build(BuildContext context) {
    final PickingTask pickingTask = context.watch<PickingTask>();
    final bool needsLocation = this.needsLocation();
    final bool canSave = documentHasData();
    final Location? location = switch (pickingTask.stockMovement) {
      StockMovement.none => null,
      StockMovement.inbound => _destinationLocation,
      StockMovement.outbound => _originLocation,
      StockMovement.inventory => _destinationLocation,
      StockMovement.transfer => _originLocation
    };

    return LoadingDisplay(
      isLoading: showSpinner,
      loadingText: spinnerMessage,
      child: PopScope(
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
          body: BarcodeKeyboardListener(
            onBarcodeScanned: _onBarcodeScanned,
            child: Column(
              children: [
                SelectMenuWidget(
                  entityController: _entityController,
                  sourceDocumentsController: _sourceDocumentsController,
                  onClientTap: () async {
                    if (_canChangeEntity) {
                      await _onChangeEntity();
                    }
                  },
                  onSourceDocumentTap: () async {
                    await _onChangeSourceDocuments();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Divider(
                          height: 2.0,
                          color: needsLocation
                              ? kErrorColor.withOpacity(0.3)
                              : kPrimaryColor.withOpacity(0.2),
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      LocationMenuWidget(
                        needsLocation: needsLocation,
                        currentLocationName: getCurrentLocationName(),
                        destinationLocation: _destinationLocation,
                        originLocation: _originLocation,
                        location: location,
                        onCleanLocation: () {
                          if (location != null) {
                            if (pickingTask.stockMovement ==
                                    StockMovement.inbound ||
                                pickingTask.stockMovement ==
                                    StockMovement.inventory) {
                              if (_canChangeDestinationLocation) {
                                setDestinationLocation(null);
                              } else {
                                Helper.showMsg(
                                  'Atenção',
                                  'A localização de origem não pode ser alterada',
                                  context,
                                );
                              }
                            } else {
                              if (_canChangeOriginLocation) {
                                setOriginLocation(null);
                              } else {
                                Helper.showMsg(
                                  'Atenção',
                                  'A localização de origem não pode ser alterada',
                                  context,
                                );
                              }
                            }
                          }
                        },
                        onSeeStock: () async {
                          await showStockList();
                        },
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: Divider(
                          height: 2.0,
                          color: needsLocation
                              ? kErrorColor.withOpacity(0.3)
                              : kPrimaryColor.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TilesListWidget(
                  listBuild: listBuild,
                  documentTilesList: documentTilesList,
                  listScrollController: _listScrollController,
                  documentLineTiles: documentLineTiles,
                ),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            shape: const CircleBorder(),
            onPressed: () async => submitPicking(pickingTask, canSave),
            backgroundColor:
                canSave ? kPrimaryColor : kPrimaryColor.withOpacity(0.3),
            child: FaIcon(
              isSavingToServer
                  ? FontAwesomeIcons.hourglass
                  : canSave
                      ? FontAwesomeIcons.check
                      : FontAwesomeIcons.ban,
              color: canSave
                  ? kPrimaryColorLight
                  : kPrimaryColorLight.withOpacity(0.5),
            ),
          ),
          bottomNavigationBar: AppBottomBar(
            lineGroupType: groupDocumentLinesBy,
            onBarcodeScan: _onBarcodeScanned,
            onProductSelected: _onProductSelectedBottomBar,
            onStockListCallBack: _onStockListCallBack,
            onMiscDataChanged: _onMiscDataChanged,
            onGetCurrentOriginLocation: _onGetCurrentOriginLocation,
            onGroupByNone: _onGroupByNone,
            onGroupByProductRef: _onGroupByProductRef,
            onGroupByProductRefAndBatch: _onGroupByProductRefAndBatch,
            onGroupByContainerBarcode: _onGroupByContainerBarcode,
            miscDataList: documentExtraFieldsList,
          ),
        ),
      ),
    );
  }
}

class LocationMenuWidget extends StatelessWidget {
  const LocationMenuWidget({
    super.key,
    required this.needsLocation,
    required this.currentLocationName,
    this.destinationLocation,
    this.originLocation,
    this.location,
    required this.onCleanLocation,
    required this.onSeeStock,
  });

  final bool needsLocation;
  final String currentLocationName;
  final Location? destinationLocation;
  final Location? originLocation;
  final Location? location;
  final Function() onCleanLocation;
  final Function() onSeeStock;

  @override
  Widget build(BuildContext context) {
    if (location == null) {
      return LocationRow(
        needsLocation: needsLocation,
        currentLocationName: currentLocationName,
      );
    }

    final PickingTask pickingTask = Provider.of<PickingTask>(
      context,
      listen: false,
    );
    final bool canSeeStock =
        pickingTask.stockMovement == StockMovement.outbound ||
            pickingTask.stockMovement == StockMovement.transfer;

    return Material(
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: MenuAnchor(
        style: MenuStyle(
          backgroundColor: WidgetStateColor.resolveWith(
            (states) => kPrimaryColor,
          ),
        ),
        builder:
            (BuildContext context, MenuController controller, Widget? child) {
          return GestureDetector(
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child: LocationRow(
              needsLocation: needsLocation,
              currentLocationName: currentLocationName,
            ),
          );
        },
        menuChildren: [
          if (canSeeStock)
            MenuItemButton(
              leadingIcon: FaIcon(
                FontAwesomeIcons.boxOpen,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20.0,
              ),
              onPressed: onSeeStock,
              child: Text(
                'Ver stock',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
            ),
          MenuItemButton(
            leadingIcon: FaIcon(
              FontAwesomeIcons.eraser,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20.0,
            ),
            onPressed: onCleanLocation,
            child: Text(
              'Limpar localização',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class LocationRow extends StatelessWidget {
  const LocationRow({
    super.key,
    required this.needsLocation,
    required this.currentLocationName,
  });

  final bool needsLocation;
  final String currentLocationName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FaIcon(
          FontAwesomeIcons.warehouse,
          size: 13.0,
          color: needsLocation
              ? kErrorColor.withOpacity(0.3)
              : kSecondaryTextColor,
        ),
        const SizedBox(
          width: 10.0,
        ),
        Text(
          currentLocationName,
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: needsLocation
                    ? kErrorColor.withOpacity(0.5)
                    : kSecondaryTextColor,
              ),
        ),
      ],
    );
  }
}

class SelectMenuWidget extends StatelessWidget {
  const SelectMenuWidget({
    super.key,
    required this.entityController,
    required this.sourceDocumentsController,
    required this.onClientTap,
    required this.onSourceDocumentTap,
  });

  final TextEditingController entityController;
  final TextEditingController sourceDocumentsController;
  final Function() onClientTap;
  final Function() onSourceDocumentTap;

  @override
  Widget build(BuildContext context) {
    final PickingTask pickingTask = Provider.of<PickingTask>(
      context,
      listen: false,
    );

    return Container(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: entityController,
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
            onTap: onClientTap,
          ),
          if (pickingTask.originDocumentType != null)
            Column(
              children: [
                const SizedBox(
                  height: 15.0,
                ),
                TextField(
                  style: Theme.of(context).textTheme.labelSmall,
                  decoration: kPickTextFieldsInputDecoration.copyWith(
                    hintText: 'Escolha os documentos de origem',
                    prefixIcon: const Icon(
                      FontAwesomeIcons.book,
                      size: 15.0,
                      color: kPrimaryColorDark,
                    ),
                  ),
                  controller: sourceDocumentsController,
                  readOnly: true,
                  onTap: onSourceDocumentTap,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class TilesListWidget extends StatelessWidget {
  const TilesListWidget({
    super.key,
    required this.listBuild,
    required this.documentTilesList,
    required this.listScrollController,
    required this.documentLineTiles,
  });

  final Future<bool> listBuild;
  final Column documentTilesList;
  final ItemScrollController listScrollController;
  final List<Widget> documentLineTiles;

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 75.0,
                              ),
                              child: Center(
                                child: Icon(
                                  FontAwesomeIcons.barsStaggered,
                                  color: kPrimaryColor.withOpacity(0.15),
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
                          itemScrollController: listScrollController,
                          itemCount: documentLineTiles.length,
                          itemBuilder: (BuildContext context, int index) {
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
    );
  }
}
