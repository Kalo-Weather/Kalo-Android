import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../services/navigation_provider.dart';
import '../../services/database_service.dart';
import '../../services/api_key_provider.dart';
import '../../services/proxy_config.dart';
import '../../services/device_service.dart';
import '../../services/crypto_service.dart';
import '../../services/location_service.dart';

import '../../services/animated_background_provider.dart';
import '../../services/update_service.dart';
import '../../services/widget_service.dart';
import '../update/update_dialog.dart';
import '../widget_editor/widget_editor_screen.dart';
import '../../models/weather_location.dart';

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
        title: Text(label, style: TextStyle(color: KaloColors.primaryText)),
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
              style: TextStyle(color: KaloColors.primaryText),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: KaloColors.secondaryText),
                filled: true,
                fillColor: KaloColors.frostWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: KaloColors.frostBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: KaloColors.frostBorder),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: KaloColors.secondaryText)),
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
        title: Text('Proxy Server', style: TextStyle(color: KaloColors.primaryText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
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
            Row(
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
              style: TextStyle(color: KaloColors.primaryText),
              decoration: InputDecoration(
                hintText: 'https://kalo-vercel.vercel.app',
                hintStyle: TextStyle(color: KaloColors.secondaryText),
                filled: true,
                fillColor: KaloColors.frostWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: KaloColors.frostBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: KaloColors.frostBorder),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: KaloColors.secondaryText)),
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

  void _showAddLocationDialog() {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Location', style: TextStyle(color: KaloColors.primaryText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Search for a city or use your current location.',
              style: TextStyle(color: KaloColors.secondaryText, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: searchController,
              style: TextStyle(color: KaloColors.primaryText),
              decoration: InputDecoration(
                hintText: 'City name',
                hintStyle: TextStyle(color: KaloColors.secondaryText),
                filled: true,
                fillColor: KaloColors.frostWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: KaloColors.frostBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: KaloColors.frostBorder),
                ),
              ),
              onSubmitted: (_) => _searchAndAddLocation(searchController.text, ctx),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _addCurrentLocation();
                },
                icon: const Icon(Icons.gps_fixed, size: 18),
                label: const Text('Use Current Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: KaloColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () => _searchAndAddLocation(searchController.text, ctx),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Future<void> _searchAndAddLocation(String query, BuildContext dialogContext) async {
    if (query.trim().isEmpty) return;
    Navigator.pop(dialogContext);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      final results = await geo.locationFromAddress(query);
      if (results.isEmpty) {
        if (mounted) Navigator.pop(context);
        _showError('Location not found');
        return;
      }

      final loc = results.first;
      final placemarks = await geo.placemarkFromCoordinates(loc.latitude, loc.longitude);
      final name = placemarks.isNotEmpty
          ? (placemarks.first.locality ?? placemarks.first.subAdministrativeArea ?? placemarks.first.administrativeArea ?? query)
          : query;

      final db = ref.read(databaseServiceProvider);
      await db.addLocation(name, loc.latitude, loc.longitude);
      ref.invalidate(allLocationsProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showError('Could not find location: $e');
    }
  }

  Future<void> _addCurrentLocation() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      final service = ref.read(locationServiceProvider);
      final hasPermission = await service.requestPermission();
      if (!hasPermission) {
        if (mounted) Navigator.pop(context);
        _showError('Location permission denied');
        return;
      }

      final position = await service.getCurrentLocation();
      if (position == null) {
        if (mounted) Navigator.pop(context);
        _showError('Could not get current location');
        return;
      }

      final placemarks = await geo.placemarkFromCoordinates(position.latitude, position.longitude);
      final name = placemarks.isNotEmpty
          ? (placemarks.first.locality ?? placemarks.first.subAdministrativeArea ?? placemarks.first.administrativeArea ?? 'Current Location')
          : 'Current Location';

      final db = ref.read(databaseServiceProvider);
      await db.addLocation(name, position.latitude, position.longitude);
      ref.invalidate(allLocationsProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showError('Error: $e');
    }
  }

  Future<void> _deleteLocation(WeatherLocation loc) async {
    final db = ref.read(databaseServiceProvider);
    await db.deleteLocation(loc.id!);
    ref.invalidate(allLocationsProvider);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade800),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paradigm = ref.watch(navigationParadigmProvider);
    final unitPref = ref.watch(unitPreferenceProvider);
    final timeFormat = ref.watch(timeFormatProvider);
    final currentAppVersion = ref.watch(currentVersionProvider).valueOrNull ?? '?';
    final locationsAsync = ref.watch(allLocationsProvider);
    final proxyUrl = ref.watch(proxyBaseUrlProvider);
    final apiKeysAsync = ref.watch(apiKeysProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: KaloColors.primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings', style: TextStyle(color: KaloColors.primaryText)),
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
                Icon(Icons.thermostat_outlined, color: KaloColors.secondaryText, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Temperature', style: TextStyle(color: KaloColors.primaryText, fontSize: 15)),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: unitPref,
                    icon: Icon(Icons.expand_more, color: KaloColors.secondaryText),
                    dropdownColor: const Color(0xFF1C1C2E),
                    style: TextStyle(color: KaloColors.primaryText, fontSize: 14),
                    items: const [
                      DropdownMenuItem(value: 'Celsius', child: Text('Celsius')),
                      DropdownMenuItem(value: 'Fahrenheit', child: Text('Fahrenheit')),
                    ],
                    onChanged: (val) async {
                      if (val != null) {
                        ref.read(unitPreferenceProvider.notifier).state = val;
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('unit_preference', val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: KaloColors.frostFill,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.access_time_outlined, color: KaloColors.secondaryText, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Time Format', style: TextStyle(color: KaloColors.primaryText, fontSize: 15)),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: timeFormat,
                    icon: Icon(Icons.expand_more, color: KaloColors.secondaryText),
                    dropdownColor: const Color(0xFF1C1C2E),
                    style: TextStyle(color: KaloColors.primaryText, fontSize: 14),
                    items: const [
                      DropdownMenuItem(value: '24h', child: Text('24-hour')),
                      DropdownMenuItem(value: '12h', child: Text('12-hour')),
                    ],
                    onChanged: (val) async {
                      if (val != null) {
                        ref.read(timeFormatProvider.notifier).state = val;
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('time_format', val);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Display'),
          const SizedBox(height: 8),
          _buildToggleTile(
            icon: Icons.animation_outlined,
            label: 'Animated Background',
            subtitle: 'Weather animations on dashboard (disable if laggy)',
            value: ref.watch(animatedBackgroundProvider),
            onChanged: (val) => ref.read(animatedBackgroundProvider.notifier).set(val),
          ),
          const SizedBox(height: 8),
          _buildTile(
            icon: Icons.dashboard_customize_outlined,
            label: 'Customize Widgets',
            subtitle: 'Drag, reorder, and toggle blocks per widget size',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WidgetEditorScreen())),
          ),
          const SizedBox(height: 8),
          _buildToggleTile(
            icon: Icons.widgets_outlined,
            label: 'Auto-Refresh Widgets',
            subtitle: 'Update widgets when weather refreshes',
            value: ref.watch(widgetRefreshEnabledProvider),
            onChanged: (val) async {
              ref.read(widgetRefreshEnabledProvider.notifier).state = val;
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('widgetRefreshEnabled', val);
            },
          ),
          const SizedBox(height: 8),
          _buildToggleTile(
            icon: Icons.lock_outline,
            label: 'Now Bar (One UI 6+)',
            subtitle: 'Show weather on Samsung lock screen Now Bar',
            value: ref.watch(nowBarEnabledProvider),
            onChanged: (val) async {
              ref.read(nowBarEnabledProvider.notifier).state = val;
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('nowBarEnabled', val);
            },
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
          _SectionHeader(title: 'Updates'),
          const SizedBox(height: 8),
          _buildTile(
            icon: Icons.system_update_outlined,
            label: 'Check for Updates',
            subtitle: 'v$currentAppVersion',
            onTap: _checkForUpdates,
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Saved Locations'),
          const SizedBox(height: 8),
          locationsAsync.when(
            data: (locations) => Column(
              children: [
                _buildTile(
                  icon: Icons.add_location_outlined,
                  label: 'Add Location',
                  subtitle: 'Search city or use current location',
                  onTap: _showAddLocationDialog,
                ),
                const SizedBox(height: 8),
                if (locations.isEmpty)
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No saved locations', style: TextStyle(color: KaloColors.secondaryText)),
                  )
                else
                  ...locations.map((loc) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildLocationTile(loc),
                  )),
              ],
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
              child: Text(label, style: TextStyle(color: KaloColors.primaryText, fontSize: 16, fontWeight: FontWeight.w600)),
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

  Future<void> _checkForUpdates() async {
    ref.invalidate(updateInfoProvider);
    final update = await ref.read(updateInfoProvider.future);
    if (!mounted) return;
    if (update == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not check for updates'), backgroundColor: Colors.red),
      );
      return;
    }
    final current = await ref.read(currentVersionProvider.future);
    if (!mounted) return;
    if (isNewerVersion(update.version, current)) {
      UpdateDialog.show(context, update, current);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Already up to date (v$current)'), backgroundColor: Colors.green.shade700),
      );
    }
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
                  Text(label, style: TextStyle(color: KaloColors.primaryText, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: KaloColors.secondaryText, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: KaloColors.secondaryText, size: 20),
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
                  Text(label, style: TextStyle(color: KaloColors.primaryText, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: KaloColors.secondaryText, fontSize: 13)),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                Text(label, style: TextStyle(color: KaloColors.primaryText, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: KaloColors.secondaryText, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTile(WeatherLocation loc) {
    return Container(
      decoration: BoxDecoration(
        color: KaloColors.frostWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KaloColors.frostBorder, width: 1),
      ),
      child: ListTile(
        leading: Icon(Icons.location_city, color: KaloColors.secondaryText),
        title: Text(loc.name, style: TextStyle(color: KaloColors.primaryText)),
        subtitle: Text(
          '${loc.latitude.toStringAsFixed(2)}, ${loc.longitude.toStringAsFixed(2)}',
          style: TextStyle(color: KaloColors.secondaryText, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 20),
              onPressed: () => _renameLocation(loc),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: () => _deleteLocation(loc),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Future<void> _renameLocation(WeatherLocation loc) async {
    final controller = TextEditingController(text: loc.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Rename Location', style: TextStyle(color: KaloColors.primaryText)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: KaloColors.primaryText),
          decoration: InputDecoration(
            hintText: 'Location name',
            hintStyle: TextStyle(color: KaloColors.secondaryText),
            filled: true,
            fillColor: KaloColors.frostWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: KaloColors.frostBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: KaloColors.frostBorder),
            ),
          ),
          onSubmitted: (val) => Navigator.pop(ctx, val.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: KaloColors.secondaryText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty || newName == loc.name) return;
    final db = ref.read(databaseServiceProvider);
    await db.updateLocation(WeatherLocation(
      id: loc.id,
      name: newName,
      latitude: loc.latitude,
      longitude: loc.longitude,
      order: loc.order,
    ));
    ref.invalidate(allLocationsProvider);
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: KaloColors.secondaryText,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}
