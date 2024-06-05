import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';

mixin MiscDataFields {
  static final List<String> allValues = [
    id,
    preOperationInput,
    postOperationInput,
    isMandatory,
    group,
    sort,
    sortType,
    name,
    type,
    table,
    field,
    value,
    valueInt,
    valueDouble,
    valueString,
    valueDate,
    valueTime,
    valueDatetime,
  ];

  static const String id = 'Id';
  static const String preOperationInput = 'PreOperationInput';
  static const String postOperationInput = 'PostOperationInput';
  static const String isMandatory = 'Mandatory';
  static const String group = 'Group';
  static const String sort = 'Sort';
  static const String sortType = 'SortType';
  static const String name = 'Name';
  static const String type = 'Type';
  static const String table = 'Table';
  static const String field = 'Field';
  static const String value = 'Value';
  static const String valueInt = 'ValueInt';
  static const String valueDouble = 'ValueDouble';
  static const String valueString = 'ValueString';
  static const String valueDate = 'ValueDate';
  static const String valueTime = 'ValueTime';
  static const String valueDatetime = 'ValueDatetime';
}

class MiscData {
  int id;
  bool? preOperationInput;
  bool? postOperationInput;
  bool? isMandatory;
  bool? group;
  bool? sort;
  String? sortType;
  String name;
  String type;
  String table;
  String field;
  String value;
  int? valueInt;
  double? valueDouble;
  String? valueString;
  DateTime? valueDate;
  DateTime? valueTime;
  DateTime? valueDatetime;

  MiscData({
    required this.id,
    this.preOperationInput,
    this.postOperationInput,
    this.isMandatory,
    this.group,
    this.sort,
    this.sortType,
    required this.name,
    required this.type,
    required this.table,
    required this.field,
    this.value = '',
    this.valueInt,
    this.valueDouble,
    this.valueString,
    this.valueDate,
    this.valueTime,
    this.valueDatetime,
  });

  factory MiscData.fromJson(Map<String, dynamic> json) => MiscData(
        id: json[MiscDataFields.id] as int,
        preOperationInput:
            json[MiscDataFields.preOperationInput] as bool? ?? false,
        postOperationInput:
            json[MiscDataFields.postOperationInput] as bool? ?? false,
        isMandatory: json[MiscDataFields.isMandatory] as bool? ?? false,
        group: json[MiscDataFields.group] as bool? ?? false,
        sort: json[MiscDataFields.sort] as bool? ?? false,
        sortType: json[MiscDataFields.sortType] as String? ?? '',
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
    data[MiscDataFields.group] = group;
    data[MiscDataFields.sort] = sort;
    data[MiscDataFields.sortType] = sortType;
    data[MiscDataFields.name] = name;
    data[MiscDataFields.type] = type;
    data[MiscDataFields.table] = table;
    data[MiscDataFields.field] = field;

    switch (type) {
      case 'Int':
        data[MiscDataFields.valueInt] = valueInt;
        data[MiscDataFields.value] = valueInt.toString();
      case 'Double':
        data[MiscDataFields.valueDouble] = valueDouble;
        data[MiscDataFields.value] = valueDouble.toString();
      case 'String':
        data[MiscDataFields.valueString] = valueString;
        data[MiscDataFields.value] = valueString;
      case 'Date':
        final DateTime? date = DateTime.tryParse(value);
        final DateFormat formatter = DateFormat('yyyy-MM-dd');
        data[MiscDataFields.value] = formatter.format(date!);
      case 'Time':
        final DateTime? time = DateTime.tryParse(value);
        final DateFormat formatter = DateFormat('HH:mm');
        data[MiscDataFields.value] = formatter.format(time!);
      case 'Datetime':
        final DateTime? datetime = DateTime.tryParse(value);
        final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
        data[MiscDataFields.value] = formatter.format(datetime!);
    }

    return data;
  }
}

mixin MiscDataHelper {
  static List<MiscData> getDocumentExtraData(PickingTask pickingTask) {
    List<MiscData> miscDataList = [];

    final String customOptions = pickingTask.customOptions;
    if (customOptions.isNotEmpty) {
      Map<String, dynamic> customOptionsJSON;
      try {
        customOptionsJSON = jsonDecode(customOptions) as Map<String, dynamic>;
      } catch (e) {
        return miscDataList;
      }

      if (customOptionsJSON.containsKey('ExtraFields')) {
        final Map<String, dynamic> extraFieldsJSON =
            customOptionsJSON['ExtraFields'] as Map<String, dynamic>;

        if (extraFieldsJSON.containsKey('Document')) {
          final List<dynamic> miscDataJSON =
              extraFieldsJSON['Document'] as List<dynamic>;
          miscDataList = miscDataJSON
              .map(
                (dynamic miscData) => MiscData.fromJson(
                  miscData as Map<String, dynamic>,
                ),
              )
              .toList();
        }
      }
    }

    return miscDataList;
  }

  static void setDocumentExtraData(
    PickingTask pickingTask,
    List<MiscData> miscDataList,
  ) {
    pickingTask.document!.extraFields = '';
    final List<Map<String, dynamic>> miscDataJSONList = miscDataList
        .map(
          (MiscData miscData) => miscData.toJson(),
        )
        .toList();
    pickingTask.document!.extraFields = jsonEncode(miscDataJSONList);
  }

  static List<MiscData> getSourceDocumentsExtraData(PickingTask pickingTask) {
    List<MiscData> miscDataList = [];

    final String customOptions = pickingTask.customOptions;
    if (customOptions.isNotEmpty) {
      final Map<String, dynamic> customOptionsJSON =
          jsonDecode(customOptions) as Map<String, dynamic>;

      if (customOptionsJSON.containsKey('ExtraFields')) {
        final Map<String, dynamic> extraFieldsJSON =
            customOptionsJSON['ExtraFields'] as Map<String, dynamic>;

        if (extraFieldsJSON.containsKey('SourceDocuments')) {
          final List<dynamic> miscDataJSON =
              extraFieldsJSON['SourceDocuments'] as List<dynamic>;
          miscDataList = miscDataJSON
              .map(
                (dynamic miscData) => MiscData.fromJson(
                  miscData as Map<String, dynamic>,
                ),
              )
              .toList();
        }
      }
    }

    return miscDataList;
  }
}
