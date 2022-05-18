import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double lat = 0.0;
  double lng = 0.0;

  findMyLocation() async {
    bool devicePermission;
    devicePermission = await Geolocator.isLocationServiceEnabled();
    if (devicePermission) {
      var appLevel = await Geolocator.checkPermission();
      if (appLevel == LocationPermission.denied) {
        appLevel = await Geolocator.requestPermission();
      } else if (appLevel == LocationPermission.deniedForever) {
        print("Error: App location permission denied forever");
      }
      var location = await Geolocator.getCurrentPosition();
      print(location.accuracy);

      setState(() {
        lat = location.latitude;
        lng = location.longitude;
      });
      print(lat);
      print(lng);
    } else {
      print("Error : GPS sensor permission issue, device level");
    }

    final LatLng _center = LatLng(lat, lng);
  }

  @override
  initState() {
    findMyLocation();
    super.initState();
  }

  Completer<GoogleMapController> _controller = Completer();

  late CameraPosition initialPoint = CameraPosition(
      target: LatLng(34.47554013447298, -100.6012667768258),
      tilt: 59.440717697143555,
      zoom: 3);

  late CameraPosition mylocation = CameraPosition(
      target: LatLng(lat, lng), tilt: 59.440717697143555, zoom: 20);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Maps'),
        centerTitle: true,
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initialPoint,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToMyLocation,
        label: const Text("my location"),
        icon: Icon(Icons.my_location),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _goToMyLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(mylocation));
  }
}
