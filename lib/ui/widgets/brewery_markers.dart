import 'package:brewery/models/response_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class BreweryMarkers {
  static List<Marker> buildMarkers(
      List<Brewery> breweries,
      Function(Brewery) onTap,
      ) {
    return breweries
        .where((b) => b.latitude != null && b.longitude != null)
        .map(
          (brewery) => Marker(
        width: 55,
        height: 55,
        point: LatLng(
          double.tryParse(brewery.latitude.toString()) ?? 0.0,
          double.tryParse(brewery.longitude.toString()) ?? 0.0,
        ),
        child: GestureDetector(
          onTap: () => onTap(brewery),
          child: Image.asset(
            "assets/custom_marker_clean.png",
            width: 55,
            height: 55,
          ),
        ),
      ),
    )
        .toList();
  }
}
