import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:n6picking_flutterapp/components/bottom_app_bar.dart';
import 'package:n6picking_flutterapp/components/document_line_tile.dart';
import 'package:n6picking_flutterapp/models/document_line_model.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';
import 'package:n6picking_flutterapp/screens/source_documents_screen.dart';
import 'package:n6picking_flutterapp/screens/source_entity_screen.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
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

  //TextControllers
  late TextEditingController _entityController;
  late TextEditingController _sourceDocumentsController;

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

  void setup() {
    _entityController = TextEditingController();
    _sourceDocumentsController = TextEditingController();
    _listScrollController = ScrollController();
    getDocumentLinesList();
  }

  @override
  void dispose() {
    _entityController.dispose();
    _sourceDocumentsController.dispose();
    _listScrollController.dispose();
    super.dispose();
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
        ),
      );
    }

    documentTilesList = Column(
      children: documentLineTiles,
    );

    return true;
  }

  Future<TaskOperation> _onBarcodeScanned(String barcode) async {
    setState(() {
      showSpinner = true;
    });
    debugPrint(barcode);
    //TODO
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      showSpinner = false;
    });

    return TaskOperation(
      success: true,
      errorCode: ErrorCode.none,
      message: '',
    );
  }

  Future<void> _onChangeEntity() async {
    await Navigator.pushNamed(context, SourceEntityScreen.id);
    setState(() {
      _entityController.text = getEntityName();
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
    await Navigator.pushNamed(context, SourceDocumentsScreen.id);
    setState(() {
      _sourceDocumentsController.text = getSourceDocumentsName();
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

  Future<void> exitPickingScreen() async {
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
                onTap: () async {
                  await exitPickingScreen();
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
                          await _onChangeEntity();
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
            //Wait 1 second to simulate a request
            setState(() {
              isSavingToServer = true;
            });
            await Future.delayed(const Duration(seconds: 1));
            setState(() {
              isSavingToServer = false;
            });
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
