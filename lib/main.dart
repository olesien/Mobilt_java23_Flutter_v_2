import 'dart:developer';

import 'package:auth/gallery.dart';
import 'package:auth/home.dart';
import 'package:auth/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  User? firebaseUser;
  bool loggedIn = false; // Nullable bool to check login status

  //Used to check login
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
      setState(() {
        firebaseUser = user;
        if (user == null) {
          loggedIn = false;
          log('User is currently signed out!');
        } else {
          log('User is signed in!');
          loggedIn = true;
        }
      });

    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      title: 'Flutter Auth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AuthGuard(loggedIn: loggedIn, child: Home(), url: "/login"), // becomes the route named '/'
      routes: <String, WidgetBuilder> {
        '/login': (BuildContext context) => AuthGuard(loggedIn: !loggedIn, child: Login(), url: "/"),
        '/register': (BuildContext context) => AuthGuard(loggedIn: !loggedIn, child: Register(), url: "/"),
        '/gallery': (BuildContext context) => AuthGuard(loggedIn: loggedIn, child: Gallery(), url: "/login"),
      },
      onUnknownRoute: null, //We don't care

    );
  }
}

// Protected Page Wrapper
class AuthGuard extends StatefulWidget {
  final Widget child;
  final bool loggedIn;
  final String url;
  const AuthGuard({super.key, required this.child, required this.loggedIn, required this.url}); //key:key is used

  @override
  _AuthGuardState createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  @override
  Widget build(BuildContext context) {
    //Loading
    if (!widget.loggedIn && context.mounted) {
      // Redirect to login if not logged in
      Future.microtask(() => Navigator.of(context).pushReplacementNamed(widget.url));
      return Container();  // Return empty container while navigating
    }

    // If logged in, show child (protected page)
    return widget.child;
  }
}
