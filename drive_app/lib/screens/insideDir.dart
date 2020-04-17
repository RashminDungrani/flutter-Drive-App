//TODO: onLongPress Show Alert Box "Are you Sure" and then delete file or Folder if input is yes (true)
//TODO: Pull Down To refresh

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:drive_app/services/crud.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> getPermissionStatus() async {
  var status = await Permission.storage.status;
  if (status.isGranted) {
    return true;
  } else if (status.isDenied) {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      return true;
    } else {
      return false;
    }
  } else if (status.isUndetermined) {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      return true;
    } else {
      return false;
    }
  } else {
    openAppSettings();
    return false;
  }
}

Future<bool> downloadFile1(StorageReference ref, context) async {
  ProgressDialog pr;
  pr = new ProgressDialog(context);
  pr.style(message: 'Downloading...');

  // final String url = await ref.getDownloadURL();
  // final http.Response downloadData = await http.get(url);
  final String fileName = await ref.getName();
  // final String path = await ref.getPath();
  // final Directory systemTempDir = Directory.systemTemp;
  var documentDirectory = await getExternalStorageDirectory();
  // print("Directory :: " + documentDirectory.toString());
  File createNewFile = new File(join(documentDirectory.path, fileName));
  String locationOfNewFile =
      createNewFile.toString().replaceAll("File: '", "").replaceAll("'", "");

  // createNewFile.existsSync()
  if (await File(locationOfNewFile).exists()) {
    await OpenFile.open(locationOfNewFile);
    return false;
  } else {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // print('connected');
        pr.show();
        await createNewFile.create().then((_) async {
          await ref.writeToFile(createNewFile).future.then((_) async {
            pr.hide();
            await OpenFile.open(locationOfNewFile);
          });
        });
      }
      return false;
    } on SocketException catch (_) {
      // print('not connected');
      return true;
    }
  }
}

class InsideDir extends StatefulWidget {
  final String dirName;
  final String currentLocation;

  @override
  _InsideDirState createState() => _InsideDirState();
  InsideDir({Key key, @required this.dirName, @required this.currentLocation})
      : super(key: key);
}

class _InsideDirState extends State<InsideDir> {
  ProgressDialog pr;
  static TextEditingController _textFieldController = TextEditingController();
  QuerySnapshot dirs;
  // Map<String, int> timeMillis;
  CrudMedthods crudObj = new CrudMedthods();
  Map<String, String> _paths;

  String directory;
  List downloadedFilePaths = new List();
  List<String> downloadedFileNames = [];

  @override
  initState() {
    crudObj.getData(widget.currentLocation).then((results) {
      setState(() {
        dirs = results;
        // print(dirs);
      });
    });

    super.initState();
    _listofFiles();
  }

  void _listofFiles() async {
    directory = (await getExternalStorageDirectory()).path;
    setState(() {
      downloadedFilePaths = Directory("$directory/").listSync();
    });

    for (var filePath in downloadedFilePaths) {
      String fileName = filePath.toString();
      fileName = fileName?.split("/")?.last.toString().replaceAll("'", "");
      downloadedFileNames.add(fileName);
    }
    // String formatBytes(int bytes) {
    //   var units = ['B', 'KB', 'MB', 'GB', 'TB'];

    //   int bytes = [bytes, 0];
    //   var pow = ((bytes ? bytes : 0) / 1024).floor();
    //   pow = [pow, units.length - 1].reduce(max);

    //   // Uncomment one of the following alternatives
    //   // $bytes /= pow(1024, $pow);
    //   // $bytes /= (1 << (10 * $pow));

    //   return (bytes).round().toString() + ' ' + units[pow];
    // }

    // print(downloadedFileNames);

    // print(downloadedFileSizes[0]);
  }

