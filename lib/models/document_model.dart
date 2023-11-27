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

  static const String id = 'id';
  static const String erpId = 'erpId';
  static const String type = 'type';
  static const String number = 'number';
  static const String name = 'name';
  static const String entity = 'entity';
  static const String address = 'address';
  static const String lines = 'lines';
}

class Document {}
