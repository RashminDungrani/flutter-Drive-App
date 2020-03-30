import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:open_file/open_file.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';

// import 'package:firebase_auth/firebase_auth.dart';

class CrudMedthods {
  // bool isLoggedIn() {
  //   if (FirebaseAuth.instance.currentUser() != null) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }

//   Future<void> downloadFile(StorageReference ref) async {
//     // final String url = await ref.getDownloadURL();
//     // final http.Response downloadData = await http.get(url);
//     final String fileName = await ref.getName();
//     // final String path = await ref.getPath();
//     // final Directory systemTempDir = Directory.systemTemp;
//     var documentDirectory = await getExternalStorageDirectory();
//     print("Directory :: " + documentDirectory.toString());
//     File createNewFile = new File(join(documentDirectory.path, fileName));
//     // print("😡  " + createNewFile.toString());
//     String locationOfNewFile =
//         createNewFile.toString().replaceAll("File: '", "").replaceAll("'", "");

//     // createNewFile.existsSync()
//     if (await File(locationOfNewFile).exists()) {
//       print("From Already Exist File");
//       await OpenFile.open(locationOfNewFile);
//     } else {
//       print("From Create new File");
//       await createNewFile.create().then((_) async {
//         await ref.writeToFile(createNewFile).future.then((_) async {
//           await OpenFile.open(locationOfNewFile);
//         });

//         // if (await File(locationOfNewFile).exists()) {
//         // } else {
//         //   print("Not Downloaded Yet");
//         // }
//       });

//       //  OpenFile.open(locationOfNewFile);

//       // await launch(createNewFile.toString(),
//       //     forceSafariVC: false, forceWebView: false);

//     }
//     //
//     // final String byteCount = (await task.future).totalByteCount.toString();
//     // var bodyBytes = downloadData.bodyBytes;
//     // print(
//     //   'Success!\nDownloaded $fileName \nUrl: $url'
//     //   '\npath: $path \nBytes Count :: $byteCount',
//     // );
//     // /data/user/0/com.example.drive/app_flutter/Resume.pdf

// // file.writeAsBytesSync(response.bodyBytes);
//   }

  Future<void> addFolder(
      String currentLocation, String createDirName, bool isFile) async {
    if (isFile) {
      Firestore.instance
          .collection(currentLocation)
          .document(createDirName)
          .setData({"created_timestamp": Timestamp.now()});
    } else {
      Firestore.instance
          .collection(currentLocation)
          .document(createDirName)
          .setData({});
    }
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

  bool isDownloaded(String refName) {
    // String fileName = await refName.getName();
    var documentDirectory = getExternalStorageDirectory();
    File filePath = new File(join(documentDirectory.path, fileName));
    String finalFilePath =
        filePath.toString().replaceAll("File: '", "").replaceAll("'", "");
    if (await File(finalFilePath).exists()) {
      return true;
    } else
      return false;
  }

  getDownloadedFileNames() async {}
}
