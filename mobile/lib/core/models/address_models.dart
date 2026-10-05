import '../utils/functions/json_helpers.dart';

class AddressModel {
  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String city;
  final String street;
  final String notes;
  final double lat;
  final double lng;
  final bool isDefault;

  const AddressModel({
    this.id = '',
    this.label = 'Home',
    this.fullName = '',
    this.phone = '',
    this.city = '',
    this.street = '',
    this.notes = '',
    this.lat = 30.0444,
    this.lng = 31.2357,
    this.isDefault = false,
  });

  String get display =>
      [street, city].where((e) => e.isNotEmpty).join(' · ');

  factory AddressModel.fromJson(dynamic json) {
    final map = asMap(unwrapData(json));
    return AddressModel(
      id: asId(map['_id'] ?? map['id']),
      label: asString(map['label'], 'Home'),
      fullName: asString(map['fullName'] ?? map['name']),
      phone: asString(map['phone']),
      city: asString(map['city']),
      street: asString(map['street']),
      notes: asString(map['notes']),
      lat: asDouble(map['lat'], 30.0444),
      lng: asDouble(map['lng'], 31.2357),
      isDefault: asBool(map['isDefault']),
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'fullName': fullName,
    'phone': phone,
    'city': city,
    'street': street,
    if (notes.isNotEmpty) 'notes': notes,
    'lat': lat,
    'lng': lng,
    'isDefault': isDefault,
  };
}