  Widget build(BuildContext context) {
    pr = new ProgressDialog(context);
    pr.style(message: 'Uploading...');
    final GlobalKey<ScaffoldState> _scaffoldKey =
        new GlobalKey<ScaffoldState>();

    void showInSnackBar(String value) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1500),
          content: Container(
            height: 12,
            child: Center(
              child: Text(
                value,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      );
    }

    _onAdd() {
      crudObj
          .addFolder(
              widget.currentLocation, _textFieldController.text, "0", false)
          .then((results) {
        initState();
      });
    }

    displayDialog(BuildContext context) async {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Create New Folder'),
              content: TextField(
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
                controller: _textFieldController,
                decoration: InputDecoration(hintText: "Add New Folder"),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _textFieldController.clear();
                  },
                ),
                new FlatButton(
                  child: new Text('Add'),
                  onPressed: () {
                    if (_textFieldController.text != "" &&
                        _textFieldController != null) {
                      _onAdd();
                      Navigator.of(context).pop();
                      _textFieldController.clear();
                    }
                  },
                ),
              ],
            );
          });
    }

    String getConvertedTime(Timestamp timestamp) {
      var now = DateTime.now();
      var today = DateTime(now.year, now.month, now.day);
      var yesterday = DateTime(now.year, now.month, now.day - 1);
      var format = DateFormat.yMMMMd('en_US');
      var date =
          DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
      var diff = now.difference(date);
      var time = '';

      final aDate = DateTime(date.year, date.month, date.day);

      if (diff.inSeconds <= 0 ||
          diff.inSeconds > 0 && diff.inMinutes == 0 ||
          diff.inMinutes > 0 && diff.inHours == 0 ||
          diff.inHours > 0 && diff.inDays == 0) {
        if (aDate == today) {
          time = "today " + DateFormat('HH:mm').format(date);
        } else if (aDate == yesterday) {
          time = "yesterday " + DateFormat('HH:mm').format(date);
        }
        // time = DateFormat('HH:mm a').format(date);

      } else if (diff.inDays > 0 && diff.inDays < 7) {
        if (diff.inDays == 1) {
          time = diff.inDays.toString() + ' day ago';
        } else {
          time = diff.inDays.toString() + ' days ago';
        }
      } else {
        if (diff.inDays == 7) {
          time = (diff.inDays / 7).floor().toString() + ' week ago';
        } else {
          time = format.format(date);
        }
      }
      return time;
    }

    Widget bodyBuilder(BuildContext context) {
      bool isFile(String nameOfFile) {
        if (nameOfFile.startsWith("XzX@"))
          return true;
        else
          return false;
      }

      List<String> widgetOfFile(fileName) {
        List<String> fileWidget = [];
        if (fileName.startsWith("XzX@PDF_")) {
          String renamedFileName = fileName.replaceAll("XzX@PDF_", "");
          fileWidget.add(renamedFileName + ".pdf");
          fileWidget.add("0xe415"); // picture_as_pdf
          fileWidget.add("0xffff0000"); // red color

          return fileWidget;
        } else if (fileName.startsWith("XzX@xls_")) {
          String renamedFileName = fileName.replaceAll("XzX@xls_", "");
          fileWidget.add(renamedFileName + ".xls");
          fileWidget.add("0xe873");
          fileWidget.add("0xff4caf50");

          return fileWidget;
        } else if (fileName.startsWith("XzX@xlsx_")) {
          String renamedFileName = fileName.replaceAll("XzX@xlsx_", "");
          fileWidget.add(renamedFileName + ".xlsx");
          fileWidget.add("0xe873");
          fileWidget.add("0xff4caf50");

          return fileWidget;
        } else {
          String renamedFileName = fileName.replaceAll("XzX@z_", "");
          String fileExtension =
              renamedFileName.substring(0, renamedFileName.lastIndexOf('^^'));
          renamedFileName =
              renamedFileName.substring(renamedFileName.indexOf('^^') + 2);
          fileWidget.add(renamedFileName + "." + fileExtension);
          fileWidget.add("0xe24d"); //insert_drive_file
          fileWidget.add("0xff607d8b");

          return fileWidget;
        }
      }

      int getDownloadedColor(fileName) {
        if (downloadedFileNames.contains(fileName)) {
          return 0xff858487;
        } else
          return 0xfff0f3f4;
      }

      if (dirs != null) {
        if (dirs.documents.length != 0) {
          return Container(
            padding: EdgeInsets.all(5),
            child: ListView(
              children: List.generate(
                dirs.documents.length,
                (index) {
                  String currentDocumentId = dirs.documents[index].documentID;
                  if (isFile(currentDocumentId)) {
                    List<String> fileWidgets = widgetOfFile(currentDocumentId);
                    String fileName = fileWidgets[0].toString();
                    fileName = fileWidgets[0];
                    int iconOfFile = int.parse(fileWidgets[1]);
                    int iconColor = int.parse(fileWidgets[2]);
                    String firebaseDatabaseLocation =
                        widget.currentLocation.replaceAll("/collection", "");
                    StorageReference storageReference = FirebaseStorage.instance
                        .ref()
                        .child(firebaseDatabaseLocation + "/" + fileName);
                    Timestamp updatedTimeMillis =
                        dirs.documents[index].data["created_timestamp"];
                    var resultOfFileCreatedTime =
                        getConvertedTime(updatedTimeMillis);

                    int downloadIconColor = getDownloadedColor(fileName);
                    return Container(
                      // padding: EdgeInsets.all(7),
                      child: InkWell(
                        // * File View
                        child: Slidable(
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: 0.25,
                            child: Container(
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                color: Color(0xfff0f3f4),
                                child: ListTile(
                                    // Icon(
                                    //     IconData(iconOfFile, fontFamily: 'MaterialIcons'),
                                    //     size: 30.0,
                                    //     color: Color(iconColor),
                                    //   ),
                                    leading: CircleAvatar(
                                      backgroundColor: Color(iconColor),
                                      child: Icon(IconData(iconOfFile,
                                          fontFamily: 'MaterialIcons')),
                                      foregroundColor: Colors.white,
                                    ),
                                    title: Text(
                                      fileName,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 17),
                                    ),
                                    subtitle: Text(dirs.documents[index]
                                            .data["file_size"] +
                                        "  " +
                                        resultOfFileCreatedTime.toString()),
                                    trailing: Icon(
                                      Icons.offline_pin,
                                      color: Color(downloadIconColor),
                                    )),
                              ),
                            ),
                            secondaryActions: <Widget>[
                              IconSlideAction(
                                  caption: 'Delete',
                                  color: Colors.red,
                                  icon: Icons.delete,
                                  // Delete from External Storage and remove item from fileNames
                                  onTap: () async {
                                    showInSnackBar("$fileName is Deleted");
                                    storageReference.delete();
                                    print("Deleting");
                                    crudObj
                                        .deleteFolder(widget.currentLocation,
                                            currentDocumentId)
                                        .then((results) async {});
                                    var documentDirectory =
                                        await getExternalStorageDirectory();
                                    File createNewFile = new File(
                                        join(documentDirectory.path, fileName));

                                    if (createNewFile.existsSync()) {
                                      String locationOfDeleteFile =
                                          createNewFile
                                              .toString()
                                              .replaceAll("File: '", "")
                                              .replaceAll("'", "");
                                      final deleteFile =
                                          File(locationOfDeleteFile);
                                      deleteFile.deleteSync(recursive: true);
                                    }
                                    // setState(() {
                                    //   dirs.documents
                                    //       .remove(locationOfDeleteFile);
                                    // });
                                    initState();
                                  }),
                            ]),
                        onTap: () async {
                          bool isStatusTrue = await getPermissionStatus();
                          if (isStatusTrue) {
                            bool isInternetOff =
                                await downloadFile1(storageReference, context);
                            if (isInternetOff) {
                              showInSnackBar("No connection");
                            } else {
                              setState(() {
                                _listofFiles();
                              });
                            }
                          } else {
                            showInSnackBar("No permission");
                          }
                        },
                      ),
                    );
                  } else {
                    return Container(
                      // padding: EdgeInsets.all(7),
                      child: InkWell(
                        // * Directory View
                        child: Slidable(
                            actionPane: SlidableDrawerActionPane(),
                            actionExtentRatio: 0.25,
                            child: Container(
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                color: Color(0xfff0f3f4),
                                child: ListTile(
                                  leading: Icon(
                                    Icons.folder,
                                    color: Colors.blueGrey,
                                    size: 30.0,
                                  ),
                                  title: Text(
                                    dirs.documents[index].documentID,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 19,
                                    ),
                                  ),
                                  trailing: Icon(Icons.keyboard_arrow_right),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => InsideDir(
                                          dirName:
                                              '${dirs.documents[index].documentID}',
                                          currentLocation: widget
                                                  .currentLocation +
                                              '/${dirs.documents[index].documentID}' +
                                              '/collection',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            secondaryActions: <Widget>[
                              IconSlideAction(
                                  caption: 'Delete',
                                  color: Colors.red,
                                  icon: Icons.delete,
                                  // Delete from External Storage and remove item from fileNames
                                  onTap: () async {
                                    // TODO: Delete This Folder in F Storage and try to delete All sub Directory from database

                                    showInSnackBar(
                                        "$currentDocumentId is Deleted");
                                    crudObj
                                        .deleteFolder(widget.currentLocation,
                                            currentDocumentId)
                                        .then((results) {
                                      initState();
                                    });

                                    initState();
                                  }),
                            ]),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        } else {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Icon(
                  Icons.no_sim,
                  size: 100,
                  color: Colors.blueGrey,
                ),
              ),
              Text(
                "No items",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.blueGrey),
              ),
            ],
          ));
        }
      } else {
        return Center(child: CircularProgressIndicator());
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dirName),
        actions: [
          IconButton(
              icon: Icon(
                Icons.create_new_folder,
                color: Colors.white,
              ),
              onPressed: () {
                displayDialog(context);
              }),
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: FilesSearch(dirs, widget.currentLocation),
                );
              })
        ],
      ),
      key: _scaffoldKey,
      backgroundColor: Colors.blueGrey[100],
      body: bodyBuilder(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool isGrated = await getPermissionStatus();
          if (isGrated) {
            openFileExplorer();
          } else {
            showInSnackBar("No permission");
          }
        },
        child: Icon(Icons.file_upload),
        tooltip: "Upload Files",
      ),
    );
  }

  // TODO: Upload Any Files With prorper File Name in database and F Storage
  openFileExplorer() async {
    upload(fileName, filePath, firebaseDatabaseLocation) async {
      firebaseDatabaseLocation =
          firebaseDatabaseLocation.replaceAll("/collection", "");
      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child(firebaseDatabaseLocation + "/" + fileName);

      String formatFileSize(int size) {
        String hrSize;
        double b = size.toDouble();
        double k = size / 1024.0;
        double m = ((size / 1024.0) / 1024.0);
        // double g = (((size / 1024.0) / 1024.0) / 1024.0);
        // double t = ((((size / 1024.0) / 1024.0) / 1024.0) / 1024.0);
        final dec = new NumberFormat("0.00");
        final kbDec = new NumberFormat("0");
// if (t > 1) {
//         hrSize = dec.format(t) + " TB";
//       } else if (g > 1) {
//         hrSize = dec.format(g) + " GB";
//       } else
        if (m > 1) {
          hrSize = dec.format(m) + " MB";
        } else if (k > 1) {
          hrSize = kbDec.format(k) + " kB";
        } else {
          hrSize = kbDec.format(b) + " bytes";
        }
        return hrSize;
      }

      print("zzzzzz" + filePath);
      String fileSize = formatFileSize(File(filePath).lengthSync());

      _onPDFAdd(String documentFileName) {
        crudObj
            .addFolder(widget.currentLocation, documentFileName, fileSize, true)
            .then((_) {
          initState();
        });
      }

      uploadPDF() {
        String fileExtension = fileName.contains(".")
            ? fileName.split('.')[fileName.split('.').length - 1]
            : "pdf";

        final StorageUploadTask uploadTask = storageReference.putFile(
            File(filePath),
            StorageMetadata(contentType: 'application/$fileExtension'));

        // fileName.substring(0, fileName.lastIndexOf('.'));
        // fileName = fileName.substring(fileName.indexOf('^^') + 2);
        uploadTask.onComplete.then((_) {
          String fileNameWithoutExtension = fileName.contains(".")
              ? fileName.substring(0, fileName.lastIndexOf('.'))
              : fileName;
          String documentFileName = "";
          if (fileExtension == "pdf") {
            documentFileName = "XzX@PDF_" + fileNameWithoutExtension;
          } else if (fileExtension == "xls") {
            documentFileName = "XzX@xls_" + fileNameWithoutExtension;
          } else if (fileExtension == "xlsx") {
            documentFileName = "XzX@xlsx_" + fileNameWithoutExtension;
          } else {
            documentFileName =
                "XzX@z_" + fileExtension + "^^" + fileNameWithoutExtension;
          }
          _onPDFAdd(documentFileName);
          pr.hide();

          initState();
        });
      }

      uploadPDF();
    }

    uploadToFirebase() {
      pr.show();

      _paths.forEach((fileName, filePath) {
        upload(fileName, filePath, widget.currentLocation);
      });
    }

    try {
      _paths = await FilePicker.getMultiFilePath(type: FileType.any);
      if (_paths != null) {
        uploadToFirebase();
      }
    } on PlatformException catch (e) {
      print("Unsupported Opeation " + e.toString());
    }
    // if (!mounted) {
    //   return;
    // }
  }

  // downloadFile(StorageReference ref, String url) async {
  //   // final String url = await ref.getDownloadURL();
  //   final http.Response downloadData = await http.get(url);
  //   final Directory systemTempDir = Directory.systemTemp;
  //   final File tempFile = File('${systemTempDir.path}/tmp.pdf');
  //   if (tempFile.existsSync()) {
  //     await tempFile.delete();
  //   }
  //   await tempFile.create();
  //   final StorageFileDownloadTask task = ref.writeToFile(tempFile);
  //   final int byteCount = (await task.future).totalByteCount;
  //   var bodyBytes = downloadData.bodyBytes;
  //   final String name = await ref.getName();
  //   final String path = await ref.getPath();
  //   print(
  //       "Success\nDownloaded: $name\nUrl: $url\nPath: $path\nByte Count: $byteCount");
  //   _scaffoldKey.currentState.showSnackBar(SnackBar(
  //     backgroundColor: Colors.white,
  //     content: Image.memory(bodyBytes, fit: BoxFit.fill),
  //   ));
  // }

  // void getData() {
  //   print("object");
  //   databaseReference.once().then((DataSnapshot snapshot) {
  //     print('Data : ${snapshot.value}');
  //   });
  // }
}

