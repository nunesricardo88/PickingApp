mixin DocumentFields {
  static final List<String> allValues = [
    id,
    erpId,
    type,
    number,
    name,
    entity,
    address,
    lines,
  ];

  static const String id = 'Id';
  static const String erpId = 'ErpId';
  static const String type = 'Type';
  static const String number = 'Number';
  static const String name = 'Name';
  static const String entity = 'Entity';
  static const String address = 'Address';
  static const String lines = 'Lines';
}

class Document {}
