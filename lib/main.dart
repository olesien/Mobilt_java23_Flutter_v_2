import 'dart:developer';

import 'package:auth/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'firebase_options.dart';

class Auth {
  // FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final loggedIn = false;
  Future<bool> isLogged() async {
    try {
      //final FirebaseUser user = await _firebaseAuth.currentUser();
     // return user != null;
      return loggedIn;
    } catch (e) {
      return false;
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Instance of your authentication class
  final Auth _auth = Auth();
  bool loggedIn = false; // Nullable bool to check login status

  //Used to check login
  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check login status when app starts
  }

  // Method to check the login status from Firebase
  void _checkLoginStatus() async {
    bool isLoggedIn = await _auth.isLogged();
    setState(() {
      loggedIn = isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AuthGuard(child: Home()), // becomes the route named '/'
      routes: <String, WidgetBuilder> {
        '/login': (BuildContext context) => Login(),
        '/register': (BuildContext context) => Login(),
        '/gallery': (BuildContext context) => Login(),
      },
    );
  }
}

// Protected Page Wrapper
class AuthGuard extends StatefulWidget {
  final Widget child;

  AuthGuard({required this.child});

  @override
  _AuthGuardState createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  final Auth _auth = Auth();
  bool? loggedIn;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    bool isLoggedIn = await _auth.isLogged();
    setState(() {
      loggedIn = isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    //Loading
    if (loggedIn == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!loggedIn!) {
      // Redirect to login if not logged in
      Future.microtask(() => Navigator.of(context).pushReplacementNamed('/login'));
      return Container();  // Return empty container while navigating
    }

    // If logged in, show child (protected page)
    return widget.child;
  }
}
