
import 'dart:developer';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double uploadProgress = -1;
  String? imageURL;
  String? imageUrlRef;
  bool isLoading = false;
  String caption = "";
  void _onImagePressed() async {
    setState(() {
      isLoading = true;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true, type: FileType.custom, allowedExtensions: ['svg', 'png', 'gif', 'jpg', 'jpeg', 'tiff', 'webp']);

    if (result != null) {
      Uint8List? fileBytes = result.files.first.bytes;
      String fileName = result.files.first.name;

      if (fileBytes != null) {
        log("File bytes EXIST");
        // Upload file
        setState(() {
          uploadProgress = 0.0;
        });
        FirebaseStorage.instance.ref('uploads/$fileName').putData(fileBytes).snapshotEvents.listen((taskSnapshot) async {
          switch (taskSnapshot.state) {
            case TaskState.running:
            // ...
              final progress =
                  (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
              log((100.0 *progress).toString());
              setState(() {
                uploadProgress = progress;
              });
              break;
            case TaskState.paused:
            // ...
              break;
            case TaskState.success:
              setState(() {
                uploadProgress = -1.0;
              });
              var path = await taskSnapshot.ref.getDownloadURL();
              var refPath = await taskSnapshot.ref.name;
              setState(() {
                imageUrlRef = refPath;
                imageURL = path;
                isLoading = false;
              });
              break;
            case TaskState.canceled:
            // ...
              setState(() {
                uploadProgress = -1.0;
              });
              Fluttertoast.showToast(
                  msg: "Upload has been cancelled",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0
              );
              break;
            case TaskState.error:
            // ...
              setState(() {
                uploadProgress = -1.0;
              });
              Fluttertoast.showToast(
                  msg: "Something went wrong",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0
              );
              break;
          }
        });

      } else {
        log("NULL");
      }
    } else {
      // User canceled the picker
      log("Cancel");
    }

  }

  _saveImage() {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var img = {
        "userId": user.uid,
        "imgUrlRef": imageUrlRef,
        "imgUrl": imageURL,
        "caption": caption
      };
      var db = FirebaseFirestore.instance;
      db.collection("gallery").add(img).then((DocumentReference doc) {
        log('DocumentSnapshot added with ID: ${doc.id}');
        Fluttertoast.showToast(
            msg: "Successfully saved to gallery",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
        setState(() {
          imageURL = null;
          caption = "";
          imageUrlRef = null;
        });
      });
    }

  }
  _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  _onItemTapped(int i) {
switch (i) {
  case 1: {
    Navigator.pushNamed(context, "/gallery");
  }
  case 2: {
    _logout();
  }
}
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("Home "),
        //actions: <Widget>[LogoutButton()],
      ),
      body: Center(
        child: Padding(padding: const EdgeInsets.all(16.0), child: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            const Text(
              'Home Page',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20.0),
            TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: "Caption"),
                onChanged: (text) {caption = text.toString();}),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: ElevatedButton(
                onPressed: _onImagePressed,
                child: const Text("Upload image"),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imageURL != null
              // Image URL is defined
                  ? [
                const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Column(children: [
                      Text(
                        "Here's your uploaded image!",
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      Text("It's living on the web."),
                    ])),
                CachedNetworkImage(
                  imageUrl: imageURL!,
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
                FilledButton(onPressed: _saveImage, child: Text("Save To Gallery"))
              ]
                  :
              // No image URL is defined
              uploadProgress >= 0.0 && uploadProgress < 100.0 ? [LinearProgressIndicator(
                value: uploadProgress,
                semanticsLabel: 'Image Upload Progress',
              )] : [const Text("No image has been uploaded.")],
            )
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
        currentIndex: 0,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}