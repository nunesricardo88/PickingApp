import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:n6picking_flutterapp/components/manual_barcode_box.dart';
import 'package:n6picking_flutterapp/models/product_model.dart';
import 'package:n6picking_flutterapp/screens/camera_screen.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';

class DrawerRightMenu extends StatefulWidget {
  const DrawerRightMenu({
    super.key,
    required this.onBarcodeScanned,
    required this.onProductSelected,
  });

  final Future<void> Function(String) onBarcodeScanned;
  final Future<void> Function(Product) onProductSelected;

  @override
  _SidebarRightMenu createState() => _SidebarRightMenu();
}

class _SidebarRightMenu extends State<DrawerRightMenu> {
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: kGreyBackground,
            ),
            child: Text(
              'Alternativas',
              style: TextStyle(fontSize: 24),
            ),
          ),
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.camera,
            ),
            title: Text(
              'Usar câmara',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CameraScreen(onBarcodeScan: widget.onBarcodeScanned),
                ),
              );
            },
          ),
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.keyboard,
            ),
            title: Text(
              'Código manual',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onTap: () async {
              await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return ManualBarcodeBox();
                },
              ).then((barcode) async {
                if (barcode is String) {
                  if (barcode.isNotEmpty) {
                    await widget.onBarcodeScanned(barcode);
                  }
                }
              });
            },
          ),
          ListTile(
            leading: const FaIcon(
              FontAwesomeIcons.magnifyingGlass,
            ),
            title: Text(
              'Procurar artigo',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onTap: () async {
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
                          return ProductLine(
                            filteredProductList: filteredProductList,
                            searchProductController: searchProductController,
                            onProductSelected: widget.onProductSelected,
                            onSeeAll: () {
                              setState(() {
                                showAllProducts = true;
                              });
                            },
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
}

class ProductLine extends StatelessWidget {
  const ProductLine({
    super.key,
    required this.filteredProductList,
    required this.searchProductController,
    required this.onProductSelected,
    required this.onSeeAll,
  });

  final List<Product> filteredProductList;
  final TextEditingController searchProductController;
  final Future<void> Function(Product) onProductSelected;
  final Function() onSeeAll;

  @override
  Widget build(BuildContext context) {
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        searchProductController.text.isNotEmpty
                            ? 'Sem resultados'
                            : 'Pesquise por um artigo',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: kPrimaryColor,
                            ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      GestureDetector(
                        onTap: onSeeAll,
                        child: Text(
                          'Ver todos',
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: kPrimaryColor,
                                    decoration: TextDecoration.underline,
                                  ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filteredProductList.length,
                  itemBuilder: (context, index) {
                    final Product product = filteredProductList[index];
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
                            onProductSelected(
                              product,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(
                              8.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        product.designation,
                                      ),
                                      const SizedBox(
                                        height: 5.0,
                                      ),
                                      Opacity(
                                        opacity: 0.6,
                                        child: Text(
                                          product.reference,
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
  }
}
