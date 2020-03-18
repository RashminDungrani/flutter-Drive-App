import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class CrudMedthods {
  // bool isLoggedIn() {
  //   if (FirebaseAuth.instance.currentUser() != null) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  Future<void> addFolder(String currentLocation, String createDirName) async {
    // if (isLoggedIn()) {
    Firestore.instance
        .collection(currentLocation)
        .document(createDirName)
        .setData({});
    // Firestore.instance.collection('Folders').add(carData).catchError((e) {
    //   print(e);
    // });
    // } else {
    // print('You need to be logged in');
    // }
  }

  Future<void> deleteFolder(
      String currentLocation, String deleteDirName) async {
    Firestore.instance
        .collection(currentLocation)
        .document(deleteDirName)
        .delete();
  }

  // getDataOfHomeScreen() async {
  //   return await Firestore.instance.collection("Folders").getDocuments();
  // }

  getData(String currentLocation) async {
    return await Firestore.instance.collection(currentLocation).getDocuments();
  }
}
