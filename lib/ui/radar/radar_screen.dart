import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RadarScreen extends StatefulWidget {
  final String frameUrl;

  const RadarScreen({super.key, required this.frameUrl});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  final TransformationController _transformController = TransformationController();
  double _zoom = 1.0;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() => _zoom = (_zoom * details.scale).clamp(1.0, 5.0));
    _transformController.value = Matrix4.diagonal3Values(_zoom, _zoom, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KaloColors.amoledDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: KaloColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Precipitation Radar', style: TextStyle(color: KaloColors.primaryText, fontSize: 16)),
        centerTitle: true,
      ),
      body: GestureDetector(
        onScaleUpdate: _onScaleUpdate,
        child: InteractiveViewer(
          transformationController: _transformController,
          minScale: 1.0,
          maxScale: 5.0,
          child: Center(
            child: Image.network(
              widget.frameUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
              errorBuilder: (context, error, stackTrace) => const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, color: KaloColors.secondaryText, size: 48),
                  SizedBox(height: 16),
                  Text('Radar unavailable', style: TextStyle(color: KaloColors.secondaryText)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
