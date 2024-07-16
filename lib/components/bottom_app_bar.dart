// ignore_for_file: use_build_context_synchronously
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:n6picking_flutterapp/components/manual_barcode_box.dart';
import 'package:n6picking_flutterapp/models/location_model.dart';
import 'package:n6picking_flutterapp/models/misc_data_model.dart';
import 'package:n6picking_flutterapp/models/product_model.dart';
import 'package:n6picking_flutterapp/models/stock_model.dart';
import 'package:n6picking_flutterapp/screens/camera_screen.dart';
import 'package:n6picking_flutterapp/screens/misc_data_screen.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';

class AppBottomBar extends StatefulWidget {
  const AppBottomBar({
    this.fabLocation = FloatingActionButtonLocation.centerDocked,
    this.shape = const CircularNotchedRectangle(),
    this.lineGroupType = LineGroupType.none,
    required this.onBarcodeScan,
    required this.onProductSelected,
    required this.onStockListCallBack,
    required this.onMiscDataChanged,
    required this.onGetCurrentOriginLocation,
    required this.onGroupByNone,
    required this.onGroupByProductRef,
    required this.onGroupByProductRefAndBatch,
    required this.onGroupByContainerBarcode,
    required this.miscDataList,
  });

  final FloatingActionButtonLocation fabLocation;
  final NotchedShape? shape;
  final LineGroupType lineGroupType;
  final Future<void> Function(String) onBarcodeScan;
  final Future<void> Function(Product) onProductSelected;
  final List<Stock> Function() onStockListCallBack;
  final Future<void> Function(List<MiscData>) onMiscDataChanged;
  final Location? Function() onGetCurrentOriginLocation;
  final Future<void> Function() onGroupByNone;
  final Future<void> Function() onGroupByProductRef;
  final Future<void> Function() onGroupByProductRefAndBatch;
  final Future<void> Function() onGroupByContainerBarcode;
  final List<MiscData> miscDataList;
  @override
  _AppBottomBarState createState() => _AppBottomBarState();
}

class _AppBottomBarState extends State<AppBottomBar> {
  TextEditingController searchProductController = TextEditingController();
  List<Product> productList = [];
  bool showAllProducts = true;

  @override
  void initState() {
    super.initState();
    initializeProductList();
    searchProductController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchProductController.dispose();
    super.dispose();
  }

  Future<void> initializeProductList() async {
    productList = ProductApi.instance.allProducts;
  }

