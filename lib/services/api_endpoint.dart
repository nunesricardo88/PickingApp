import 'package:n6picking_flutterapp/models/document_model.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';
import 'package:n6picking_flutterapp/models/user_model.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
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
  static String getAllProducts() {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    return '$baseUrlPath/Product/getAll';
  }

  //Batches
  static String getBatchByReferenceAndBatchNumber(
    String reference,
    String batchNumber,
  ) {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    return '$baseUrlPath/Batch/getByReferenceAndBatchNumber/reference=$reference&batchNumber=$batchNumber';
  }

  static String getSplitBatches(
    int noFl,
    String reference,
    double numMolhos,
    double numBarras,
    double compBarra,
  ) {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    return '$baseUrlPath/Batch/getSplitBatches/noFl=$noFl&reference=${reference.trim()}&numMolhos=$numMolhos&numBarras=$numBarras&compBarra=$compBarra';
  }

  //Entities
  static String getEntitiesByType(EntityType entityType) {
    final int entityTypeInt = entityType.index;
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    return '$baseUrlPath/Entity/getByType/entityType=$entityTypeInt';
  }

  static String getSelfEntity() {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    return '$baseUrlPath/Entity/getSelf';
  }

  //Document
  static String getPendingDocuments(PickingTask task) {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    final String pickingTaskErpId = task.erpId.trim();
    final EntityType entityType = task.document!.documentType.entityType;

    return '$baseUrlPath/Document/getPendingDocuments/taskErpId=$pickingTaskErpId&entityType=${entityType.index}';
  }

  static String getPendingDocumentByBarcode(PickingTask task, String barcode) {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    final String pickingTaskErpId = task.erpId.trim();
    final EntityType entityType = task.document!.documentType.entityType;
    return '$baseUrlPath/Document/getPendingDocumentByBarcode/taskErpId=$pickingTaskErpId&entityType=${entityType.index}&barcode=$barcode';
  }

  static String postPickingTask() {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    return '$baseUrlPath/PickingTask/post';
  }

  static String printDocumentLineLabel() {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    return '$baseUrlPath/DocumentLine/printLabel';
  }

  static String postNewBarcode() {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    return '$baseUrlPath/Product/postNewBarcode';
  }

  //DocumentLines
  static String getLinesFromDocuments(
    PickingTask task,
    List<Document> documents,
  ) {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    final String pickingTaskErpId = task.erpId.trim();
    final StringBuffer sb = StringBuffer();
    sb.write(
      '$baseUrlPath/DocumentLine/getFromDocuments/taskErpId=${Uri.encodeComponent(pickingTaskErpId.trim())}?',
    );
    for (int i = 0; i < documents.length; i++) {
      final Document document = documents[i];
      sb.write('&documentErpIds=');
      sb.write(Uri.encodeComponent(document.erpId!.trim()));
    }
    return sb.toString();
  }

  //Locations
  static String getAllLocations() {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    return '$baseUrlPath/Location/getAll';
  }

  static String getLocationByErpId(String erpId) {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    return '$baseUrlPath/Location/getByErpId/erpId=$erpId';
  }

  static String getLocationByParentErpId(String parentErpId) {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    return '$baseUrlPath/Location/getByParentErpId/parentErpId=$parentErpId';
  }

  static String getProductStockByLocation(
    String locationErpId,
    String productErpId,
    String batchErpId,
  ) {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    return '$baseUrlPath/Location/getProductStock/locationErpId=$locationErpId&productErpId=$productErpId&batchErpId=$batchErpId';
  }
}
