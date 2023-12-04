import 'package:flutter_guid/flutter_guid.dart';

mixin AddressFields {
  static final List<String> allValues = [
    id,
    erpId,
    name,
    street,
    postalCode,
    city,
    country,
  ];

  static const String id = 'id';
  static const String erpId = 'erpId';
  static const String name = 'name';
  static const String street = 'street';
  static const String postalCode = 'postalCode';
  static const String city = 'city';
  static const String country = 'country';
}

class Address {
  Guid id;
  String erpId;
  String name;
  String street;
  String postalCode;
  String city;
  String country;

  Address({
    required this.id,
    required this.erpId,
    required this.name,
    required this.street,
    required this.postalCode,
    required this.city,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: Guid(json[AddressFields.id] as String),
        erpId: json[AddressFields.erpId] as String,
        name: json[AddressFields.name] as String,
        street: json[AddressFields.street] as String,
        postalCode: json[AddressFields.postalCode] as String,
        city: json[AddressFields.city] as String,
        country: json[AddressFields.country] as String,
      );
}
