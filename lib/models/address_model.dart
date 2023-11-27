import 'package:flutter_guid/flutter_guid.dart';

mixin AddressFields {
  static final List<String> allValues = [
    id,
    erpId,
    street,
    postalCode,
    city,
    country,
  ];

  static const String id = 'id';
  static const String erpId = 'erpId';
  static const String street = 'street';
  static const String postalCode = 'postalCode';
  static const String city = 'city';
  static const String country = 'country';
}

class Address {
  Guid id;
  String erpId;
  String street;
  String postalCode;
  String city;
  String country;

  Address({
    required this.id,
    required this.erpId,
    required this.street,
    required this.postalCode,
    required this.city,
    required this.country,
  });
}
