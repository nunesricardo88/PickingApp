import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:n6picking_flutterapp/database/api_connection_table.dart';
import 'package:n6picking_flutterapp/models/api_connection_model.dart';
import 'package:n6picking_flutterapp/models/api_response.dart';
import 'package:n6picking_flutterapp/models/user_model.dart';
import 'package:n6picking_flutterapp/services/api_endpoint.dart';
import 'package:n6picking_flutterapp/services/networking.dart';
import 'package:package_info_plus/package_info_plus.dart';

class System {
  static final System instance = System._init();

  User? activeUser;
  ApiConnection? apiConnection;
  List<int>? appVersion;
  List<int>? apiVersion;
  bool? isUpToDate;
  String? token;

  System();
  System._init() {
    initialize();
  }

  Future<void> initialize() async {
    apiConnection = await getApiConnectionFromDb();
    isUpToDate = await checkIfUpToDate();
  }

  Future<ApiConnection?> getApiConnectionFromDb() async {
    return ApiConnectionDatabase.instance.readFirst();
  }

  Future<bool> checkIfUpToDate() async {
    appVersion = await getAppVersion();
    apiVersion = await getApiVersion();

    if (apiVersion == null) {
      return false;
    }

    if (appVersion![0] < apiVersion![0]) {
      return false;
    } else if (appVersion![0] > apiVersion![0]) {
      return true;
    } else {
      if (appVersion![1] < apiVersion![1]) {
        return false;
      } else if (appVersion![1] > apiVersion![1]) {
        return true;
      } else {
        if (appVersion![2] < apiVersion![2]) {
          return false;
        } else if (appVersion![2] > apiVersion![2]) {
          return true;
        } else {
          return true;
        }
      }
    }
  }

  Future<List<int>> getAppVersion() async {
    await PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      appVersion = packageInfo.version.split('.').map(int.parse).toList();
    });

    return appVersion!;
  }

  Future<List<int>?> getApiVersion() async {
    if (apiConnection == null) {
      return null;
    }

    try {
      final String url = ApiEndPoint.apiVersionURL();
      final NetworkHelper networkHelper = NetworkHelper(url);
      final http.Response result =
          await networkHelper.getDataNoAuth(seconds: 5) as http.Response;

      if (result.statusCode == 200) {
        final resultBody = result.body;
        return resultBody.split('.').map(int.parse).toList();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> setApiConnection(String url, String port) async {
    await ApiConnectionDatabase.instance.deleteAll();

    final ApiConnection api = ApiConnection(
      url: url,
      port: port,
      connectionString: 'http://$url:$port',
    );

    apiConnection = await ApiConnectionDatabase.instance.create(api);
  }

  Future<bool> isConnectedToServer() async {
    apiConnection = await getApiConnectionFromDb();
    if (apiConnection == null) {
      return false;
    } else {
      return apiConnection!.isValid();
    }
  }

  Future<ApiResponse> login(User user, String userPin) async {
    final String url = ApiEndPoint.userLoginURL();
    final String json = ApiEndPoint.userLoginJSON(user, userPin);
    final ApiResponse response = await NetworkHelper(url).postDataNoAuth(
      json: json,
      seconds: 10,
    ) as ApiResponse;

    if (response.statusCode == 200) {
      final String responseBody = response.result as String;
      final Map<String, dynamic> jsonBody =
          jsonDecode(responseBody) as Map<String, dynamic>;
      activeUser = User.fromJson(jsonBody);
    } else {
      activeUser = null;
    }

    return response;
  }
}
