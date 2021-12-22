import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_type.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _userEmail = "";
  String _userPassword = "";
  String _userName = "";
  String _userPhone = "";
  String _userType = "";
  bool _isLoading = false;
  final _auth = FirebaseAuth.instance;

  void _selecteduserType(BuildContext context, type) {
    if (type == 0) {
      _userType = "Customer";
    } else {
      _userType = "Mechanic";
    }
  }

  void _trySubmit(ctx) {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_userType.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(
          'Please choose the option customer or mechanic',
        ),
        backgroundColor: Theme.of(ctx).primaryColor,
      ));
      return;
    }

    if (isValid && !_userType.isEmpty) {
      _formKey.currentState!.save();
      _formKey.currentState!.save();
      _submitAuthForm(_userEmail.trim(), _userPassword.trim(), _userName.trim(),
          _userPhone.trim(), _userType, ctx);
    }
  }

  void _submitAuthForm(String email, String password, String username,
      String phone, String userType, BuildContext ctx) async {
    UserCredential authResult;
    try {
      setState(() {
        _isLoading = true;
      });
      authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      UserType.userType = userType;
      UserType.name = username;
      UserType.email = email;
      UserType.phone = phone;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(authResult.user!.uid)
          .set({
        'username': username,
        'email': email,
        'phone': phone,
        'userType': userType
      });
      if (userType == 'Mechanic') {
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
      Navigator.pop(context);
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
    print("completed");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Container(
            padding: EdgeInsets.only(top: 20),
            height: (MediaQuery.of(context).size.height - kToolbarHeight),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  AutoSizeText(
                    'Please enter your details',
                    style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    minFontSize: 10,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height -
                        kToolbarHeight -
                        120,
                    padding: EdgeInsets.only(left: 40, right: 40),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                labelText: "Name",
                                labelStyle: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Theme.of(context).primaryColorLight),
                              ),
                              validator: (value) {
                                if (value!.isEmpty)
                                  return 'Please enter a valid name';
                                else
                                  return null;
                              },
                              onSaved: (value) {
                                _userName = value.toString();
                              },
                            ),
                          ),
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
                              keyboardType: TextInputType.emailAddress,
                              cursorColor: Theme.of(context).accentColor,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: "Phone",
                                labelStyle: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Theme.of(context).primaryColorLight),
                              ),
                              validator: (value) {
                                if (value!.isEmpty)
                                  return 'Please enter a valid phone number';
                                else
                                  return null;
                              },
                              onSaved: (value) {
                                _userPhone = value.toString();
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
                              keyboardType: TextInputType.emailAddress,
                              cursorColor: Theme.of(context).accentColor,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: "Choose Password",
                                labelStyle: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Theme.of(context).primaryColorLight),
                              ),
                              validator: (value) {
                                if (value!.isEmpty || value.length < 7)
                                  return 'Password must be at least 7 characters long';
                                else {
                                  _userPassword = value.toString();
                                  return null;
                                }
                              },
                              onSaved: (value) {
                                _userPassword = value.toString();
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
                              keyboardType: TextInputType.emailAddress,
                              cursorColor: Theme.of(context).accentColor,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: "Confirm Password",
                                labelStyle: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Theme.of(context).primaryColorLight),
                              ),
                              validator: (value) {
                                if (value!.isEmpty ||
                                    value.toString() != _userPassword)
                                  return 'Password mismatch';
                                else {
                                  return null;
                                }
                              },
                              onSaved: (value) {
                                _userPassword = value.toString();
                              },
                            ),
                          ),
                          Container(
                            height: 55,
                            padding: EdgeInsets.only(left: 35, right: 35),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                color: Theme.of(context).accentColor),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Are you a...?',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold),
                                ),
                                PopupMenuButton(
                                    onSelected: (i) =>
                                        _selecteduserType(context, i),
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Colors.white,
                                    ),
                                    itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 0,
                                            child: Text('Customer'),
                                          ),
                                          PopupMenuItem(
                                              value: 1,
                                              child: Text('Mechanic')),
                                        ]),
                              ],
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
                                    'Register',
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                        ]),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        "Already havn an account?",
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            color: Theme.of(context).accentColor),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(primary: Colors.grey),
                        child: Text(
                          'Sign in',
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
