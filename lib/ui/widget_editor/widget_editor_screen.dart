import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/widget_config.dart';
import '../../services/widget_config_provider.dart';
import '../../services/widget_service.dart';
import '../../theme/app_theme.dart';
import 'widget_preview.dart';

class WidgetEditorScreen extends ConsumerStatefulWidget {
  const WidgetEditorScreen({super.key});

  @override
  ConsumerState<WidgetEditorScreen> createState() => _WidgetEditorScreenState();
}

class _WidgetEditorScreenState extends ConsumerState<WidgetEditorScreen> {
  WidgetSize _selectedSize = WidgetSize.medium;
  late List<WidgetBlockType> _blocks;
  bool _hasUnsaved = false;

  @override
  void initState() {
    super.initState();
    _loadBlocks();
  }

  void _loadBlocks() {
    final config = ref.read(widgetConfigProvider);
    _blocks = List.from(config.forSize(_selectedSize).blocks);
  }

  void _onSizeChanged(WidgetSize size) {
    setState(() {
      _selectedSize = size;
      final config = ref.read(widgetConfigProvider);
      _blocks = List.from(config.forSize(size).blocks);
      _hasUnsaved = false;
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final block = _blocks.removeAt(oldIndex);
      _blocks.insert(newIndex, block);
      _hasUnsaved = true;
    });
  }

  void _toggleBlock(WidgetBlockType type) {
    setState(() {
      if (_blocks.contains(type)) {
        _blocks.remove(type);
      } else {
        _blocks.add(type);
      }
      _hasUnsaved = true;
    });
  }

  Future<void> _save() async {
    ref.read(widgetConfigProvider.notifier).updateBlocks(_selectedSize, List.from(_blocks));
    await ref.read(widgetConfigProvider.notifier).save();
    await WidgetService.saveWidgetConfig(ref.read(widgetConfigProvider));
    setState(() => _hasUnsaved = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Widget configuration saved'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _reset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reset to Default', style: TextStyle(color: KaloColors.primaryText)),
        content: Text(
          'Reset ${_selectedSize.name} widget to default blocks?',
          style: TextStyle(color: KaloColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: KaloColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final defaults = WidgetConfig.defaults().forSize(_selectedSize);
    setState(() {
      _blocks = List.from(defaults.blocks);
      _hasUnsaved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(widgetConfigProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: KaloColors.primaryText),
          onPressed: () {
            if (_hasUnsaved) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1A1A2E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Text('Unsaved Changes', style: TextStyle(color: KaloColors.primaryText)),
                  content: Text(
                    'You have unsaved changes. Discard them?',
                    style: TextStyle(color: KaloColors.secondaryText),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Stay', style: TextStyle(color: KaloColors.secondaryText)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                      child: const Text('Discard'),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text('Widget Editor', style: TextStyle(color: KaloColors.primaryText)),
        actions: [
          IconButton(
            icon: Icon(Icons.restore_outlined, color: KaloColors.secondaryText),
            onPressed: _reset,
            tooltip: 'Reset to default',
          ),
          IconButton(
            icon: Icon(Icons.save_outlined, color: _hasUnsaved ? Colors.white : KaloColors.secondaryText),
            onPressed: _hasUnsaved ? _save : null,
            tooltip: 'Save',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSizeSelector(),
          Expanded(child: _buildContent()),
          _buildPreviewSection(config),
        ],
      ),
    );
  }

  Widget _buildSizeSelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        color: KaloColors.frostWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KaloColors.frostBorder),
      ),
      child: Row(
        children: WidgetSize.values.map((size) {
          final selected = _selectedSize == size;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onSizeChanged(size),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Icon(
                      size == WidgetSize.small ? Icons.widgets_outlined :
                          size == WidgetSize.medium ? Icons.space_dashboard_outlined :
                              Icons.dashboard_outlined,
                      color: selected ? Colors.white : KaloColors.secondaryText,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      size.name[0].toUpperCase() + size.name.substring(1),
                      style: TextStyle(
                        color: selected ? Colors.white : KaloColors.secondaryText,
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    final available = WidgetBlockType.values.where((b) => b.minSize.index <= _selectedSize.index).toList();

    return Column(
      children: [
        _buildBlockPalette(available),
        Divider(color: KaloColors.frostBorder, height: 1),
        Expanded(child: _buildActiveList()),
      ],
    );
  }

  Widget _buildBlockPalette(List<WidgetBlockType> available) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BLOCKS',
            style: TextStyle(color: KaloColors.secondaryText, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: available.map((type) {
              final active = _blocks.contains(type);
              return GestureDetector(
                onTap: () => _toggleBlock(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? Colors.white.withValues(alpha: 0.15) : KaloColors.frostWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active ? Colors.white38 : KaloColors.frostBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active ? Icons.check : Icons.add,
                        size: 14,
                        color: active ? Colors.white : KaloColors.secondaryText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        type.label,
                        style: TextStyle(
                          color: active ? Colors.white : KaloColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveList() {
    final activeBlocks = List<WidgetBlockType>.from(_blocks);

    if (activeBlocks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app_outlined, color: KaloColors.secondaryText, size: 36),
            const SizedBox(height: 8),
            Text(
              'Tap blocks above to add them',
              style: TextStyle(color: KaloColors.secondaryText, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Long-press to reorder',
              style: TextStyle(color: KaloColors.secondaryText, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: activeBlocks.length,
      onReorderItem: (oldIndex, newIndex) => _onReorder(oldIndex, newIndex),
      proxyDecorator: (child, index, animation) {
        return Material(
          color: Colors.transparent,
          elevation: 4,
          shadowColor: Colors.white24,
          borderRadius: BorderRadius.circular(12),
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final type = activeBlocks[index];
        return Container(
          key: ValueKey('block_${type.name}_$_selectedSize'),
          margin: const EdgeInsets.symmetric(vertical: 3),
          decoration: BoxDecoration(
            color: KaloColors.frostWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: KaloColors.frostBorder),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            leading: ReorderableDragStartListener(
              index: index,
              child: Icon(Icons.drag_indicator, color: KaloColors.secondaryText, size: 24),
            ),
            title: Text(
              type.label,
              style: TextStyle(color: KaloColors.primaryText, fontSize: 14),
            ),
            trailing: Icon(
              Icons.check_circle,
              color: Colors.white38,
              size: 20,
            ),
            dense: true,
          ),
        );
      },
    );
  }

  Widget _buildPreviewSection(WidgetConfig config) {
    final previewBlocks = _blocks.where((b) => b.minSize.index <= _selectedSize.index).toList();

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KaloColors.frostWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: KaloColors.frostBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              children: [
                Icon(Icons.visibility_outlined, color: KaloColors.secondaryText, size: 16),
                const SizedBox(width: 6),
                Text(
                  'PREVIEW',
                  style: TextStyle(color: KaloColors.secondaryText, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1),
                ),
              ],
            ),
          ),
          WidgetPreview(blocks: previewBlocks, size: _selectedSize),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
