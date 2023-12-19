import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:n6picking_flutterapp/components/bottom_app_bar.dart';
import 'package:n6picking_flutterapp/components/document_line_dialog.dart';
import 'package:n6picking_flutterapp/components/document_line_tile.dart';
import 'package:n6picking_flutterapp/models/batch_model.dart';
import 'package:n6picking_flutterapp/models/document_line_model.dart';
import 'package:n6picking_flutterapp/models/document_model.dart';
import 'package:n6picking_flutterapp/models/location_model.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';
import 'package:n6picking_flutterapp/models/product_model.dart';
import 'package:n6picking_flutterapp/screens/document_line_screen.dart';
import 'package:n6picking_flutterapp/screens/source_documents_screen.dart';
import 'package:n6picking_flutterapp/screens/source_entity_screen.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:n6picking_flutterapp/utilities/helper.dart';
import 'package:n6picking_flutterapp/utilities/system.dart';
import 'package:n6picking_flutterapp/utilities/task_operation.dart';
import 'package:provider/provider.dart';

class PickingScreen extends StatefulWidget {
  static const String id = 'picking_screen_id';

  @override
  State<PickingScreen> createState() => _PickingScreenState();
}

class _PickingScreenState extends State<PickingScreen> {
  bool showSpinner = false;
  bool isSavingToServer = false;
  bool canPick = false;

  //Location variables
  bool _useLocations = false;
  bool _isTransfer = false;
  Location? _fromLocation;
  Location? _toLocation;
  bool _forceFromLocation = false;
  bool _forceToLocation = false;

  //Entity variables
  late bool _canChangeEntity;

  //TextControllers
  late TextEditingController _entityController;
  late TextEditingController _sourceDocumentsController;
  late TextEditingController _fromLocationController;
  late TextEditingController _toLocationController;

  //ScrollControllers
  late ScrollController _listScrollController;

  //FutureBuilder
  List<Widget> documentLineTiles = [];
  Column documentTilesList = const Column();
  late Future<bool> listBuild;
  List<DocumentLine> documentLineList = [];

  @override
  void initState() {
    super.initState();
    setup();
  }