class FilesSearch extends SearchDelegate {
  final QuerySnapshot dirs;
  final String currentLocation;

  FilesSearch(this.dirs, this.currentLocation);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: Colors.blueGrey,
      textTheme: TextTheme(title: TextStyle(color: Colors.white, fontSize: 19)),
      // cursorColor: Colors.white,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    //TODO: If hit Search Button Then Show Subtitle and if possible to view Download button then Show it
    List<DocumentSnapshot> results = dirs.documents
        .where((a) => a.documentID.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return searchBodyBuilder(context, results, currentLocation);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<DocumentSnapshot> results = dirs.documents
        .where((a) => a.documentID.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return searchBodyBuilder(context, results, currentLocation);
    // return ListView(
    // children: results.map<Widget>((a) => Text(a.documentID)).toList());
  }
}

// String getConvertedTime(Timestamp timestamp) {
//   var now = DateTime.now();
//   var today = DateTime(now.year, now.month, now.day);
//   var yesterday = DateTime(now.year, now.month, now.day - 1);
//   var format = DateFormat.yMMMMd('en_US');
//   var date =
//       DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
//   var diff = now.difference(date);
//   var time = '';

//   final aDate = DateTime(date.year, date.month, date.day);

//   if (diff.inSeconds <= 0 ||
//       diff.inSeconds > 0 && diff.inMinutes == 0 ||
//       diff.inMinutes > 0 && diff.inHours == 0 ||
//       diff.inHours > 0 && diff.inDays == 0) {
//     if (aDate == today) {
//       time = "Today " + DateFormat('HH:mm').format(date);
//     } else if (aDate == yesterday) {
//       time = "Yesterday " + DateFormat('HH:mm').format(date);
//     }
//     // time = DateFormat('HH:mm a').format(date);

//   } else if (diff.inDays > 0 && diff.inDays < 7) {
//     if (diff.inDays == 1) {
//       time = diff.inDays.toString() + ' Day ago';
//     } else {
//       time = diff.inDays.toString() + ' Days ago';
//     }
//   } else {
//     if (diff.inDays == 7) {
//       time = (diff.inDays / 7).floor().toString() + ' Week ago';
//     } else {
//       time = format.format(date);
//     }
//   }
//   return time;
// }

Widget searchBodyBuilder(
    BuildContext context, List<DocumentSnapshot> dirs, String currentLocation) {
  // CrudMedthods crudObj = new CrudMedthods();

  bool isFile(String nameOfFile) {
    if (nameOfFile.startsWith("XzX@"))
      return true;
    else
      return false;
  }

  List<String> widgetOfFile(fileName) {
    List<String> fileWidget = [];
    if (fileName.startsWith("XzX@PDF_")) {
      String renamedFileName = fileName.replaceAll("XzX@PDF_", "");
      fileWidget.add(renamedFileName + ".pdf");
      fileWidget.add("0xe415"); // picture_as_pdf
      fileWidget.add("0xffff0000"); // red color

      return fileWidget;
    } else if (fileName.startsWith("XzX@xls_")) {
      String renamedFileName = fileName.replaceAll("XzX@xls_", "");
      fileWidget.add(renamedFileName + ".xls");
      fileWidget.add("0xe873");
      fileWidget.add("0xff4caf50");

      return fileWidget;
    } else if (fileName.startsWith("XzX@xlsx_")) {
      String renamedFileName = fileName.replaceAll("XzX@xlsx_", "");
      fileWidget.add(renamedFileName + ".xlsx");
      fileWidget.add("0xe873");
      fileWidget.add("0xff4caf50");

      return fileWidget;
    } else {
      String renamedFileName = fileName.replaceAll("XzX@z_", "");
      String fileExtension =
          renamedFileName.substring(0, renamedFileName.lastIndexOf('^^'));
      renamedFileName =
          renamedFileName.substring(renamedFileName.indexOf('^^') + 2);
      fileWidget.add(renamedFileName + "." + fileExtension);
      fileWidget.add("0xe24d"); //insert_drive_file
      fileWidget.add("0xff607d8b");

      return fileWidget;
    }
  }

  if (dirs != null) {
    if (dirs.length != 0) {
      return Scaffold(
        backgroundColor: Colors.blueGrey[100],
        body: Container(
          padding: EdgeInsets.all(5),
          child: ListView(
            children: List.generate(
              dirs.length,
              (index) {
                String currentDocumentId = dirs[index].documentID;
                if (isFile(currentDocumentId)) {
                  List<String> fileWidgets = widgetOfFile(currentDocumentId);
                  String fileName = fileWidgets[0].toString();
                  fileName = fileWidgets[0];
                  int iconOfFile = int.parse(fileWidgets[1]);
                  int iconColor = int.parse(fileWidgets[2]);
                  String firebaseDatabaseLocation =
                      currentLocation.replaceAll("/collection", "");
                  StorageReference storageReference = FirebaseStorage.instance
                      .ref()
                      .child(firebaseDatabaseLocation + "/" + fileName);
                  // Timestamp updatedTimeMillis =
                  //     dirs[index].data["created_timestamp"];
                  // var resultOfFileCreatedTime =
                  //     getConvertedTime(updatedTimeMillis);

                  return Container(
                      // padding: EdgeInsets.all(7),
                      child: InkWell(
                    // ! Previous Code of Grid View
                    // child: Row(
                    //   children: <Widget>[
                    //     Padding(
                    //       padding: const EdgeInsets.only(left: 13.0),
                    //       child: Icon(
                    //         Icons.picture_as_pdf,
                    //         color: Colors.red,
                    //         size: 30.0,
                    //       ),
                    //     ),
                    //     Flexible(
                    //       child: Container(
                    //         child: Padding(
                    //           padding: const EdgeInsets.only(left: 8.0),
                    //           child: Text(
                    //             pdfFileName,
                    //             overflow: TextOverflow.ellipsis,
                    //             style: TextStyle(fontSize: 19),
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),

                    // * File View
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      color: Color(0xfff0f3f4),
                      child: ListTile(
                        leading: Icon(
                          IconData(iconOfFile, fontFamily: 'MaterialIcons'),
                          size: 30.0,
                          color: Color(iconColor),
                        ),
                        title: Text(
                          fileName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 17),
                        ),
                        // subtitle: Text(resultOfFileCreatedTime.toString()),
                      ),
                    ),
                    onTap: () async {
                      downloadFile1(storageReference, context);
                    },
                    // onLongPress: () async {
                    //   // TODO : Delete file in ExternalStorage Also

                    //   storageReference.delete();
                    //   print("Deleting");
                    //   crudObj
                    //       .deleteFolder(currentLocation, currentDocumentId)
                    //       .then((results) {
                    //     print("Folder File");
                    //     // initState();
                    //     //TODO: Out From Search
                    //   });
                    // },
                  ));
                } else {
                  return Container(
                    // padding: EdgeInsets.all(7),
                    child: InkWell(
                      // * Directory View
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: Color(0xfff0f3f4),
                        child: ListTile(
                          leading: Icon(
                            Icons.folder,
                            color: Colors.blueGrey,
                            size: 30.0,
                          ),
                          title: Text(
                            dirs[index].documentID,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 19,
                            ),
                          ),
                          trailing: Icon(Icons.keyboard_arrow_right),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InsideDir(
                              dirName: '${dirs[index].documentID}',
                              currentLocation: currentLocation +
                                  '/${dirs[index].documentID}' +
                                  '/collection',
                            ),
                          ),
                        );
                      },
                      // onLongPress: () {
                      //   // TODO: Delete This Folder in F Storage and try to delete All sub Directory from database
                      //   print("Deleting");
                      //   crudObj
                      //       .deleteFolder(
                      //           currentLocation, '${dirs[index].documentID}')
                      //       .then((results) {
                      //     print("Folder Deleted");
                      //     // initState();
                      //     //TODO: Out From Search
                      //   });
                      // },
                    ),
                  );
                }
              },
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.blueGrey[100],
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Icon(
                Icons.no_sim,
                size: 100,
                color: Colors.blueGrey,
              ),
            ),
            Text(
              "No items",
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.blueGrey),
            ),
          ],
        )),
      );
    }
  } else {
    return Center(child: CircularProgressIndicator());
  }
}
