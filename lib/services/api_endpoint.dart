import 'package:n6picking_flutterapp/models/document_model.dart';
import 'package:n6picking_flutterapp/models/entity_model.dart';
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
  static String getAllProducts(DateTime lastSyncDate) {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    final String lastSyncDateStr = lastSyncDate.toIso8601String();
    return '$baseUrlPath/Product/getAll/lastSyncDate=$lastSyncDateStr';
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
    return '$baseUrlPath/Batch/getSplitBatches/noFl=$noFl&reference=$reference&numMolhos=$numMolhos&numBarras=$numBarras&compBarra=$compBarra';
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
    final Entity? entity = task.document!.entity;

    if (entity == null) {
      return '$baseUrlPath/Document/getPendingDocuments/taskErpId=$pickingTaskErpId&entityType=${entityType.index}&entityErpId=null';
    } else {
      return '$baseUrlPath/Document/getPendingDocuments/taskErpId=$pickingTaskErpId&entityType=${entityType.index}&entityErpId=${entity.erpId.trim()}';
    }
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

  //DocumentLines
  static String getLinesFromDocuments(
    PickingTask task,
    List<Document> documents,
  ) {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    final String pickingTaskErpId = task.erpId.trim();
    final StringBuffer sb = StringBuffer();
    sb.write(
      '$baseUrlPath/DocumentLine/getFromDocuments/taskErpId=$pickingTaskErpId&documentErpIds=',
    );
    for (int i = 0; i < documents.length; i++) {
      final Document document = documents[i];
      sb.write(Uri.encodeComponent(document.erpId!.trim()));
      if (i < documents.length - 1) {
        sb.write(',');
      }
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
}
