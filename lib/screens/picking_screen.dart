import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';
import 'package:n6picking_flutterapp/screens/source_entity_screen.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:provider/provider.dart';

class PickingScreen extends StatefulWidget {
  static const String id = 'picking_screen_id';

  @override
  State<PickingScreen> createState() => _PickingScreenState();
}

class _PickingScreenState extends State<PickingScreen> {
  bool showSpinner = false;

  //TextControllers
  late TextEditingController _entityController;
  late TextEditingController _sourceDocumentsController;

  @override
  void initState() {
    super.initState();

    _entityController = TextEditingController();
    _sourceDocumentsController = TextEditingController();
  }

  @override
  void dispose() {
    _entityController.dispose();
    _sourceDocumentsController.dispose();
    super.dispose();
  }

  Future<void> _onBarcodeScanned(String barcode) async {
    setState(() {
      showSpinner = true;
    });
    //TODO
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      showSpinner = false;
    });
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
    //TODO
    await Future.delayed(const Duration(seconds: 1));
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
        backgroundColor: kWhiteBackground,
        appBar: AppBar(
          backgroundColor: kPrimaryColorDark,
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
                  decoration: const BoxDecoration(
                    color: kPrimaryColorLight,
                    border: Border(
                      bottom: BorderSide(
                        color: kPrimaryColorDark,
                      ),
                    ),
                  ),
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
                const Expanded(
                  child: ColoredBox(
                    color: kWhiteBackground,
                    child: Center(
                      child: Text('Linhas'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
