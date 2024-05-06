import 'dart:convert';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:http/http.dart' as http;
import 'package:n6picking_flutterapp/models/container_model.dart';
import 'package:n6picking_flutterapp/models/product_model.dart';
import 'package:n6picking_flutterapp/services/api_endpoint.dart';
import 'package:n6picking_flutterapp/services/networking.dart';

mixin ContainerProductFields {
  static final List<String> allValues = [
    id,
    erpId,
    container,
    product,
    quantity,
  ];

  static const String id = 'id';
  static const String erpId = 'erpId';
  static const String container = 'container';
  static const String product = 'product';
  static const String quantity = 'quantity';
}

class ContainerProduct {
  Guid id;
  String? erpId;
  Container container;
  Product product;
  double quantity;

  ContainerProduct({
    required this.id,
    this.erpId,
    required this.container,
    required this.product,
    this.quantity = 0.0,
  });

  factory ContainerProduct.fromJson(Map<String, dynamic> json) =>
      ContainerProduct(
        id: Guid(json[ContainerProductFields.id] as String),
        erpId: json[ContainerProductFields.erpId] as String,
        container: Container.fromJson(
          json[ContainerProductFields.container] as Map<String, dynamic>,
        ),
        product: Product.fromJson(
          json[ContainerProductFields.product] as Map<String, dynamic>,
        ),
        quantity: json[ContainerProductFields.quantity] as double,
      );

  Map<String, dynamic> toJson() => {
        ContainerProductFields.id: id.toString(),
        ContainerProductFields.erpId: erpId,
        ContainerProductFields.container: container.toJson(),
        ContainerProductFields.product: product.toJson(),
        ContainerProductFields.quantity: quantity,
      };
}

mixin ContainerProductApi {
  static Future<List<ContainerProduct>> getByContainerErpId(
    String containerErpId,
  ) async {
    final String url =
        ApiEndPoint.getContainerProductsByContainerErpId(containerErpId);
    List<ContainerProduct> containerProducts = [];
    final NetworkHelper networkHelper = NetworkHelper(url);
    final http.Response response =
        await networkHelper.getData(seconds: 10) as http.Response;

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      if (jsonBody['result'] != null) {
        final Iterable l = jsonBody['result'] as Iterable;
        containerProducts = List<ContainerProduct>.from(
          l.map(
            (model) => ContainerProduct.fromJson(model as Map<String, dynamic>),
          ),
        );
      }
    }
    return containerProducts;
  }
}
