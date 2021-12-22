import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './user_type.dart';

class LocationProvider with ChangeNotifier {
  double latitude = 0.0;
  double longitude = 0.0;
  String address = "";
  bool isLocation = false;
  bool isDenied = false;
  StreamSubscription<gl.Position>? positionStreamSubscription;

  Future<void> getCurrentLocation() async {
    print("in fun");
    Location location = new Location();
    gl.Position _locationData;

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        isLocation = false;
        isDenied = true;
        notifyListeners();

        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        isDenied = true;
        isLocation = false;
        notifyListeners();
        return;
      }
    }

    positionStreamSubscription = gl.Geolocator.getPositionStream(
            desiredAccuracy: gl.LocationAccuracy.best, distanceFilter: 0)
        .listen((event) async {
      print("Hello");
      print(event);
      latitude = event.latitude;
      longitude = event.longitude;
      isLocation = true;
      isDenied = false;

      notifyListeners();
      if (UserType.userType == 'Mechanic') {
        FirebaseFirestore.instance
            .collection("mechanic_locations")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
          'location': GeoPoint(latitude, longitude),
          'username': UserType.name,
          'phone': UserType.phone,
          'email': UserType.email,
        });
      } else if (UserType.userType == 'Customer') {
        var userId = FirebaseAuth.instance.currentUser!.uid;
        try {
          final snapshot = await FirebaseFirestore.instance
              .collection('customers')
              .doc(userId)
              .collection('mechanics')
              .get();
          for (int i = 0; i < snapshot.docs.length; i++) {
            var id = snapshot.docs[i].id;
            await FirebaseFirestore.instance
                .collection('customer_locations')
                .doc(id)
                .collection('customer_location')
                .doc(userId)
                .set({
              'location': GeoPoint(latitude, longitude),
              'username': UserType.name,
              'phone': UserType.phone,
              'email': UserType.email,
            });
          }
        } catch (e) {
          print(e);
        }
      }
    });
  }
}
