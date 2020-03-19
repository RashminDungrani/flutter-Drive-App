import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

// import 'package:firebase_auth/firebase_auth.dart';

class CrudMedthods {
  // bool isLoggedIn() {
  //   if (FirebaseAuth.instance.currentUser() != null) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

  Future<void> downloadFile(StorageReference ref) async {
    // final String url = await ref.getDownloadURL();
    // final http.Response downloadData = await http.get(url);
    final String fileName = await ref.getName();
    // final String path = await ref.getPath();
    // final Directory systemTempDir = Directory.systemTemp;
    var documentDirectory = await getExternalStorageDirectory();
    print("Directory :: " + documentDirectory.toString());
    File createNewFile = new File(join(documentDirectory.path, fileName));
    // print("😡  " + createNewFile.toString());
    String locationOfNewFile =
        createNewFile.toString().replaceAll("File: '", "").replaceAll("'", "");

    // createNewFile.existsSync()
    if (await File(locationOfNewFile).exists()) {
      print("From Already Exist File");
      await OpenFile.open(locationOfNewFile);
    } else {
      print("From Create new File");
      await createNewFile.create().then((results) async {
        final StorageFileDownloadTask task = ref.writeToFile(createNewFile);
        if (await File(locationOfNewFile).exists()) {
          await OpenFile.open(locationOfNewFile);
        } else {
          print("Not Downloaded Yet");
        }
      });

      //  OpenFile.open(locationOfNewFile);

      // await launch(createNewFile.toString(),
      //     forceSafariVC: false, forceWebView: false);

    }
    //
    // final String byteCount = (await task.future).totalByteCount.toString();
    // var bodyBytes = downloadData.bodyBytes;
    // print(
    //   'Success!\nDownloaded $fileName \nUrl: $url'
    //   '\npath: $path \nBytes Count :: $byteCount',
    // );
    // /data/user/0/com.example.drive/app_flutter/Resume.pdf

// file.writeAsBytesSync(response.bodyBytes);
  }

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
