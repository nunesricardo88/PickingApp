import 'package:n6picking_flutterapp/models/user_model.dart';
import 'package:n6picking_flutterapp/utilities/system.dart';

mixin ApiEndPoint {
  //Version
  static String apiVersionURL() {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    return '$baseUrlPath/Api/getVersion';
  }

  //Login
  static String userLoginURL() {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    return '$baseUrlPath/Auth/login';
  }

  static String userLoginJSON(User user, String userPin) {
    final StringBuffer stringBuffer = StringBuffer();
    stringBuffer.write('{"loginName":"');
    stringBuffer.write(user.loginName);
    stringBuffer.write('","loginPassword":"');
    stringBuffer.write(userPin);
    stringBuffer.write('"}');
    return stringBuffer.toString();
  }

  //Users
  static String getAllUsersURL() {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    return '$baseUrlPath/User/getAll';
  }

  //Tasks
  static String getTasksByAccessId(int accessId) {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    return '$baseUrlPath/PickingTask/getByAccessId/accessId=$accessId';
  }

  //Products
  static String getAllProducts(DateTime lastSyncDate) {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    final String lastSyncDateStr = lastSyncDate.toIso8601String();
    return '$baseUrlPath/Product/getAll/lastSyncDate=$lastSyncDateStr';
  }
}
