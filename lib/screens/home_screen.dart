import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/location_provider.dart';
import './mechanic_screen.dart';
import './map_screen.dart';
import './profile_screen.dart';
import '../models/user_type.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDenied = false;
  bool _islocation = false;
  int _currentIndex = 0;
  List<Widget> screenList = [
    MechanicScreen(),
    MapScreen(),
    ProfileScreen(),
  ];
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    if (UserType.userType.isEmpty) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        if (value.exists) {
          UserType.userType = value["userType"];
          UserType.email = value["email"];
          UserType.name = value["username"];
          UserType.phone = value["phone"];
          print(UserType.userType);
          setState(() {});
        }
      });
    }

    Future.delayed(Duration.zero, () {
      context.read<LocationProvider>().getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    var locationProvider = context.watch<LocationProvider>();
    return Scaffold(
        body: locationProvider.isDenied
            ? Center(
                child: Text(
                'Please turn on your location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ))
            : locationProvider.isLocation == false || UserType.userType.isEmpty
                ? Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : IndexedStack(
                    index: _currentIndex,
                    children: screenList,
                  ),
        bottomNavigationBar:
            locationProvider.isLocation && !locationProvider.isDenied
                ? BottomNavigationBar(
                    currentIndex: _currentIndex,
                    elevation: 0,
                    selectedItemColor: Theme.of(context).primaryColor,
                    unselectedItemColor: Theme.of(context).primaryColorLight,
                    selectedLabelStyle: TextStyle(fontFamily: 'Montserrat'),
                    unselectedLabelStyle: TextStyle(fontFamily: 'Montserrat'),
                    onTap: onTabTapped,
                    items: [
                      BottomNavigationBarItem(
                          icon: Icon(Icons.home_rounded), label: 'Home'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.map_rounded), label: 'Map'),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.person), label: 'Profile'),
                    ],
                  )
                : Container(
                    height: 0,
                  ));
  }
}
