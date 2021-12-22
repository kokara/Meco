import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meco/models/user_type.dart';
import 'package:provider/provider.dart';
import '../models/location_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  var longitude = 0.0;
  var latitude = 0.0;
  LatLng latlng = LatLng(19.0760, 72.8777);
  var currUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    print("rebuild");
    var locationProvider = context.watch<LocationProvider>();
    longitude = locationProvider.longitude;
    latitude = locationProvider.latitude;
    latlng = LatLng(latitude, longitude);
    return Scaffold(
        appBar: AppBar(
          title: Text('Map'),
        ),
        body: StreamBuilder(
            stream: UserType.userType == 'Customer'
                ? FirebaseFirestore.instance
                    .collection('mechanic_locations')
                    .snapshots()
                : FirebaseFirestore.instance
                    .collection('customer_locations')
                    .doc(currUserId)
                    .collection('customer_location')
                    .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              List<Marker> markers = [];

              if (snapshot.hasData) {
                markers = [];
                final doc = snapshot.data!.docs;
                int n = doc.length;
                for (int i = 0; i < n; i++) {
                  if (doc[i].id != currUserId) {
                    LatLng lt = LatLng(doc[i]['location'].latitude,
                        doc[i]['location'].longitude);
                    markers.add(
                      Marker(
                        point: lt,
                        builder: (ctx) => PopupMenuButton(
                            icon: Icon(
                              Icons.pin_drop_rounded,
                              color: Theme.of(context).accentColor,
                            ),
                            onSelected: (item) {},
                            itemBuilder: (context) => [
                                  PopupMenuItem(
                                      value: 0,
                                      child: Column(
                                        children: [
                                          Text(doc[i]['username']),
                                          Text(doc[i]['phone']),
                                        ],
                                      ))
                                ]),
                      ),
                    );
                  }
                }
              }
              markers.add(Marker(
                point: latlng,
                builder: (ctx) => PopupMenuButton(
                    icon: Icon(
                      Icons.pin_drop_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                    onSelected: (item) {},
                    itemBuilder: (context) => [
                          PopupMenuItem(
                              value: 0,
                              child: Column(
                                children: [
                                  Text(UserType.name),
                                  Text(UserType.phone),
                                ],
                              ))
                        ]),
              ));
              return FlutterMap(
                options:
                    new MapOptions(center: latlng, maxZoom: 18, minZoom: 1),
                layers: [
                  new TileLayerOptions(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c']),
                  MarkerLayerOptions(markers: markers),
                ],
              );
            }));
  }
}
