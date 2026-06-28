import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../services/update_service.dart';

enum _DialogState { checking, available, downloading, ready, error }

class UpdateDialog extends ConsumerStatefulWidget {
  final AppUpdate update;
  final String currentVersion;

  const UpdateDialog({super.key, required this.update, required this.currentVersion});

  static Future<void> show(BuildContext context, AppUpdate update, String currentVersion) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => UpdateDialog(update: update, currentVersion: currentVersion),
    );
  }

  @override
  ConsumerState<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends ConsumerState<UpdateDialog> {
  _DialogState _state = _DialogState.available;
  String? _errorMessage;
  String? _downloadedPath;

  Future<void> _download() async {
    setState(() => _state = _DialogState.downloading);
    try {
      final path = await downloadApk(widget.update.downloadUrl);
      setState(() {
        _downloadedPath = path;
        _state = _DialogState.ready;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _state = _DialogState.error;
      });
    }
  }

  Future<void> _install() async {
    if (_downloadedPath == null) return;
    final ok = await installApk(_downloadedPath!);
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.system_update, color: Colors.blue.shade300, size: 24),
          const SizedBox(width: 10),
          Text('Update Available', style: TextStyle(color: KaloColors.primaryText, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: _buildContent(),
      ),
      actions: _buildActions(),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'v${widget.currentVersion} → v${widget.update.version}',
          style: TextStyle(color: KaloColors.secondaryText, fontSize: 14),
        ),
        if (_state == _DialogState.downloading || _state == _DialogState.ready) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _state == _DialogState.ready ? 1 : null,
              backgroundColor: KaloColors.frostWhite,
              valueColor: AlwaysStoppedAnimation(Colors.blue.shade300),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _state == _DialogState.ready ? 'Download complete' : 'Downloading...',
            style: TextStyle(color: KaloColors.secondaryText, fontSize: 12),
          ),
        ],
        if (_state == _DialogState.error) ...[
          const SizedBox(height: 12),
          Text('Download failed: $_errorMessage', style: TextStyle(color: Colors.red.shade300, fontSize: 13)),
        ],
        if (widget.update.releaseNotes != null && widget.update.releaseNotes!.isNotEmpty && _state == _DialogState.available) ...[
          const SizedBox(height: 12),
          Text('What\'s new', style: TextStyle(color: KaloColors.primaryText, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: Text(
                widget.update.releaseNotes!,
                style: TextStyle(color: KaloColors.secondaryText, fontSize: 13, height: 1.4),
              ),
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildActions() {
    switch (_state) {
      case _DialogState.available:
        return [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later', style: TextStyle(color: KaloColors.secondaryText)),
          ),
          FilledButton.icon(
            onPressed: _download,
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Download & Install'),
            style: FilledButton.styleFrom(backgroundColor: Colors.blue.shade700),
          ),
        ];
      case _DialogState.downloading:
        return [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: KaloColors.secondaryText)),
          ),
        ];
      case _DialogState.ready:
        return [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Later', style: TextStyle(color: KaloColors.secondaryText)),
          ),
          FilledButton.icon(
            onPressed: _install,
            icon: const Icon(Icons.download_done, size: 18),
            label: const Text('Install'),
            style: FilledButton.styleFrom(backgroundColor: Colors.green.shade700),
          ),
        ];
      case _DialogState.error:
        return [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: KaloColors.secondaryText)),
          ),
          TextButton(
            onPressed: _download,
            child: Text('Retry', style: TextStyle(color: Colors.blue.shade300)),
          ),
        ];
      case _DialogState.checking:
        return [];
    }
  }
}
