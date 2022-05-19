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
  //GOOGLE ANIMATION CONTROLLER
  final Completer<GoogleMapController> _controller = Completer();
  //GOOGLE MARK CONTROLLER
  final Completer<GoogleMapController> controller = Completer();
  final Set<Marker> _markers = {};

  //GOOGLE MAP INIT POSITION
  late CameraPosition initialPoint = const CameraPosition(
      target: LatLng(34.47554013447298, -100.6012667768258),
      tilt: 59.440717697143555,
      zoom: 3);

  // TODO FIND LAT AND LNG
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
      // print(location.accuracy);

      setState(() {
        lat = location.latitude;
        lng = location.longitude;
      });
    } else {
      print("Error : GPS sensor permission issue, device level");
    }
  }

  //TODO CREATE THE MARK ON THE MAP
  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _markers
          .add(Marker(markerId: MarkerId('id-1'), position: LatLng(lat, lng)));
    });
  }

  //TODO GO TO MY POSITION GOOGLE MAPS
  Future<void> _goToMyLocation() async {
    late CameraPosition mylocation = CameraPosition(
        target: LatLng(lat, lng), tilt: 59.440717697143555, zoom: 20);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(mylocation));
    _onMapCreated(controller);
  }

  @override
  initState() {
    findMyLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps'),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        markers: _markers,
        initialCameraPosition: initialPoint,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        onPressed: _goToMyLocation,
        child: const Icon(Icons.my_location),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
