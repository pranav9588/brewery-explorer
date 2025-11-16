import 'package:brewery/models/response_model.dart';
import 'package:brewery/ui/widgets/brewery_bottom_sheet.dart';
import 'package:brewery/ui/widgets/brewery_markers.dart';
import 'package:brewery/ui/widgets/map_controls.dart';
import 'package:brewery/ui/widgets/user_location_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  final List<Brewery> breweries;

  const MapScreen({super.key, required this.breweries});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  double _currentZoom = 4;
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    final location = await UserLocationMarker.getUserLocation();
    if (location != null && mounted) {
      setState(() => _userLocation = location);
    }
  }

  @override
  Widget build(BuildContext context) {
    final breweryMarkers =
    BreweryMarkers.buildMarkers(widget.breweries, _onMarkerTap);

    final initialCenter = breweryMarkers.isNotEmpty
        ? breweryMarkers.first.point
        : const LatLng(38.0, -95.0);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: _currentZoom,
            minZoom: 2,
            maxZoom: 18,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: "com.example.breweries",
            ),

            // Brewery markers
            MarkerLayer(markers: breweryMarkers),

            // User marker
            if (_userLocation != null)
              MarkerLayer(
                markers: [
                  UserLocationMarker.buildUserMarker(_userLocation!),
                ],
              ),
          ],
        ),

        // Zoom controls
        Positioned(
          right: 16,
          bottom: 30,
          child: MapControls(
            onZoomIn: () {
              setState(() {
                _currentZoom += 1;
                _mapController.move(_mapController.camera.center, _currentZoom);
              });
            },
            onZoomOut: () {
              setState(() {
                _currentZoom -= 1;
                _mapController.move(_mapController.camera.center, _currentZoom);
              });
            },
          ),
        ),
      ],
    );
  }

  void _onMarkerTap(Brewery brewery) {
    final lat = double.tryParse(brewery.latitude.toString()) ?? 0.0;
    final lng = double.tryParse(brewery.longitude.toString()) ?? 0.0;

    _mapController.move(LatLng(lat, lng), 15);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => BreweryBottomSheet(brewery),
    );
  }
}
