import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    Timer.run(() { // import 'dart:async:
      Navigator.of(context).pushNamed('login');
    });
  }
  _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("Home "),
        //actions: <Widget>[LogoutButton()],
      ),
      body: Center(
        child: Text('Home Page'),

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _logout,
        tooltip: 'Logout',
        child: const Icon(Icons.logout),
      ),
    );
  }
}