  Future<void> setup() async {
    final PickingTask pickingTask =
        // ignore: use_build_context_synchronously
        Provider.of<PickingTask>(context, listen: false);

    _entityController = TextEditingController();
    _sourceDocumentsController = TextEditingController();
    _fromLocationController = TextEditingController();
    _toLocationController = TextEditingController();
    _listScrollController = ScrollController();

    await getDocumentLinesList();

    //Set default entity if StockMovement is Internal
    if (pickingTask.stockMovement == StockMovement.transfer ||
        pickingTask.stockMovement == StockMovement.inventory) {
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

    //Locations
    switch (pickingTask.stockMovement) {
      case StockMovement.inbound:
        final Location? location = LocationApi.getByErpId(
          'ALV22120258773.125352084',
          LocationApi.instance.allLocations,
        );
        setState(() {
          _useLocations = true;
          _isTransfer = false;
          _forceFromLocation = false;
          _forceToLocation = true;
          _toLocation = location;
          _toLocationController.text = getLocationName(_toLocation);
        });

        break;
      case StockMovement.outbound:
        setState(() {
          _useLocations = true;
          _isTransfer = false;
          _forceFromLocation = false;
          _forceToLocation = false;
        });

        break;
      case StockMovement.transfer:
        setState(() {
          _useLocations = true;
          _isTransfer = true;
          _forceFromLocation = false;
          _forceToLocation = false;
        });
        break;
      case StockMovement.inventory:
        setState(() {
          _useLocations = true;
          _isTransfer = false;
          _forceFromLocation = false;
          _forceToLocation = false;
        });

        break;
    }
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

  @override
  void dispose() {
    _entityController.dispose();
    _sourceDocumentsController.dispose();
    _fromLocationController.dispose();
    _toLocationController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  void setLocation(Location location) {
    setState(() {
      _toLocation = location;
      _toLocationController.text = getLocationName(_toLocation);
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
        DocumentLineTile(
            documentLine: documentLine,
            location: _toLocation,
            callDocumentLineScreen: _onCallDocumentLineScreen),
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
    setState(() {});
  }

  Future<void> _onSplitBatches(
    DocumentLine documentLine,
    List<double> batchData,
  ) async {
    final PickingTask pickingTask =
        Provider.of<PickingTask>(context, listen: false);

    await splitBatches(
      documentLine,
      batchData,
    );

    await getDocumentLinesList();
    _scrollToBottom();
    setState(() {});
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

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

    final DocumentLine oldDocumentLine = line.copyWith();
    pickingTask.document!.lines.removeWhere((element) => element.id == line.id);

    for (final Batch batch in newLines) {
      final double quantity = double.tryParse(batch.erpId!) ?? 0;

      addProduct(
        product: oldDocumentLine.product,
        location: _toLocation,
        batch: batch,
        quantity: quantity,
      );

      final DocumentLine documentLine = pickingTask.document!.lines.last;
      documentLine.linkedLineErpId = oldDocumentLine.erpId;
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

    final TaskOperation taskOperation = await handleBarcode(barcode);

    if (!taskOperation.success) {
      // ignore: use_build_context_synchronously
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
    Product? product;
    Batch? batch;

    //TODO - Check if barcode is valid

    switch (barCodeType) {
      case BarCodeType.unknown:
        taskOperation = TaskOperation(
          success: false,
          errorCode: ErrorCode.invalidBarcode,
          message: 'Código de barras não é válido',
        );
        break;
      case BarCodeType.product:
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
            location: _toLocation,
          );
        }
        break;
      case BarCodeType.batch:
        //Json with product ref and batch number
        //{"ref":"000","lote":"000"}
        final Map<String, dynamic> json =
            jsonDecode(barcode) as Map<String, dynamic>;
        final String productRef = json['ref'] as String;
        final String batchNumber = json['lote'] as String;
        product = ProductHelper.getProduct(
          reference: productRef,
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
          if (batch == null) {
            taskOperation = TaskOperation(
              success: false,
              errorCode: ErrorCode.batchNotFound,
              message: 'Lote não encontrado',
            );
          } else {
            taskOperation = await addProduct(
              product: product,
              batch: batch,
              location: _toLocation,
            );
          }
        }

        break;
      case BarCodeType.container:
        break;
      case BarCodeType.location:
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
          setLocation(location);
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
    Location? location,
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
    final List<DocumentLine> documentLines = pickingTask.document!.lines
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

                      // Botch Batch tracked but neither have batch
                      ||
                      (product.isBatchTracked &&
                          documentLineToAdd.batch == null &&
                          element.batch == null)) &&
              //Location
              (
                  //Both without location
                  (documentLineToAdd.destinationLocation == null &&
                          element.destinationLocation == null) ||
                      //Both in the same location
                      (documentLineToAdd.destinationLocation != null &&
                          element.destinationLocation != null &&
                          documentLineToAdd.destinationLocation!.erpId ==
                              element.destinationLocation!.erpId) ||

                      //Element without location and documentLine with location
                      (documentLineToAdd.destinationLocation != null &&
                          element.destinationLocation == null)),
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
      if (location != null) {
        finalDocumentLine.destinationLocation = location;
      }
    } else {
      finalDocumentLine = documentLines.firstWhereOrNull(
            (element) =>
                element.quantity + element.quantityPicked < element.quantity,
          ) ??
          documentLines.first;
      finalDocumentLine.batch = documentLineToAdd.batch;
      if (location != null) {
        finalDocumentLine.destinationLocation = location;
      }
      quantityToAdd = documentLineToAdd.quantity;
    }

    return pickingTask.changeDocumentLineQuantity(
      finalDocumentLine,
      quantityToAdd,
    );
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
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              GestureDetector(
                onTap: () {
                  exitPickingScreen();
                },
                child: const FaIcon(
                  FontAwesomeIcons.angleLeft,
                  color: kPrimaryColorLight,
                ),
              ),
              const SizedBox(
                width: 15.0,
              ),
              Text(
                pickingTask.name,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: kPrimaryColorLight,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
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
                      if (_useLocations)
                        const SizedBox(
                          height: 15.0,
                        ),
                      if (pickingTask.stockMovement == StockMovement.inbound ||
                          pickingTask.stockMovement == StockMovement.inventory)
                        Text(
                          ' Localização: ${_toLocation != null ? _toLocation!.name : '(Nenhuma)'}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  child: Divider(
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
                            : SingleChildScrollView(
                                controller: _listScrollController,
                                child: documentTilesList,
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
            setState(() {
              isSavingToServer = true;
              showSpinner = true;
            });

            final TaskOperation taskOperation =
                await pickingTask.saveToServer();

            if (!taskOperation.success) {
              // ignore: use_build_context_synchronously
              await Helper.showMsg(
                'Atenção',
                taskOperation.message,
                context,
              );
            } else {
              // ignore: use_build_context_synchronously
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
        ),
      ),
    );
  }
}
