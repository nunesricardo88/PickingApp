import 'dart:convert';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:http/http.dart' as http;
import 'package:n6picking_flutterapp/services/api_endpoint.dart';
import 'package:n6picking_flutterapp/services/networking.dart';

mixin UserFields {
  static final List<String> allValues = [
    id,
    erpId,
    number,
    name,
    loginName,
    tokenId,
    accessMask,
  ];

  static const String id = 'Id';
  static const String erpId = 'ErpId';
  static const String number = 'Number';
  static const String name = 'Name';
  static const String loginName = 'LoginName';
  static const String tokenId = 'tokenId';
  static const String accessMask = 'AccessMask';
}

class User {
  Guid id;
  String erpId;
  int number;
  String name;
  String loginName;
  String tokenId;
  int accessMask;

  User({
    required this.id,
    required this.erpId,
    required this.number,
    required this.name,
    required this.loginName,
    required this.tokenId,
    required this.accessMask,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: Guid(json[UserFields.id] as String),
        erpId: json[UserFields.erpId] as String,
        number: json[UserFields.number] as int,
        name: json[UserFields.name] as String,
        loginName: json[UserFields.loginName] as String,
        tokenId: json[UserFields.tokenId] as String,
        accessMask: json[UserFields.accessMask] as int,
      );

  Map<String, dynamic> toJson() => {
        UserFields.id: id.toString(),
        UserFields.erpId: erpId,
        UserFields.number: number,
        UserFields.name: name,
        UserFields.loginName: loginName,
        UserFields.tokenId: tokenId,
        UserFields.accessMask: accessMask,
      };
}

mixin UserApi {
  static Future<List<User>> getAll() async {
    List<User> userList = [];
    final String url = ApiEndPoint.getAllUsersURL();
    final NetworkHelper networkHelper = NetworkHelper(url);
    final http.Response response =
        await networkHelper.getData(seconds: 5) as http.Response;

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      final Iterable l = jsonBody['result'] as Iterable;

      userList = List<User>.from(
        l.map((model) => User.fromJson(model as Map<String, dynamic>)),
      );
    }

    return userList;
  }
}
