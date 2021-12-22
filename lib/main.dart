import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

import '../screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/home_screen.dart';
import 'package:provider/provider.dart';
import '../models/location_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Firebase.initializeApp();

  // await Firebase.initializeApp();
  runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LocationProvider())],
      child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meco',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(235, 77, 75, 1), //52, 34, 46, 1
        accentColor: Color.fromRGBO(53, 59, 72, 1),

        primaryColorLight: Color.fromRGBO(53, 59, 72, 0.6),

        iconTheme: IconThemeData(
          color: Color.fromRGBO(26, 188, 156, 1),
        ),
        fontFamily: 'OpenSans',

        appBarTheme: AppBarTheme(
          elevation: 0,
          textTheme: TextTheme(
            headline6: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
      ),
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            print("change");
            if (userSnapshot.hasData)
              return HomeScreen();
            else
              return LoginScreen();
          }), // MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

/*class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LatLng latlng = LatLng(19.0760, 72.8777);
  bool _f = false;
  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    print("hello");

    Location location = new Location();
    LocationData _locationData;

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    print("hii");
    print(_locationData.altitude);
    print(_locationData);

    latlng =
        LatLng(_locationData.latitude ?? 0.0, _locationData.longitude ?? 0.0);
    setState(() {
      print("in");
      _f = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: _f
            ? FlutterMap(
                options:
                    new MapOptions(center: latlng, maxZoom: 18, minZoom: 1),
                layers: [
                  new TileLayerOptions(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c']),
                  MarkerLayerOptions(markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: latlng,
                      builder: (ctx) => Container(
                        child: FlutterLogo(),
                      ),
                    ),
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(25.5732, 85.0693),
                      builder: (ctx) => Container(
                        child: FlutterLogo(),
                      ),
                    ),
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(25.5775, 85.0930),
                      builder: (ctx) => Container(
                        child: FlutterLogo(),
                      ),
                    ),
                  ])
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              )

         IconButton(
                onPressed: () async {
                  await getCurrentLocation();
                },
                icon: Icon(Icons.ac_unit_outlined))

        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}*/
