import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/eco_business_model.dart';

class GoogleMapsComponent extends StatefulWidget {
  final List<EcoBusinessModel> businesses;
  final double initialLatitude;
  final double initialLongitude;
  final double initialZoom;

  const GoogleMapsComponent({
    super.key,
    required this.businesses,
    this.initialLatitude = 3.1390, // Kuala Lumpur
    this.initialLongitude = 101.6869,
    this.initialZoom = 12.0,
  });

  @override
  State<GoogleMapsComponent> createState() => _GoogleMapsComponentState();
}

class _GoogleMapsComponentState extends State<GoogleMapsComponent> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  void _createMarkers() {
    _markers = widget.businesses.map((business) {
      return Marker(
        markerId: MarkerId(business.title),
        position: LatLng(business.latitude, business.longitude),
        infoWindow: InfoWindow(
          title: business.title,
          snippet: business.subtitle,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.initialLatitude, widget.initialLongitude),
            zoom: widget.initialZoom,
          ),
          markers: _markers,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: true,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
} 