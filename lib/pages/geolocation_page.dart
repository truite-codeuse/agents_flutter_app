import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

/// THIS PAGE IS NOT USED IN THE PROJECT
/// IT WAS ONLY A TEST PAGE FOR THE GPS MODULE

class GeolocationPage extends StatelessWidget {
  const GeolocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _determinePosition(),
      builder: (BuildContext context, AsyncSnapshot<Position> pos) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: positionToText(pos.data),
          ),
        );
      }
    );
  }

  List<Text> positionToText(Position? pos) {
    if (pos != null){
      return [
          Text(pos.latitude.toString()),
          Text(pos.longitude.toString()),
          Text(pos.altitude.toString())
        ];
    }
    else {
      return [const Text("Finding location...")];
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

}