  List<Product> filterProductList(String query) {
    List<Product> filteredList = [];
    if (query.isNotEmpty) {
      filteredList = productList
          .where(
            (product) =>
                product.reference.toLowerCase().contains(query.toLowerCase()) ||
                product.designation.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } else if (showAllProducts) {
      filteredList = productList;
    }
    return filteredList;
  }

  Widget getGroupByButton() {
    final VisualDensity density = Theme.of(context).visualDensity;
    final double horizontalPadding = math.max(
      4,
      12 + density.horizontal * 2,
    );

    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStateColor.resolveWith(
          (states) => kPrimaryColor,
        ),
      ),
      builder: (
        BuildContext context,
        MenuController controller,
        Widget? child,
      ) {
        return TextButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FaIcon(
                    FontAwesomeIcons.filter,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 20.0,
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: horizontalPadding,
                    ),
                    child: Text(
                      'Agrupar',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
      menuChildren: [
        MenuItemButton(
          style: MenuItemButton.styleFrom(
            backgroundColor: widget.lineGroupType == LineGroupType.product
                ? kPrimaryColorDark
                : kPrimaryColor,
          ),
          leadingIcon: FaIcon(
            FontAwesomeIcons.filter,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 20.0,
          ),
          child: Text(
            'Agrupar por referência',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          onPressed: () async {
            widget.onGroupByProductRef();
          },
        ),
        MenuItemButton(
          style: MenuItemButton.styleFrom(
            backgroundColor: widget.lineGroupType == LineGroupType.productBatch
                ? kPrimaryColorDark
                : kPrimaryColor,
          ),
          leadingIcon: FaIcon(
            FontAwesomeIcons.filter,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 20.0,
          ),
          child: Text(
            'Agrupar por referência e lote',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          onPressed: () async {
            widget.onGroupByProductRefAndBatch();
          },
        ),
        MenuItemButton(
          style: MenuItemButton.styleFrom(
            backgroundColor: widget.lineGroupType == LineGroupType.container
                ? kPrimaryColorDark
                : kPrimaryColor,
          ),
          leadingIcon: FaIcon(
            FontAwesomeIcons.filter,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 20.0,
          ),
          child: Text(
            'Agrupar por container',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          onPressed: () async {
            widget.onGroupByContainerBarcode();
          },
        ),
        MenuItemButton(
          style: MenuItemButton.styleFrom(
            backgroundColor: widget.lineGroupType == LineGroupType.none
                ? kPrimaryColorDark
                : kPrimaryColor,
          ),
          leadingIcon: FaIcon(
            FontAwesomeIcons.filterCircleXmark,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 20.0,
          ),
          child: Text(
            'Desagrupar',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          onPressed: () async {
            widget.onGroupByNone();
          },
        ),
      ],
    );
  }

  Widget getLeftButton() {
    return Material(
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: MenuAnchor(
        style: MenuStyle(
          backgroundColor: WidgetStateColor.resolveWith(
            (states) => kPrimaryColor,
          ),
        ),
        builder: (
          BuildContext context,
          MenuController controller,
          Widget? child,
        ) {
          return IconButton(
            icon: FaIcon(
              FontAwesomeIcons.bars,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 30.0,
            ),
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
          );
        },
        menuChildren: [
          if (widget.miscDataList.isNotEmpty)
            MenuItemButton(
              leadingIcon: FaIcon(
                FontAwesomeIcons.penToSquare,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20.0,
              ),
              child: Text(
                'Outros dados',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MiscDataScreen(
                      miscDataList: widget.miscDataList,
                    ),
                  ),
                ).then(
                  (value) {
                    if (value is List<MiscData>) {
                      widget.onMiscDataChanged(value);
                    }
                  },
                );
              },
            ),
          getGroupByButton(),
        ],
      ),
    );
  }

  Widget getRightButton() {
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
          return IconButton(
            icon: FaIcon(
              FontAwesomeIcons.qrcode,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 30.0,
            ),
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
          );
        },
        menuChildren: [
          MenuItemButton(
            leadingIcon: FaIcon(
              FontAwesomeIcons.camera,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20.0,
            ),
            child: Text(
              'Usar câmara',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CameraScreen(onBarcodeScan: widget.onBarcodeScan),
                ),
              );
            },
          ),
          MenuItemButton(
            leadingIcon: FaIcon(
              FontAwesomeIcons.keyboard,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20.0,
            ),
            child: Text(
              'Código manual',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
            onPressed: () async {
              await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return ManualBarcodeBox();
                },
              ).then((barcode) async {
                if (barcode is String) {
                  if (barcode.isNotEmpty) {
                    await widget.onBarcodeScan(barcode);
                  }
                }
              });
            },
          ),
          MenuItemButton(
            leadingIcon: FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20.0,
            ),
            child: Text(
              'Procurar artigo',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
            onPressed: () async {
              showModalBottomSheet(
                shape: const RoundedRectangleBorder(),
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) => FractionallySizedBox(
                  heightFactor: 0.9,
                  widthFactor: 1,
                  child: Drawer(
                    backgroundColor: kWhiteBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          final List<Product> filteredProductList =
                              filterProductList(
                            searchProductController.text,
                          );
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: searchProductController,
                                keyboardType: TextInputType.name,
                                onEditingComplete: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Procurar artigo',
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Expanded(
                                child: filteredProductList.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              searchProductController
                                                      .text.isNotEmpty
                                                  ? 'Sem resultados'
                                                  : 'Pesquise por um artigo',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                    color: kPrimaryColor,
                                                  ),
                                            ),
                                            const SizedBox(
                                              height: 10.0,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  showAllProducts = true;
                                                });
                                              },
                                              child: Text(
                                                'Ver todos',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      color: kPrimaryColor,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: filteredProductList.length,
                                        itemBuilder: (context, index) {
                                          final Product product =
                                              filteredProductList[index];
                                          return Column(
                                            children: [
                                              if (index == 0)
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                              if (index > 0)
                                                const Divider(
                                                  thickness: 1.0,
                                                ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(
                                                    context,
                                                  );
                                                  widget.onProductSelected(
                                                    product,
                                                  );
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .stretch,
                                                          children: [
                                                            Text(
                                                              product
                                                                  .designation,
                                                            ),
                                                            const SizedBox(
                                                              height: 5.0,
                                                            ),
                                                            Opacity(
                                                              opacity: 0.6,
                                                              child: Text(
                                                                product
                                                                    .reference,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 60.0,
      shape: widget.shape,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      color: kPrimaryColor,
      surfaceTintColor: Colors.transparent,
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            getLeftButton(),
            getRightButton(),
          ],
        ),
      ),
    );
  }
}
