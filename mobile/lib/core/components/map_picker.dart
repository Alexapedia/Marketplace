import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/color_model.dart';

class MapPicker extends StatefulWidget {
  const MapPicker({
    super.key,
    required this.lat,
    required this.lng,
    required this.onChanged,
    this.height = 220,
  });

  final double lat;
  final double lng;
  final ValueChanged<LatLng> onChanged;
  final double height;

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  late final MapController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MapController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MapPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lat != widget.lat || oldWidget.lng != widget.lng) {
      try {
        _controller.move(LatLng(widget.lat, widget.lng), _controller.camera.zoom);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final gold = Theme.of(context).extension<AppColors>()!.gold;
    final point = LatLng(widget.lat, widget.lng);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: widget.height,
        child: FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: point,
            initialZoom: 13,
            onTap: (_, latLng) => widget.onChanged(latLng),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'placemarket_mobile',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 40,
                  height: 40,
                  child: Icon(Icons.location_on, color: gold, size: 40),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
