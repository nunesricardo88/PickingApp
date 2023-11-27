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

  static const String id = 'Id';
  static const String erpId = 'ErpId';
  static const String street = 'Street';
  static const String postalCode = 'PostalCode';
  static const String city = 'City';
  static const String country = 'Country';
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
