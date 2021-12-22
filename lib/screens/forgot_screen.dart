import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotScreen extends StatefulWidget {
  @override
  _ForgotScreenState createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  String _userEmail = "";

  final _formKey = GlobalKey<FormState>();

  void _trySubmit(context) {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      _showMyDialog();
    }
  }

  Future<void> _sendEmail() async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: _userEmail);
  }

  Future<void> _showMyDialog() async {
    await _sendEmail();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(
              'A password email has been sent to $_userEmail',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(primary: Colors.grey),
                child: Text(
                  'Ok',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Container(
          height: (MediaQuery.of(context).size.height - kToolbarHeight),
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 40, right: 40, top: 50),
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Column(children: [
                  SvgPicture.asset("assets/mechanic.svg"),
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
                ]),
              ),
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Container(
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
                    ),
                    SizedBox(
                      height: 40,
                    ),
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(18)))),
                          child: Text(
                            'Submit',
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          )),
                    ),
                    Expanded(child: Container()),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(primary: Colors.grey),
                      child: Text(
                        'Return to Sign in Page',
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
