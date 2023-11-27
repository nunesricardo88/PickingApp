import 'package:flutter_guid/flutter_guid.dart';
import 'package:n6picking_flutterapp/models/document_type_model.dart';
import 'package:n6picking_flutterapp/models/entity_model.dart';
import 'package:n6picking_flutterapp/models/location_model.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';

mixin PickingTaskFields {
  static final List<String> allValues = [
    id,
    erpId,
    accessId,
    userErpId,
    group,
    name,
    description,
    taskType,
    originDocumentType,
    destinationDocumentType,
    defaultEntity,
    defaultOriginLocation,
    defaultDestinationLocation,
    customOptions,
  ];

  static const String id = 'id';
  static const String erpId = 'erpId';
  static const String accessId = 'accessId';
  static const String userErpId = 'userErpId';
  static const String group = 'group';
  static const String name = 'name';
  static const String description = 'description';
  static const String taskType = 'taskType';
  static const String originDocumentType = 'originDocumentType';
  static const String destinationDocumentType = 'destinationDocumentType';
  static const String defaultEntity = 'defaultEntity';
  static const String defaultOriginLocation = 'defaultOriginLocation';
  static const String defaultDestinationLocation = 'defaultDestinationLocation';
  static const String customOptions = 'customOptions';
}

class PickingTask {
  Guid id;
  String erpId;
  int accessId;
  String userErpId;
  String group;
  String name;
  String description;
  PickingTaskType taskType;
  DocumentType originDocumentType;
  DocumentType destinationDocumentType;
  Entity defaultEntity;
  Location defaultOriginLocation;
  Location defaultDestinationLocation;
  String customOptions;

  PickingTask({
    required this.id,
    required this.erpId,
    required this.accessId,
    required this.userErpId,
    required this.group,
    required this.name,
    required this.description,
    required this.taskType,
    required this.originDocumentType,
    required this.destinationDocumentType,
    required this.defaultEntity,
    required this.defaultOriginLocation,
    required this.defaultDestinationLocation,
    required this.customOptions,
  });
}
