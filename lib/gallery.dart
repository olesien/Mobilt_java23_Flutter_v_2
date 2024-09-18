import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
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

  _deleteImage(Map<String, dynamic> data, String documentId) async {
    log(documentId);
    try {
      //Delete firestore link
      await FirebaseFirestore.instance.collection("gallery").doc(documentId).delete();
      //Delete from storage bucket
      var storageRef = FirebaseStorage.instance;
      final imgRef = storageRef.ref().child("uploads/${data["imgUrlRef"]}");
      await imgRef.delete();


      Fluttertoast.showToast(
        msg: "Successfully deleted image",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (err) {
      Fluttertoast.showToast(
        msg: err.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

  }

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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Gallery Page',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20.0),
              Expanded(
                child: StreamBuilder(
                  stream: query.snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final List<DocumentSnapshot> documents = snapshot.data!.docs;

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 items per row
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8, // Adjust the aspect ratio to control image height
                      ),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        var data = documents[index].data() as Map<String, dynamic>;
                        String imageUrl = data['imgUrl'];
                        String caption = data['caption'] ?? 'No Caption';

                        return Stack(
                          children: [
                            // Display the image in the grid
                            Positioned.fill(
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) {
                                  log(error.toString());
                                  return const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  );
                                },
                              ),
                            ),

                            // Overlay: Title and delete button at the bottom
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.black54,
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distributes space between Text and Icon
                                  children: [
                                    Expanded(
                                      child: Text(
                                        caption,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis, // Handle long captions
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        _deleteImage(data, documents[index].id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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