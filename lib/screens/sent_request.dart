import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../models/user_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/location_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/user_tile.dart';

class SentRequestScreen extends StatefulWidget {
  const SentRequestScreen({Key? key}) : super(key: key);

  @override
  _SentRequestScreenState createState() => _SentRequestScreenState();
}

class _SentRequestScreenState extends State<SentRequestScreen> {
  @override
  Widget build(BuildContext context) {
    var locationProvider = context.read<LocationProvider>();
    return Scaffold(
        appBar: AppBar(
          title: Text('Sent Requests'),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('customers')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('mechanics')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              );
            if (snapshot.hasError)
              return Center(
                child: Text('Something went wrong'),
              );
            var doc = snapshot.data!.docs;
            return ListView.builder(
                itemCount: doc.length,
                itemBuilder: (context, i) {
                  var userLatitude = doc[i]['location'].latitude;
                  var userLongitude = doc[i]['location'].longitude;

                  double dist = -1;
                  String distKm = '-1';
                  dist = Geolocator.distanceBetween(locationProvider.latitude,
                      locationProvider.longitude, userLatitude, userLongitude);

                  dist = dist / 1000.0;
                  distKm = dist.toStringAsFixed(2);
                  return UserTile(
                      isSentRequest: true,
                      id: doc[i].id,
                      dist: distKm,
                      name: doc[i]['username'],
                      phone: doc[i]['phone'],
                      email: doc[i]['email'],
                      latitude: userLatitude,
                      longitude: userLongitude);
                });
          },
        ));
  }
}
