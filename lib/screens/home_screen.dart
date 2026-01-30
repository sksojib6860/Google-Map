import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_tracking/controllers/location_controller.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {



  @override
  void initState() {
    Future.microtask(() async {
      if (mounted) {
        await context.read<LocationController>().getLatLng();
      }
    });
    super.initState();
  }


  @override
  void dispose() {
    Future.microtask(() {
      if(mounted){
       context.read<LocationController>().infoWindowController.dispose();
      }
    },);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LocationController locationController = context.watch<LocationController>();
    return Scaffold(
      body: Stack(
        children: [
          Consumer<LocationController>(
            builder: (context, provider, child) => provider.position.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    zoomControlsEnabled: false,
                    buildingsEnabled: true,
                    trafficEnabled: true,
                    compassEnabled: true,
                    myLocationEnabled: true,
                    fortyFiveDegreeImageryEnabled: true,
                    mapToolbarEnabled: false,
                    onTap: (_) => provider.infoWindowController.hideInfoWindow!(),
                    onCameraMove: (_) => provider.infoWindowController.onCameraMove!(),
                    onMapCreated: (controller) {
                     provider.mapController = controller;
                     provider.infoWindowController.googleMapController = controller;
                      controller.animateCamera(
                        duration: Duration(seconds: 4),
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: provider.position.first,
                            zoom: 16,
                          ),
                        ),
                      );
                    },
                    mapType: MapType.normal,
                    polylines: {
                      Polyline(
                        width: 5,
                        color: Colors.green,
                        polylineId: const PolylineId("my-polyline"),
                        points: provider.position.toList(),
                      ),
                    },
                    markers: {
                      Marker(
                        onTap: () {
                         provider.infoWindowController.addInfoWindow!(
                            InfoWindow(
                              title: "Starting point",
                              provider: provider,
                            ),
                            provider.position.first,
                          );
                        },
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen,
                        ),
                        markerId: const MarkerId("my-first-location"),
                        position: provider.position.first,
                      ),
                      Marker(
                        onTap: () {
                          provider.infoWindowController.addInfoWindow!(
                            InfoWindow(
                              title: "My Current Location",
                              provider: provider,
                            ),
                            provider.position.last,
                          );
                        },
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                        markerId: const MarkerId("my-last-location"),
                        position: provider.position.last,
                      ),
                    },
                    initialCameraPosition: CameraPosition(
                      target: provider.position.first,
                    ),
                  ),
          ),
          CustomInfoWindow(
            controller: locationController.infoWindowController,
            height: 80,
            width: 240,
            offset: 50,
          ),
        ],
      ),
    );
  }
}

class InfoWindow extends StatelessWidget {
  final String title;
  final LocationController provider;

  const InfoWindow({super.key, required this.title, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .all(10),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisAlignment: .spaceBetween,
        spacing: 10,
        children: [
          Row(
            spacing: 15,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.my_location_outlined, color: Colors.white, size: 30),
              Text(title, style: TextStyle(color: Colors.white)),
            ],
          ),
          Row(
            spacing: 5,
            mainAxisAlignment: .start,
            children: [
              Text(
                style: .new(color: Colors.white),
                provider.position.first.longitude.toString(),
              ),
              Text(",", style: .new(color: Colors.white)),
              Text(
                style: .new(color: Colors.white),

                provider.position.first.latitude.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
