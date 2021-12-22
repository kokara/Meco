import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/user_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/location_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/user_tile.dart';
import './sent_request.dart';

class MechanicScreen extends StatefulWidget {
  const MechanicScreen({Key? key}) : super(key: key);

  @override
  _MechanicScreenState createState() => _MechanicScreenState();
}

class _MechanicScreenState extends State<MechanicScreen> {
  Future<void> refresh_mech() {
    return Future.delayed(Duration.zero, () {
      setState(() {});
    });
  }

  void Navigate(ctx) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => SentRequestScreen()));
  }

  @override
  Widget build(BuildContext context) {
    var locationProvider = context.read<LocationProvider>();
    return Scaffold(
        appBar: AppBar(
          title: Text(UserType.userType == 'Customer'
              ? 'Mechanics Nearby'
              : 'Customer Requests'),
          actions: UserType.userType == 'Customer'
              ? [
                  PopupMenuButton(
                      onSelected: (item) => Navigate(context),
                      itemBuilder: (context) => [
                            PopupMenuItem(
                                value: 0, child: Text('Sent Requests'))
                          ]),
                ]
              : [],
        ),
        body: UserType.userType == 'Customer'
            ? StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('mechanic_locations')
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
                  return RefreshIndicator(
                    onRefresh: refresh_mech,
                    color: Theme.of(context).primaryColor,
                    child: ListView.builder(
                        itemCount: doc.length,
                        itemBuilder: (context, i) {
                          var dist = Geolocator.distanceBetween(
                              locationProvider.latitude,
                              locationProvider.longitude,
                              doc[i]['location'].latitude,
                              doc[i]['location'].longitude);
                          if (dist <= 5000.0) {
                            dist = dist / 1000.0;
                            String distKm = dist.toStringAsFixed(2);
                            print(distKm);

                            return UserTile(
                                isSentRequest: false,
                                id: doc[i].id,
                                dist: distKm,
                                name: doc[i]['username'],
                                phone: doc[i]['phone'],
                                email: doc[i]['email'],
                                latitude: doc[i]['location'].latitude,
                                longitude: doc[i]['location'].longitude);
                          }
                          return Container(
                            height: 0,
                          );
                        }),
                  );
                })
            : StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('mechanics')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('customers')
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
                  return RefreshIndicator(
                    onRefresh: refresh_mech,
                    color: Theme.of(context).primaryColor,
                    child: ListView.builder(
                        itemCount: doc.length,
                        itemBuilder: (context, i) {
                          var userLatitude = doc[i]['location'].latitude;
                          var userLongitude = doc[i]['location'].longitude;

                          double dist = -1;
                          String distKm = '-1';
                          dist = Geolocator.distanceBetween(
                              locationProvider.latitude,
                              locationProvider.longitude,
                              userLatitude,
                              userLongitude);

                          dist = dist / 1000.0;
                          distKm = dist.toStringAsFixed(2);
                          return UserTile(
                              isSentRequest: false,
                              id: doc[i].id,
                              dist: distKm,
                              name: doc[i]['username'],
                              phone: doc[i]['phone'],
                              email: doc[i]['email'],
                              latitude: userLatitude,
                              longitude: userLongitude);
                        }
                        /*  var userLatitude = 0.0;
                          var userLongitude = 0.0;

                          double dist = -1;
                          String distKm = '-1';
                          try {
                            print("in location");
                            FirebaseFirestore.instance
                                .collection('customer_locations')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection('customer_location')
                                .doc(doc[i].id)
                                .get()
                                .then((value) {
                              userLatitude = value['location'].latitude;
                              userLongitude = value['location'].longitude;

                              print("userLatitude: " + userLatitude.toString());
                              dist = Geolocator.distanceBetween(
                                  locationProvider.latitude,
                                  locationProvider.longitude,
                                  userLatitude,
                                  userLongitude);

                              dist = dist / 1000.0;
                              distKm = dist.toStringAsFixed(2);

                              print(distKm);
                               return UserTile(
                                  id: doc[i].id,
                                  dist: distKm,
                                  name: doc[i]['username'],
                                  phone: doc[i]['phone'],
                                  email: doc[i]['email'],
                                  latitude: userLatitude,
                                  longitude: userLongitude);
                            });
                          } catch (e) {
                            print(e);
                          }*/

                        ),
                  );
                },
              ));
  }
}
