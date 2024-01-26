import 'dart:convert';

import 'package:n6picking_flutterapp/models/picking_task_model.dart';

mixin MiscDataFields {
  static final List<String> allValues = [
    id,
    preOperationInput,
    postOperationInput,
    isMandatory,
    name,
    type,
    table,
    field,
    value,
    valueInt,
    valueDouble,
    valueString,
    valueDatetime,
  ];

  static const String id = 'Id';
  static const String preOperationInput = 'PreOperationInput';
  static const String postOperationInput = 'PostOperationInput';
  static const String isMandatory = 'Mandatory';
  static const String name = 'Name';
  static const String type = 'Type';
  static const String table = 'Table';
  static const String field = 'Field';
  static const String value = 'Value';
  static const String valueInt = 'ValueInt';
  static const String valueDouble = 'ValueDouble';
  static const String valueString = 'ValueString';
  static const String valueDatetime = 'ValueDatetime';
}

class MiscData {
  int id;
  bool preOperationInput;
  bool postOperationInput;
  bool isMandatory;
  String name;
  String type;
  String table;
  String field;
  String value;
  int? valueInt;
  double? valueDouble;
  String? valueString;
  DateTime? valueDatetime;

  MiscData({
    required this.id,
    required this.preOperationInput,
    required this.postOperationInput,
    required this.isMandatory,
    required this.name,
    required this.type,
    required this.table,
    required this.field,
    this.value = '',
    this.valueInt,
    this.valueDouble,
    this.valueString,
    this.valueDatetime,
  });

  factory MiscData.fromJson(Map<String, dynamic> json) => MiscData(
        id: json[MiscDataFields.id] as int,
        preOperationInput: json[MiscDataFields.preOperationInput] as bool,
        postOperationInput: json[MiscDataFields.postOperationInput] as bool,
        isMandatory: json[MiscDataFields.isMandatory] as bool,
        name: json[MiscDataFields.name] as String,
        type: json[MiscDataFields.type] as String,
        table: json[MiscDataFields.table] as String,
        field: json[MiscDataFields.field] as String,
      );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[MiscDataFields.id] = id;
    data[MiscDataFields.preOperationInput] = preOperationInput;
    data[MiscDataFields.postOperationInput] = postOperationInput;
    data[MiscDataFields.isMandatory] = isMandatory;
    data[MiscDataFields.name] = name;
    data[MiscDataFields.type] = type;
    data[MiscDataFields.table] = table;
    data[MiscDataFields.field] = field;

    switch (type) {
      case 'Int':
        data[MiscDataFields.valueInt] = valueInt;
        data[MiscDataFields.value] = valueInt.toString();
        break;
      case 'Double':
        data[MiscDataFields.valueDouble] = valueDouble;
        data[MiscDataFields.value] = valueDouble.toString();
        break;
      case 'String':
        data[MiscDataFields.valueString] = valueString;
        data[MiscDataFields.value] = valueString;
        break;
      case 'Datetime':
        data[MiscDataFields.valueDatetime] = valueDatetime;
        data[MiscDataFields.value] = valueDatetime.toString();
        break;
    }

    return data;
  }
}

mixin MiscDataHelper {
  static List<MiscData> fromTask(PickingTask pickingTask) {
    List<MiscData> miscDataList = [];

    final String customOptions = pickingTask.customOptions;
    if (customOptions.isNotEmpty) {
      final Map<String, dynamic> customOptionsJSON =
          jsonDecode(customOptions) as Map<String, dynamic>;

      if (customOptionsJSON.containsKey('DocumentExtraData')) {
        final List<dynamic> miscDataJSON =
            customOptionsJSON['DocumentExtraData'] as List<dynamic>;
        miscDataList = miscDataJSON
            .map(
              (dynamic miscData) => MiscData.fromJson(
                miscData as Map<String, dynamic>,
              ),
            )
            .toList();
      }
    }

    return miscDataList;
  }

  static void toTask(PickingTask pickingTask, List<MiscData> miscDataList) {
    final String customOptions = pickingTask.customOptions;
    if (customOptions.isNotEmpty) {
      final Map<String, dynamic> customOptionsJSON =
          jsonDecode(customOptions) as Map<String, dynamic>;

      if (customOptionsJSON.containsKey('DocumentExtraData')) {
        customOptionsJSON['DocumentExtraData'] = miscDataList;

        pickingTask.customOptions = json.encode(customOptionsJSON);
      }
    }
  }
}
