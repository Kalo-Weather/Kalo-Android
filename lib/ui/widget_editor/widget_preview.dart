import 'package:flutter/material.dart';
import '../../models/widget_config.dart';
import '../../theme/app_theme.dart';

class WidgetPreview extends StatelessWidget {
  final List<WidgetBlockType> blocks;
  final WidgetSize size;

  const WidgetPreview({super.key, required this.blocks, required this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: KaloColors.frostBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: _buildWidgetContent(),
        ),
      ),
    );
  }

  Widget _buildWidgetContent() {
    final displayed = blocks.take(_maxBlocks).toList();

    switch (size) {
      case WidgetSize.small:
        return _buildSmallContent(displayed);
      case WidgetSize.medium:
        return _buildMediumContent(displayed);
      case WidgetSize.large:
        return _buildLargeContent(displayed);
    }
  }

  int get _maxBlocks {
    switch (size) {
      case WidgetSize.small:
        return 3;
      case WidgetSize.medium:
        return 5;
      case WidgetSize.large:
        return 8;
    }
  }

  double get _widgetWidth {
    switch (size) {
      case WidgetSize.small:
        return 140;
      case WidgetSize.medium:
        return 260;
      case WidgetSize.large:
        return 300;
    }
  }

  double get _widgetHeight {
    switch (size) {
      case WidgetSize.small:
        return 100;
      case WidgetSize.medium:
        return 140;
      case WidgetSize.large:
        return 240;
    }
  }

  Widget _buildSmallContent(List<WidgetBlockType> blocks) {
    return Container(
      width: _widgetWidth,
      height: _widgetHeight,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: blocks.map(_renderBlock).toList(),
      ),
    );
  }

  Widget _buildMediumContent(List<WidgetBlockType> blocks) {
    return Container(
      width: _widgetWidth,
      height: _widgetHeight,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...blocks.take(3).map(_renderBlock),
          if (blocks.length > 3) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: blocks.skip(3).take(3).map((b) => _renderMiniBlock(b)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLargeContent(List<WidgetBlockType> blocks) {
    return Container(
      width: _widgetWidth,
      height: _widgetHeight,
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          ...blocks.take(2).map(_renderBlock),
          const SizedBox(height: 4),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              physics: const NeverScrollableScrollPhysics(),
              children: blocks.skip(2).take(6).map((b) => _renderMiniBlock(b)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderBlock(WidgetBlockType type) {
    switch (type) {
      case WidgetBlockType.locationName:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Text(
            'San Francisco',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 9),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        );
      case WidgetBlockType.temperature:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '72°F',
              style: TextStyle(color: Colors.white, fontSize: size == WidgetSize.small ? 22 : 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Text('☀️', style: TextStyle(fontSize: size == WidgetSize.small ? 18 : 22)),
          ],
        );
      case WidgetBlockType.conditionIcon:
        return Text('☀️', style: TextStyle(fontSize: size == WidgetSize.small ? 24 : 30));
      case WidgetBlockType.feelsLike:
        return Text(
          'Feels like 70°F',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 9),
          textAlign: TextAlign.center,
        );
      case WidgetBlockType.time:
        return Text(
          'Updated 2:30 PM',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 8),
          textAlign: TextAlign.center,
        );
      case WidgetBlockType.humidity:
        return _renderInfoRow('💧', 'Humidity', '65%');
      case WidgetBlockType.wind:
        return _renderInfoRow('🌬️', 'Wind', '12 mph');
      case WidgetBlockType.uvIndex:
        return _renderInfoRow('☀️', 'UV Index', '5');
      case WidgetBlockType.aqi:
        return _renderInfoRow('🌫️', 'AQI', '42');
    }
  }

  Widget _renderMiniBlock(WidgetBlockType type) {
    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: _renderBlock(type),
    );
  }

  Widget _renderInfoRow(String emoji, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(
          '$value',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 10),
        ),
      ],
    );
  }
}
