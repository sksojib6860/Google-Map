import 'dart:async';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationController extends ChangeNotifier {
  Set<LatLng> position = {};
  StreamSubscription<Position>? _positionStream;

  final CustomInfoWindowController infoWindowController =
  CustomInfoWindowController();
  late GoogleMapController mapController;

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> getLatLng() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return;
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {


      _positionStream?.cancel();


      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
        ),
      ).listen(
            (Position event) {
          position.add(LatLng(event.latitude, event.longitude));
          notifyListeners();
          infoWindowController.onCameraMove!();
        },
        onError: (e) {
          debugPrint("Location stream error: $e");
        },
      );


      try {
        Position firstPosition = await Geolocator.getCurrentPosition(
          locationSettings : .new(accuracy: .bestForNavigation,distanceFilter: 0),
        );
        position.add(LatLng(firstPosition.latitude, firstPosition.longitude));
      } catch (e) {
        debugPrint("Get current position error: $e");
      }

      notifyListeners();
    }
  }
}