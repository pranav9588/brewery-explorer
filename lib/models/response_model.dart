import 'package:hive/hive.dart';

part 'response_model.g.dart';

@HiveType(typeId: 1)
class Brewery extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? breweryType;

  @HiveField(3)
  String? address1;

  @HiveField(4)
  String? address2;

  @HiveField(5)
  String? address3;

  @HiveField(6)
  String? city;

  @HiveField(7)
  String? stateProvince;

  @HiveField(8)
  String? postalCode;

  @HiveField(9)
  String? country;

  @HiveField(10)
  double? longitude;

  @HiveField(11)
  double? latitude;

  @HiveField(12)
  String? phone;

  @HiveField(13)
  String? websiteUrl;

  @HiveField(14)
  String? state;

  @HiveField(15)
  String? street;

  Brewery({
    this.id,
    this.name,
    this.breweryType,
    this.address1,
    this.address2,
    this.address3,
    this.city,
    this.stateProvince,
    this.postalCode,
    this.country,
    this.longitude,
    this.latitude,
    this.phone,
    this.websiteUrl,
    this.state,
    this.street,
  });

  factory Brewery.fromJson(Map<String, dynamic> json) {
    return Brewery(
      id: json["id"],
      name: json["name"],
      breweryType: json["brewery_type"],
      address1: json["address_1"],
      address2: json["address_2"],
      address3: json["address_3"],
      city: json["city"],
      stateProvince: json["state_province"],
      postalCode: json["postal_code"],
      country: json["country"],
      longitude: json["longitude"] != null
          ? double.tryParse(json["longitude"].toString())
          : null,
      latitude: json["latitude"] != null
          ? double.tryParse(json["latitude"].toString())
          : null,
      phone: json["phone"],
      websiteUrl: json["website_url"],
      state: json["state"],
      street: json["street"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "brewery_type": breweryType,
      "address_1": address1,
      "address_2": address2,
      "address_3": address3,
      "city": city,
      "state_province": stateProvince,
      "postal_code": postalCode,
      "country": country,
      "longitude": longitude,
      "latitude": latitude,
      "phone": phone,
      "website_url": websiteUrl,
      "state": state,
      "street": street,
    };
  }
}
