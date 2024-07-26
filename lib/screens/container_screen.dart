import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:n6picking_flutterapp/components/document_line_property_tile.dart';
import 'package:n6picking_flutterapp/components/document_line_tile.dart';
import 'package:n6picking_flutterapp/components/loading_display.dart';
import 'package:n6picking_flutterapp/models/container_model.dart'
    as container_model;
import 'package:n6picking_flutterapp/models/container_product_model.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:n6picking_flutterapp/utilities/helper.dart';
import 'package:n6picking_flutterapp/utilities/task_operation.dart';
import 'package:pinput/pinput.dart';

class ContainerScreen extends StatefulWidget {
  const ContainerScreen({
    required this.container,
  });

  final container_model.Container container;

  @override
  _ContainerScreenState createState() => _ContainerScreenState();
}

class _ContainerScreenState extends State<ContainerScreen> {
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _depthController = TextEditingController();

  late Future<List<ContainerProduct>> containerProductsFuture;
  final List<Widget> productListTiles = [];

  bool showSpinner = false;
  String spinnerMessage = 'Por favor, aguarde';

  @override
  void initState() {
    super.initState();
    setup();
  }

  void setup() {
    // calculatedValue = widget.documentLine.quantity;
    _widthController.setText(
      Helper.removeDecimalZeroFormat(widget.container.width),
    );
    _heightController.setText(
      Helper.removeDecimalZeroFormat(widget.container.height),
    );
    _depthController.setText(
      Helper.removeDecimalZeroFormat(widget.container.depth),
    );

    containerProductsFuture = getContainerProducts();
  }

  Future<List<ContainerProduct>> getContainerProducts() async {
    try {
      final List<ContainerProduct> containerProducts =
          await ContainerProductApi.getByContainerErpId(
        widget.container.erpId!,
      );

      for (final ContainerProduct containerProduct in containerProducts) {
        productListTiles.add(
          DocumentLineTileCard(
            designation: containerProduct.product.designation,
            reference: containerProduct.product.reference,
            quantity: containerProduct.quantity,
            unit: containerProduct.product.unit,
            product: containerProduct.product,
          ),
        );
      }

      return containerProducts;
    } catch (error) {
      throw Exception('Failed to load container products: $error');
    }
  }

  void showLoadingDisplay(String message) {
    setState(() {
      showSpinner = true;
      spinnerMessage = message;
    });
  }

  void hideLoadingDisplay() {
    setState(() {
      showSpinner = false;
    });
  }

  Future<TaskOperation> changeQuantity() async {
    try {
      setState(() {
        widget.container.width = double.parse(_widthController.text);
        widget.container.height = double.parse(_heightController.text);
        widget.container.depth = double.parse(_depthController.text);
      });
    } catch (error) {
      return TaskOperation(
        success: false,
        message: error.toString(),
        errorCode: ErrorCode.unknownError,
      );
    }

    return TaskOperation(
      success: true,
      errorCode: ErrorCode.none,
      message: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: LoadingDisplay(
        isLoading: showSpinner,
        loadingText: spinnerMessage,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: kGreyBackground,
          appBar: AppBar(
            backgroundColor: kPrimaryColor,
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
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
              'Editar container',
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: kPrimaryColorLight,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            titleSpacing: 0.0,
            elevation: 10,
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: kWhiteBackground,
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 6.0,
                      ),
                      child: Column(
                        children: [
                          DocumentLinePropertyTile(
                            title: 'Código de barras',
                            value: widget.container.barcode,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Material(
                    color: kWhiteBackground,
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text('Largura'),
                          TextField(
                            controller: _widthController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            textAlign: TextAlign.end,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onTap: () {
                              _widthController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: _widthController.text.length,
                              );
                            },
                          ),
                          const Text('Altura'),
                          TextField(
                            controller: _heightController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            textAlign: TextAlign.end,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onTap: () {
                              _heightController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: _heightController.text.length,
                              );
                            },
                          ),
                          const Text('Profundidade'),
                          TextField(
                            controller: _depthController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            textAlign: TextAlign.end,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onTap: () {
                              _depthController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: _depthController.text.length,
                              );
                            },
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MaterialButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Cancelar',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .copyWith(
                                            color:
                                                kPrimaryColor.withOpacity(0.8),
                                          ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 40,
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimaryColor,
                                      surfaceTintColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    onPressed: () async {
                                      final TaskOperation taskOperation =
                                          await changeQuantity();

                                      if (taskOperation.success) {
                                        Navigator.pop(context);
                                      } else {
                                        await Helper.showMsg(
                                          'Atenção',
                                          taskOperation.message,
                                          context,
                                        );
                                      }
                                    },
                                    child: Text(
                                      'Submeter',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .copyWith(
                                            color: kWhiteBackground,
                                            fontWeight: FontWeight.w400,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Material(
                    color: kWhiteBackground,
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: FutureBuilder<List<ContainerProduct>>(
                      future: containerProductsFuture,
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<List<ContainerProduct>> snapshot,
                      ) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child:
                                CircularProgressIndicator(color: kPrimaryColor),
                          );
                        } else if (snapshot.hasError) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: kPrimaryColor.withOpacity(0.6),
                                size: 50,
                              ),
                              const SizedBox(height: 20.0),
                              Text(
                                snapshot.error.toString(),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        } else if (snapshot.hasData) {
                          final List<Widget> productTiles = productListTiles
                                  .isNotEmpty
                              ? productListTiles
                              : [
                                  Center(
                                    child: Icon(
                                      FontAwesomeIcons.barsStaggered,
                                      color: kPrimaryColor.withOpacity(0.15),
                                      size: 150,
                                    ),
                                  ),
                                ];
                          return Column(
                            children: List.generate(
                              productTiles.length,
                              (index) => productTiles[index],
                            ).toList(),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 5,
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
