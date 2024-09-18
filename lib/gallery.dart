import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Gallery extends StatefulWidget {
  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  double uploadProgress = -1;
  String? imageURL;
  bool isLoading = false;
  String caption = "";

  _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  _onItemTapped(int i) {
    switch (i) {
      case 0: {
        Navigator.pushNamed(context, "/");
      }
      case 2: {
        _logout();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;
    //Get the firebase data
    if (user == null) {
      return const Scaffold(); //Empty
    }
      Query query = FirebaseFirestore.instance.collection("gallery").where('userId', isEqualTo: user.uid);

    return  Scaffold(
      appBar: AppBar(
        title: Text("Gallery"),
        //actions: <Widget>[LogoutButton()],
      ),
      body: Center(
        child: Padding(padding: const EdgeInsets.all(16.0), child: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            const Text(
              'Gallery Page',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20.0),
            StreamBuilder(stream: query.snapshots(), builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              //Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // List of documents...
              final List<DocumentSnapshot> documents = snapshot.data!.docs;

              return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                var data = documents[index].data() as Map<String, dynamic>;
                log(data['imgUrl']);
                return ListTile(
                  leading: Image.network(data['imgUrl']),
                  title: Text(data['caption'] ?? 'No Caption'),
                );
              }
              );

            })
          ],
        )),

      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.browse_gallery),
            label: 'Gallery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}