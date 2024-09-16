import 'dart:async';

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
    );
  }
}