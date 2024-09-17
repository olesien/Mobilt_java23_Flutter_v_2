import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
class Register extends StatefulWidget {
  @override
  _RegisterPage createState() => _RegisterPage();
}

class _RegisterPage extends State<Register> {
  String email = "";
  String password = "";

  register() async {
    log(email);
    log(password);
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

    } on FirebaseAuthException catch (e) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Register Page "),
      ),
      body: Padding(padding: const EdgeInsets.all(16.0), child: Column(

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
          Padding(padding: const EdgeInsets.all(20), child: FilledButton( onPressed: register, child: Text("Register" ) )),
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
    );
  }
}