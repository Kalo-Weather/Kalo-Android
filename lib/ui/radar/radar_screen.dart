import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_theme.dart';
import '../../services/location_service.dart';

class RadarScreen extends ConsumerWidget {
  final String frameUrl;

  const RadarScreen({super.key, required this.frameUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionAsync = ref.watch(currentPositionProvider);

    return Scaffold(
      backgroundColor: KaloColors.amoledDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: KaloColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Precipitation Radar', style: TextStyle(color: KaloColors.primaryText, fontSize: 16)),
        centerTitle: true,
      ),
      body: positionAsync.when(
        data: (position) {
          final center = position != null
              ? LatLng(position.latitude, position.longitude)
              : const LatLng(40.7, -74.0);
          return _buildMap(center);
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (_, __) => _buildMap(const LatLng(40.7, -74.0)),
      ),
    );
  }

  Widget _buildMap(LatLng center) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 6,
        minZoom: 3,
        maxZoom: 18,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        TileLayer(
          urlTemplate: frameUrl,
          evictErrorTileStrategy: EvictErrorTileStrategy.dispose,
        ),
      ],
    );
  }
}
