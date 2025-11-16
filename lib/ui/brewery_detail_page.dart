import 'package:brewery/core/utils/utilities.dart';
import 'package:brewery/models/response_model.dart';
import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class BreweryDetailPage extends StatelessWidget {
  final Brewery brewery;

  const BreweryDetailPage({super.key, required this.brewery});

  @override
  Widget build(BuildContext context) {
    final LatLng? location =
        (brewery.latitude != null && brewery.longitude != null)
        ? LatLng(brewery.latitude!.toDouble(), brewery.longitude!.toDouble())
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(brewery.name ?? "Brewery Details"), actions: [

      ],),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (location != null)
              SizedBox(
                height: 250,
                child: FlutterMap(
                  options: MapOptions(initialCenter: location, initialZoom: 14),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: "com.example.breweries",
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 40,
                          height: 40,
                          point: location,
                          child: const Icon(
                            Icons.location_pin,
                            size: 40,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text("Location not available"),
              ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title("Name"),
                  _value(brewery.name),

                  _title("Type"),
                  _value(brewery.breweryType),

                  _title("Address"),
                  _value(_fullAddress(brewery)),

                  _title("City"),
                  _value(brewery.city),

                  _title("State"),
                  _value(brewery.stateProvince),

                  _title("Country"),
                  _value(brewery.country),

                  _title("Postal Code"),
                  _value(brewery.postalCode),

                  _title("Phone"),
                  _value(brewery.phone),

                  const SizedBox(height: 20),

                  if (brewery.websiteUrl != null &&
                      brewery.websiteUrl!.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () => Utilities.launchURL(brewery.websiteUrl!),
                      icon: const Icon(Icons.link),
                      label: const Text("Visit Website"),
                    ),

                  const SizedBox(height: 10),

                  if (location != null)
                    ElevatedButton.icon(
                      onPressed: () =>
                          _openInMaps(brewery.latitude!, brewery.longitude!),
                      icon: const Icon(Icons.map),
                      label: const Text("Open in Maps"),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _value(String? text) {
    return Text(text?.isNotEmpty == true ? text! : "Not available");
  }

  String _fullAddress(Brewery b) {
    return [
      b.street,
      b.address1,
      b.address2,
      b.address3,
    ].where((e) => e != null && e!.isNotEmpty).join(", ");
  }

  Future<void> _openInMaps(double lat, double lng) async {
    final googleUrl =
        "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
    final appleUrl = "https://maps.apple.com/?q=$lat,$lng";
    final osmUrl = "https://www.openstreetmap.org/?mlat=$lat&mlon=$lng&zoom=18";

    final uri = Uri.parse(googleUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(Uri.parse(appleUrl))) {
      await launchUrl(Uri.parse(appleUrl));
    } else {
      await launchUrl(Uri.parse(osmUrl));
    }
  }
}
