mixin PickingTaskFields {
  static final List<String> allValues = [
    id,
    erpId,
    group,
    name,
    description,
    taskType,
    entityType,
    documentType,
    defaultEntity,
    defaultOriginLocation,
    defaultDestinationLocation,
    customOptions,
  ];

  static const String id = 'id';
  static const String erpId = 'erpId';
  static const String group = 'group';
  static const String name = 'name';
  static const String description = 'description';
  static const String taskType = 'taskType';
  static const String entityType = 'entityType';
  static const String documentType = 'documentType';
  static const String defaultEntity = 'defaultEntity';
  static const String defaultOriginLocation = 'defaultOriginLocation';
  static const String defaultDestinationLocation = 'defaultDestinationLocation';
  static const String customOptions = 'customOptions';
}
