import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../services/navigation_provider.dart';
import '../../services/database_service.dart';
import '../../services/api_key_provider.dart';
import '../../services/proxy_config.dart';
import '../../services/device_service.dart';
import '../../services/crypto_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _customUrlController = TextEditingController();
  final _weatherKeyController = TextEditingController();
  final _aqiKeyController = TextEditingController();

  @override
  void dispose() {
    _customUrlController.dispose();
    _weatherKeyController.dispose();
    _aqiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveWeatherKey(String rawKey) async {
    if (rawKey.trim().isEmpty) return;
    try {
      final deviceService = ref.read(deviceServiceProvider);
      final fingerprint = await deviceService.getHardwareFingerprint();
      final encrypted = encryptLocalKey(rawKey.trim(), fingerprint);
      final db = ref.read(databaseServiceProvider);
      await db.saveApiKey('openweathermap', encrypted);
      ref.invalidate(apiKeysProvider);
    } finally {}
  }

  Future<void> _saveAqiKey(String rawKey) async {
    if (rawKey.trim().isEmpty) return;
    try {
      final deviceService = ref.read(deviceServiceProvider);
      final fingerprint = await deviceService.getHardwareFingerprint();
      final encrypted = encryptLocalKey(rawKey.trim(), fingerprint);
      final db = ref.read(databaseServiceProvider);
      await db.saveApiKey('waqi', encrypted);
      ref.invalidate(apiKeysProvider);
    } finally {}
  }

  void _showApiKeyDialog(String provider, String label, String hint, Future<void> Function(String) onSave) {
    final controller = provider == 'openweathermap' ? _weatherKeyController : _aqiKeyController;
    controller.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(label, style: const TextStyle(color: KaloColors.primaryText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Stored encrypted on-device and sent securely to the proxy.',
              style: TextStyle(color: KaloColors.secondaryText, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              style: const TextStyle(color: KaloColors.primaryText),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: KaloColors.secondaryText),
                filled: true,
                fillColor: KaloColors.frostWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: KaloColors.frostBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: KaloColors.frostBorder),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: KaloColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showProxyDialog() {
    final currentUrl = ref.read(proxyBaseUrlProvider);
    _customUrlController.text = currentUrl;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Proxy Server', style: TextStyle(color: KaloColors.primaryText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Use the public Kalo proxy or your own Vercel deployment.',
              style: TextStyle(color: KaloColors.secondaryText, fontSize: 13),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(proxyBaseUrlProvider.notifier).resetToDefault();
                  Navigator.pop(ctx);
                },
                icon: const Icon(Icons.public, size: 18),
                label: const Text('Use Public Proxy'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(child: Divider(color: KaloColors.frostBorder)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('OR', style: TextStyle(color: KaloColors.secondaryText, fontSize: 11)),
                ),
                Expanded(child: Divider(color: KaloColors.frostBorder)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _customUrlController,
              style: const TextStyle(color: KaloColors.primaryText),
              decoration: InputDecoration(
                hintText: 'https://kalo-vercel.vercel.app',
                hintStyle: const TextStyle(color: KaloColors.secondaryText),
                filled: true,
                fillColor: KaloColors.frostWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: KaloColors.frostBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: KaloColors.frostBorder),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: KaloColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(proxyBaseUrlProvider.notifier).setUrl(_customUrlController.text);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paradigm = ref.watch(navigationParadigmProvider);
    final unitPref = ref.watch(unitPreferenceProvider);
    final locationsAsync = ref.watch(allLocationsProvider);
    final proxyUrl = ref.watch(proxyBaseUrlProvider);
    final apiKeysAsync = ref.watch(apiKeysProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: KaloColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings', style: TextStyle(color: KaloColors.primaryText)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: 'Navigation'),
          const SizedBox(height: 8),
          _buildChoiceChip(
            label: 'Location Carousel',
            subtitle: 'Swipe left/right to switch locations',
            selected: paradigm == NavigationParadigm.locationCarousel,
            onTap: () => ref.read(navigationParadigmProvider.notifier).state = NavigationParadigm.locationCarousel,
          ),
          const SizedBox(height: 8),
          _buildChoiceChip(
            label: 'Stack View',
            subtitle: 'Swipe up/down to switch locations',
            selected: paradigm == NavigationParadigm.stackView,
            onTap: () => ref.read(navigationParadigmProvider.notifier).state = NavigationParadigm.stackView,
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Units'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: KaloColors.frostFill,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.thermostat_outlined, color: KaloColors.secondaryText, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Temperature', style: TextStyle(color: KaloColors.primaryText, fontSize: 15)),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: unitPref,
                    icon: const Icon(Icons.expand_more, color: KaloColors.secondaryText),
                    dropdownColor: const Color(0xFF1C1C2E),
                    style: const TextStyle(color: KaloColors.primaryText, fontSize: 14),
                    items: const [
                      DropdownMenuItem(value: 'Celsius', child: Text('Celsius')),
                      DropdownMenuItem(value: 'Fahrenheit', child: Text('Fahrenheit')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        ref.read(unitPreferenceProvider.notifier).state = val;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'API Keys'),
          const SizedBox(height: 8),
          apiKeysAsync.when(
            data: (keys) => Column(
              children: [
                _buildApiKeyTile(
                  icon: Icons.cloud_outlined,
                  label: 'OpenWeatherMap',
                  hasKey: keys.any((k) => k.provider == 'openweathermap'),
                  onTap: () => _showApiKeyDialog(
                    'openweathermap',
                    'OpenWeatherMap API Key',
                    'Enter your API key',
                    _saveWeatherKey,
                  ),
                ),
                const SizedBox(height: 8),
                _buildApiKeyTile(
                  icon: Icons.air_outlined,
                  label: 'WAQI (Air Quality)',
                  hasKey: keys.any((k) => k.provider == 'waqi'),
                  onTap: () => _showApiKeyDialog(
                    'waqi',
                    'WAQI API Key',
                    'Enter your API key',
                    _saveAqiKey,
                  ),
                ),
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Proxy Server'),
          const SizedBox(height: 8),
          _buildTile(
            icon: Icons.dns_outlined,
            label: 'Server URL',
            subtitle: proxyUrl,
            onTap: _showProxyDialog,
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Saved Locations'),
          const SizedBox(height: 8),
          locationsAsync.when(
            data: (locations) => locations.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No saved locations', style: TextStyle(color: KaloColors.secondaryText)),
                  )
                : Column(
                    children: locations.map((loc) => ListTile(
                      leading: const Icon(Icons.location_city, color: KaloColors.secondaryText),
                      title: Text(loc.name, style: const TextStyle(color: KaloColors.primaryText)),
                      subtitle: Text(
                        '${loc.latitude.toStringAsFixed(2)}, ${loc.longitude.toStringAsFixed(2)}',
                        style: const TextStyle(color: KaloColors.secondaryText, fontSize: 12),
                      ),
                    )).toList(),
                  ),
            loading: () => const SizedBox(height: 32, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
            error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeyTile({
    required IconData icon,
    required String label,
    required bool hasKey,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KaloColors.frostWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: KaloColors.frostBorder, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: KaloColors.primaryText, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: const TextStyle(color: KaloColors.primaryText, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: hasKey ? Colors.green.withValues(alpha: 0.2) : KaloColors.frostWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasKey ? Colors.green : KaloColors.frostBorder,
                  width: 1,
                ),
              ),
              child: Text(
                hasKey ? 'Set' : 'Not set',
                style: TextStyle(
                  color: hasKey ? Colors.green : KaloColors.secondaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KaloColors.frostWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: KaloColors.frostBorder, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: KaloColors.primaryText, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: KaloColors.primaryText, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: KaloColors.secondaryText, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: KaloColors.secondaryText, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withValues(alpha: 0.15) : KaloColors.frostWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.white : KaloColors.frostBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: KaloColors.primaryText, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: KaloColors.secondaryText, fontSize: 13)),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: KaloColors.secondaryText,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}
