import 'package:flutter/material.dart';
import 'package:live_tracking/controllers/location_controller.dart';
import 'package:live_tracking/screens/home_screen.dart';
import 'package:provider/provider.dart';

class LiveTracking extends StatelessWidget {
  const LiveTracking({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocationController()),
      ],
      child: MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen()),
    );
  }
}
