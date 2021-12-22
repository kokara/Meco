import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/user_type.dart';
import './register_screen.dart';
import './forgot_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _userEmail = "";
  String _userPassword = "";
  bool _isLoading = false;
  final _auth = FirebaseAuth.instance;
  void _trySubmit(BuildContext ctx) {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      _submitAuthForm(_userEmail.trim(), _userPassword.trim(), ctx);
    }
  }

  void _submitAuthForm(String email, String password, BuildContext ctx) async {
    UserCredential authResult;
    try {
      setState(() {
        _isLoading = true;
      });
      authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      FirebaseFirestore.instance
          .collection("users")
          .doc(authResult.user!.uid)
          .get()
          .then((value) {
        if (value.exists) {
          {
            UserType.userType = value["userType"];
            UserType.name = value["username"];
            UserType.phone = value["phone"];
            UserType.email = value["email"];
          }
          print(UserType.userType);
        }
      });
      if (UserType.userType == "Mechanic") {
        await FirebaseFirestore.instance
            .collection("mechanic_locations")
            .doc(authResult.user!.uid)
            .set({
          'location': GeoPoint(0.0, 0.0),
          'username': UserType.name,
          'phone': UserType.phone,
          'email': UserType.email,
        });
      }
    } on PlatformException catch (err) {
      var message = 'An error occurred, please check your credentials';
      if (err.message != null) {
        message = err.message.toString();
      } else {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).accentColor,
        ));
        setState(() {
          _isLoading = false;
        });
      }
    } catch (err) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(err.toString()),
        backgroundColor: Theme.of(ctx).accentColor,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Container(
          height: (MediaQuery.of(context).size.height -
              kToolbarHeight -
              MediaQuery.of(context).padding.bottom),
          alignment: Alignment.center,
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(child: Container()),
                    SvgPicture.asset(
                      "assets/mechanic.svg",
                      fit: BoxFit.scaleDown,
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      'meco',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Sign in to Continue',
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat'),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: EdgeInsets.only(left: 40, right: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 35),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: Color.fromRGBO(0, 0, 0, 0.09)),
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            cursorColor: Theme.of(context).accentColor,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: "Email",
                              labelStyle: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Theme.of(context).primaryColorLight),
                            ),
                            validator: (value) {
                              if (value!.isEmpty || !value.contains('@'))
                                return 'Please enter a valid email address ';
                              else
                                return null;
                            },
                            onSaved: (value) {
                              _userEmail = value.toString();
                            },
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 35),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: Color.fromRGBO(0, 0, 0, 0.09)),
                          child: TextFormField(
                            obscureText: true,
                            cursorColor: Theme.of(context).accentColor,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: "Password",
                              labelStyle: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Theme.of(context).primaryColorLight),
                            ),
                            validator: (value) {
                              if (value!.isEmpty || value.length < 7)
                                return 'Password must be at least 7 characters long ';
                              else
                                return null;
                            },
                            onSaved: (value) {
                              _userPassword = value.toString();
                            },
                          ),
                        ),
                        if (_isLoading)
                          CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          )
                        else
                          Container(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                                onPressed: () {
                                  _trySubmit(context);
                                },
                                style: ElevatedButton.styleFrom(
                                    primary: Theme.of(context).primaryColor,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(18)))),
                                child: Text(
                                  'Sign in',
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )),
                          )
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotScreen()));
                        },
                        style: TextButton.styleFrom(primary: Colors.grey),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              fontFamily: 'Montserrat'),
                        ),
                      ),
                      Expanded(child: Container()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't havn an account?",
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                                color: Theme.of(context).accentColor),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          RegisterScreen()));
                            },
                            style: TextButton.styleFrom(primary: Colors.grey),
                            child: Text(
                              'Register',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat'),
                            ),
                          ),
                        ],
                      )
                    ],
                  ))
            ],
          ),
        ),
      ),
    ));
  }
}
