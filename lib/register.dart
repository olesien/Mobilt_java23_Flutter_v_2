import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
class Register extends StatefulWidget {
  @override
  _RegisterPage createState() => _RegisterPage();
}

class _RegisterPage extends State<Register> {
  bool isLoading = false;
  String email = "";
  String password = "";

  register() async {
    setState(() {
      isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      Fluttertoast.showToast(
          msg: "Register successful!",
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Register Page "),
      ),
      body: Padding(padding: const EdgeInsets.all(16.0), child: Center(child: FractionallySizedBox(widthFactor: screenWidth < 750 ? 1.0 : 750 / screenWidth, child: Column(

        children: <Widget>[
          const Text(
            'Register Information',
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
          Padding(padding: const EdgeInsets.all(20), child: FilledButton( onPressed: isLoading ? null : register, child: Text(isLoading ? "Registering..." : "Register" ) )),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, "/login");
            },
            child: const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text("Already have an account? Login here", style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
          )
        ],
      )),
    )));
  }
}