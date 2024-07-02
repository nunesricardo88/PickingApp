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
    return '$baseUrlPath/PickingTask/getByAccessId/$accessId';
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
    final String encodedReference = Uri.encodeComponent(reference.trim());
    final String encodedBatchNumber = Uri.encodeComponent(batchNumber.trim());
    return '$baseUrlPath/Batch/getByReferenceAndBatchNumber/$encodedReference/$encodedBatchNumber';
  }

  static String getSplitBatches(
    int noFl,
    String reference,
    double numMolhos,
    double numBarras,
    double compBarra,
  ) {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    final String encodedReference = Uri.encodeComponent(reference.trim());
    return '$baseUrlPath/Batch/getSplitBatches/$noFl/$encodedReference/$numMolhos/$numBarras/$compBarra';
  }

  //Entities
  static String getEntitiesByType(EntityType entityType) {
    final int entityTypeInt = entityType.index;
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    return '$baseUrlPath/Entity/getByType/$entityTypeInt';
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

    return '$baseUrlPath/Document/getPendingDocuments/$pickingTaskErpId/${entityType.index}';
  }

  static String getPendingDocumentByBarcode(PickingTask task, String barcode) {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    final String encodedTaskErpId = Uri.encodeComponent(task.erpId.trim());
    final String encodedBarcode = Uri.encodeComponent(barcode.trim());
    final EntityType entityType = task.document!.documentType.entityType;

    return '$baseUrlPath/Document/getPendingDocumentByBarcode/$encodedTaskErpId/${entityType.index}/$encodedBarcode';
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
      '$baseUrlPath/DocumentLine/getFromDocuments?taskErpId=${Uri.encodeComponent(pickingTaskErpId.trim())}',
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
    final String encodedErpId = Uri.encodeComponent(erpId.trim());
    return '$baseUrlPath/Location/getByErpId/$encodedErpId';
  }

  static String getLocationByParentErpId(String parentErpId) {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    final String encodedParentErpId = Uri.encodeComponent(parentErpId.trim());
    return '$baseUrlPath/Location/getByParentErpId/$encodedParentErpId';
  }

  static String getProductStockByLocation(
    String locationErpId,
    String productErpId,
    String batchErpId,
  ) {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    final String encodedLocationErpId =
        Uri.encodeComponent(locationErpId.trim());
    final String encodedProductErpId = Uri.encodeComponent(productErpId.trim());
    final String encodedBatchErpId = Uri.encodeComponent(batchErpId.trim());
    return '$baseUrlPath/Location/getProductStock/$encodedLocationErpId/$encodedProductErpId/$encodedBatchErpId';
  }

  static String getLocationByProductWithStock(
    String productErpId,
    String batchErpId,
  ) {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    final String encodedProductErpId = Uri.encodeComponent(productErpId.trim());
    final String encodedBatchErpId = Uri.encodeComponent(batchErpId.trim());
    return '$baseUrlPath/Location/getByProductWithStock/$encodedProductErpId/$encodedBatchErpId';
  }

  //Stock
  static String getStockByLocation(String locationErpId) {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    final String encodedLocationErpId =
        Uri.encodeComponent(locationErpId.trim());
    return '$baseUrlPath/Stock/getByLocation/$encodedLocationErpId';
  }

  //Containers
  static String getContainerByBarcode(String barcode) {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    final String encodedBarcode = Uri.encodeComponent(barcode.trim());
    return '$baseUrlPath/Container/getByBarcode/$encodedBarcode';
  }

  static String getContainerProductsByContainerErpId(String containerErpId) {
    final String baseUrlPath = System.instance.apiConnection!.connectionString;
    final String encodedContainerErpId =
        Uri.encodeComponent(containerErpId.trim());
    return '$baseUrlPath/ContainerProduct/getByContainerErpId/$encodedContainerErpId';
  }
}
