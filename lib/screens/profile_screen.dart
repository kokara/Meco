import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_type.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/location_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String address = "";
  double latitude = 0;
  double longitude = 0;
  bool _isLoading = true;
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      var locationProvider = context.read<LocationProvider>();
      latitude = locationProvider.latitude;
      longitude = locationProvider.longitude;
      findAddress();
    });
  }

  void findAddress() async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    Placemark placeMark = placemarks[0];
    String add_name = placeMark.name.toString();
    String subLocality = placeMark.subLocality.toString();
    String locality = placeMark.locality.toString();
    String administrativeArea = placeMark.administrativeArea.toString();
    String postalCode = placeMark.postalCode.toString();
    String country = placeMark.country.toString();
    if (add_name.isNotEmpty) address += add_name;
    if (subLocality.isNotEmpty) address = address + "," + subLocality;
    if (locality.isNotEmpty) address = address + "," + locality;
    if (administrativeArea.isNotEmpty)
      address = address + "," + administrativeArea;
    if (postalCode.isNotEmpty) address = address + "," + postalCode;
    if (country.isNotEmpty) address = address + "," + country;

    print("address done");
    print(address);
    setState(() {
      _isLoading = false;
    });
  }

  void logOut(context) async {
    var locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    locationProvider.positionStreamSubscription!.cancel();
    locationProvider.isLocation = false;
    locationProvider.isDenied = false;
    if (UserType.userType == "Mechanic") {
      print("logout");
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection("mechanic_locations")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .delete();
      setState(() {
        _isLoading = false;
      });
    } else if (UserType.userType == "Customer") {
      var userId = FirebaseAuth.instance.currentUser!.uid;
      try {
        setState(() {
          _isLoading = true;
        });
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
              .delete();
        }
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print(e);
      }
    }

    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Details'),
        actions: [
          PopupMenuButton(
              onSelected: (item) => logOut(context),
              itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 0,
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Log Out"),
                        ],
                      ),
                    )
                  ]),
        ],
      ),
      body: address.isEmpty || _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : Container(
              padding:
                  EdgeInsets.only(top: 18, right: 18, left: 18, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).accentColor),
                        child: Text(
                          UserType.name,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16),
                        )),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(left: 10),
                    child: Text(
                      'Current Address',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).accentColor,
                          fontFamily: 'Montserrat'),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    width: double.infinity,
                    child: Text(address),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Color.fromRGBO(0, 0, 0, 0.09),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(left: 10),
                    child: Text(
                      'Email Address',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).accentColor,
                          fontFamily: 'Montserrat'),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    width: double.infinity,
                    child: Text(UserType.email),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Color.fromRGBO(0, 0, 0, 0.09),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(left: 10),
                    child: Text(
                      'Mobile',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).accentColor,
                          fontFamily: 'Montserrat'),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    width: double.infinity,
                    child: Text(UserType.phone),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Color.fromRGBO(0, 0, 0, 0.09),
                    ),
                  ),
                ],
              ),
            ),

      /*Center(
        child: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            UserType.userType = "";

            locationProvider.positionStreamSubscription!.cancel();
            locationProvider.isDenied = false;
            locationProvider.isLocation = false;

            FirebaseAuth.instance.signOut();
          },
        ),
      ),*/
    );
  }
}
