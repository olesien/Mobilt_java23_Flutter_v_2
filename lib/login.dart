import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
class Login extends StatefulWidget {
  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<Login> {
  bool isLoading = false;
  String email = "";
  String password = "";

  login() async {
    setState(() {
      isLoading = true;
    });
    log(email);
    log(password);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      Fluttertoast.showToast(
          msg: "Login successful!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
      );
      setState(() {
        isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      if (e.code == 'user-not-found') {
        log('No user found for that email.');
        Fluttertoast.showToast(
            msg: "No user found for that email.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      } else if (e.code == 'wrong-password') {
        log('Wrong password provided for that user.');
        Fluttertoast.showToast(
            msg: "Wrong password provided for that user.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      } else {
        Fluttertoast.showToast(
            msg: e.message ?? "Something went wrong",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Page "),
      ),
      body: Padding(padding: const EdgeInsets.all(16.0), child: Center(child: FractionallySizedBox(widthFactor: screenWidth < 750 ? 1.0 : 750 / screenWidth, child: Column(

        children: <Widget>[
          const Text(
            'Login Information',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20.0),
          TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: "Email Address"),
              onChanged: (text) {email = text.toString();}),


          TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: "Password"),
              onChanged: (text) {password = text.toString();}),
          Padding(padding: const EdgeInsets.all(20), child: FilledButton( onPressed: isLoading ? null : login, child: Text(isLoading ? "LOGGING IN..." : "LOGIN" ) )),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, "/register");
            },
            child: const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text("Don't have an account? Register here", style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
          ),
          )
        ],
      )),
    )));
  }
}