import 'package:flutter/material.dart';
class Login extends StatefulWidget {
  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Page "),
      ),
      body: Column(
        children: <Widget>[

          Text(
            'Login Information',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20.0),
          TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: "Email Address")),

          TextFormField(
              obscureText: true,
              decoration: InputDecoration(labelText: "Password")),
          MaterialButton(child: Text("LOGIN"), onPressed: () {}),
        ],
      ),
    );
  }
}