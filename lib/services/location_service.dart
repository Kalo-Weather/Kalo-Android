import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final locationServiceProvider = Provider((ref) => LocationService());

final currentPositionProvider = FutureProvider<Position?>((ref) async {
  final service = ref.watch(locationServiceProvider);
  final hasPermission = await service.requestPermission();
  if (hasPermission) {
    return await service.getCurrentLocation();
  }
  return null;
});

final currentLocalityProvider = FutureProvider<String?>((ref) async {
  final pos = await ref.watch(currentPositionProvider.future);
  if (pos == null) return null;
  final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
  if (placemarks.isEmpty) return null;
  return placemarks.first.locality ?? placemarks.first.subAdministrativeArea ?? placemarks.first.administrativeArea;
});

final currentCountryCodeProvider = FutureProvider<String?>((ref) async {
  final pos = await ref.watch(currentPositionProvider.future);
  if (pos == null) return null;
  final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
  if (placemarks.isEmpty) return null;
  return placemarks.first.isoCountryCode;
});

class LocationService {
  Future<bool> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    } 

    return true;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
    } catch (e) {
      return null;
    }
  }
}
