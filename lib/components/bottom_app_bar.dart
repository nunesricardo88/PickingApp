import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:n6picking_flutterapp/components/manual_barcode_box.dart';
import 'package:n6picking_flutterapp/models/product_model.dart';
import 'package:n6picking_flutterapp/screens/camera_screen.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';

class AppBottomBar extends StatefulWidget {
  const AppBottomBar({
    this.fabLocation = FloatingActionButtonLocation.centerDocked,
    this.shape = const CircularNotchedRectangle(),
    required this.onBarcodeScan,
    required this.onProductSelected,
  });

  final FloatingActionButtonLocation fabLocation;
  final NotchedShape? shape;
  final Future<void> Function(String) onBarcodeScan;
  final Future<void> Function(Product) onProductSelected;
  @override
  _AppBottomBarState createState() => _AppBottomBarState();
}

class _AppBottomBarState extends State<AppBottomBar> {
  TextEditingController searchProductController = TextEditingController();
  List<Product> productList = [];

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

  void initializeProductList() {
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
    }
    return filteredList;
  }

  Widget getLeftButton() {
    return Material(
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: MenuAnchor(
        style: MenuStyle(
          backgroundColor: MaterialStateColor.resolveWith(
            (states) => kPrimaryColor,
          ),
        ),
        builder:
            (BuildContext context, MenuController controller, Widget? child) {
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
          MenuItemButton(
            leadingIcon: FaIcon(
              FontAwesomeIcons.objectUngroup,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20.0,
            ),
            child: Text(
              'Agrupamento',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
            onPressed: () async {},
          ),
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
          backgroundColor: MaterialStateColor.resolveWith(
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
            onPressed: () {
              showModalBottomSheet(
                shape: const RoundedRectangleBorder(),
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) => FractionallySizedBox(
                  heightFactor: 0.8,
                  widthFactor: 1,
                  child: Drawer(
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
                                  suffixIcon: FaIcon(
                                    FontAwesomeIcons.magnifyingGlass,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Expanded(
                                child: filteredProductList.isEmpty
                                    ? Center(
                                        child: Text(
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
                                      )
                                    : ListView.builder(
                                        itemCount: filteredProductList.length,
                                        itemBuilder: (context, index) {
                                          final Product product =
                                              filteredProductList[index];
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.pop(
                                                context,
                                              );
                                              widget.onProductSelected(product);
                                            },
                                            child: Card(
                                              color: kWhiteBackground,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
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
                                                            product.designation,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          const SizedBox(
                                                            height: 5.0,
                                                          ),
                                                          Opacity(
                                                            opacity: 0.6,
                                                            child: Text(
                                                              product.reference,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
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
