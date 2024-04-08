import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:n6picking_flutterapp/models/entity_model.dart';
import 'package:n6picking_flutterapp/models/location_model.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';

mixin Helper {
  static String removeDecimalZeroFormat(double n, {int decimalPlaces = 2}) {
    final RegExp regex = RegExp(r'([.]*0)(?!.*\d)');
    if (n % 1 == 0) {
      return n.toStringAsFixed(0);
    } else {
      final String nString = n.toStringAsFixed(decimalPlaces);
      return nString.replaceAll(regex, '');
    }
  }

  static String getWordFromPosition(int position, String expression) {
    final List<String> words = expression.split(' ');
    return words[position];
  }

  static dynamic qrCodeToJson(String scannedString) {
    String result;
    result = scannedString.replaceAll('[', '{');
    result = result.replaceAll(']', '}');
    result = result.replaceAll(';', ':');
    result = result.replaceAll("'", '"');

    final resultJson = jsonDecode(result);
    return resultJson;
  }

  static BarCodeType getBarCodeType(String barcode) {
    BarCodeType barCodeType;
    if (barcode.isEmpty) {
      barCodeType = BarCodeType.unknown;
    } else if (barcode.startsWith('{')) {
      barCodeType = BarCodeType.batch;
    } else if (barcode.startsWith('C_')) {
      barCodeType = BarCodeType.container;
    } else if (barcode.startsWith('D_')) {
      barCodeType = BarCodeType.document;
    } else {
      //Check if barcode is the erpId of any location
      final Location? location =
          LocationApi.getByErpId(barcode, LocationApi.instance.allLocations);

      if (location != null) {
        barCodeType = BarCodeType.location;
      } else {
        barCodeType = BarCodeType.product;
      }
    }

    return barCodeType;
  }

  static Future<void> showMsg(
    String title,
    String message,
    BuildContext context,
  ) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          surfaceTintColor: kWhiteBackground,
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Ok',
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<bool> askQuestion(
    String title,
    String question,
    BuildContext context,
  ) async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          surfaceTintColor: kWhiteBackground,
          title: Text(title),
          content: Text(question),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                result = false;
                Navigator.of(context).pop();
              },
              child: Text(
                'Não',
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: kPrimaryColor.withOpacity(0.8),
                    ),
              ),
            ),
            TextButton(
              onPressed: () {
                result = true;
                Navigator.of(context).pop();
              },
              child: Text(
                'Sim',
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        );
      },
    );
    return result;
  }

  static bool isEntityEqual(Entity? entity1, Entity? entity2) {
    bool equals = false;
    if (entity1 == null && entity2 == null) {
      equals = true;
    } else {
      if (entity1 == null) {
        equals = false;
      } else if (entity2 == null) {
        equals = false;
      } else if (entity1.erpId == entity2.erpId &&
          entity1.entityType == entity2.entityType) {
        equals = true;
      } else {
        equals = false;
      }
    }
    return equals;
  }

  static Future<List<Entity>> getEntitySuggestions(
    List<Entity> entityList,
    String query,
  ) async {
    if (query.isEmpty) {
      return [];
    }
    final List<Entity> entities = entityList.where((entity) {
      final String queryLower = query.toLowerCase();
      final String entityNameLower = entity.name.toLowerCase();
      return entityNameLower.contains(queryLower);
    }).toList();

    return entities;
  }

  static void printDebug(String message) {
    final RegExp pattern = RegExp('.{1,800}');
    pattern.allMatches(message).forEach((match) => debugPrint(match.group(0)));
  }
}
