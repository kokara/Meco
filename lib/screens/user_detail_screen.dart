import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_type.dart';
import 'package:provider/provider.dart';
import '../models/location_provider.dart';

class UserDetailScreen extends StatefulWidget {
  String dist;
  String name;
  String phone;
  String email;
  double latitude;
  double longitude;
  String id;
  bool isSentRequest;
  UserDetailScreen(
      {required this.dist,
      required this.name,
      required this.phone,
      required this.email,
      required this.latitude,
      required this.longitude,
      required this.id,
      required this.isSentRequest});

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  @override
  bool _isLoading = true;
  bool _isRequested = true;
  String address = "";
  void initState() {
    super.initState();
    findAddress();
  }

  Future<bool> showRequestDialog(context) async {
    bool res = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('If you request ' +
                widget.name +
                ", your location will be visible to " +
                widget.name),
            content:
                Text('Are you sure you want to request ' + widget.name + " ?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                style: TextButton.styleFrom(primary: Colors.grey),
                child: Text(
                  'Yes',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                style: TextButton.styleFrom(primary: Colors.grey),
                child: Text(
                  'No',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          );
        });
    return res;
  }

  Future<bool> showCancelRequestDialog(context) async {
    bool res = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('If you cancel request, ' +
                "your location won't be visible to " +
                widget.name),
            content: Text('Are you sure you want to cancel request ?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                style: TextButton.styleFrom(primary: Colors.grey),
                child: Text(
                  'Yes',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                style: TextButton.styleFrom(primary: Colors.grey),
                child: Text(
                  'No',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              )
            ],
          );
        });
    return res;
  }

  void findAddress() async {
    if (UserType.userType == "Customer" && widget.isSentRequest == false) {
      try {
        var doc = await FirebaseFirestore.instance
            .collection("customers")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("mechanics")
            .doc(widget.id)
            .get();
        _isRequested = doc.exists;
      } catch (e) {
        print(e);
      }
    }

    if (widget.dist != '-1') {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(widget.latitude, widget.longitude);
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
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var locationProvider = context.read<LocationProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(UserType.userType == 'Customer'
            ? 'Mechanic Details'
            : 'Customer Details'),
      ),
      body: _isLoading
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
                          widget.name,
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
                    child: Text(widget.email),
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
                    child: Text(widget.phone),
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
                      'Distance',
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
                    child: Text(
                        widget.dist == '-1' ? "unknown" : (widget.dist + "km")),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Color.fromRGBO(0, 0, 0, 0.09),
                    ),
                  ),
                  Expanded(child: Container()),
                  if (UserType.userType == 'Customer')
                    Container(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                          onPressed: () async {
                            if (!_isRequested) {
                              bool res = await showRequestDialog(context);
                              if (res) {
                                setState(() {
                                  _isRequested = !_isRequested;
                                });
                                await FirebaseFirestore.instance
                                    .collection('customer_locations')
                                    .doc(widget.id)
                                    .collection('customer_location')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .set({
                                  'location': GeoPoint(
                                      locationProvider.latitude,
                                      locationProvider.longitude),
                                  'username': widget.name,
                                  'email': widget.email,
                                  'phone': widget.phone
                                });
                                await FirebaseFirestore.instance
                                    .collection('mechanics')
                                    .doc(widget.id)
                                    .collection('customers')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .set({
                                  'location': GeoPoint(
                                      locationProvider.latitude,
                                      locationProvider.longitude),
                                  'username': UserType.name,
                                  'email': UserType.email,
                                  'phone': UserType.phone
                                });
                                await FirebaseFirestore.instance
                                    .collection('customers')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('mechanics')
                                    .doc(widget.id)
                                    .set({
                                  'location': GeoPoint(
                                      widget.latitude, widget.longitude),
                                  'username': widget.name,
                                  'email': widget.email,
                                  'phone': widget.phone
                                });
                              }
                            } else {
                              bool res = await showCancelRequestDialog(context);
                              if (res) {
                                setState(() {
                                  _isRequested = !_isRequested;
                                });
                                await FirebaseFirestore.instance
                                    .collection('customer_locations')
                                    .doc(widget.id)
                                    .collection('customer_location')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .delete();
                                await FirebaseFirestore.instance
                                    .collection('mechanics')
                                    .doc(widget.id)
                                    .collection('customers')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .delete();
                                await FirebaseFirestore.instance
                                    .collection('customers')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('mechanics')
                                    .doc(widget.id)
                                    .delete();
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              primary: Theme.of(context).primaryColor,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(18)))),
                          child: Text(
                            _isRequested ? 'Cancel Request' : 'Send Request',
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          )),
                    )
                ],
              ),
            ),
    );
  }
}
