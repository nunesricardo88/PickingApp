import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:n6picking_flutterapp/models/entity_model.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';

mixin Helper {
  static String removeDecimalZeroFormat(double n) {
    final RegExp regex = RegExp(r'([.]*0)(?!.*\d)');
    return n.toString().replaceAll(regex, '');
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

  static Future<void> showMsg(
    String title,
    String message,
    BuildContext context,
  ) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kWhiteBackground,
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
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
          title: Text(title),
          content: Text(question),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                result = false;
                Navigator.of(context).pop();
              },
              child: const Text('Não'),
            ),
            TextButton(
              onPressed: () {
                result = true;
                Navigator.of(context).pop();
              },
              child: const Text('Sim'),
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
}
