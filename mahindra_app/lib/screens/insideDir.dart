//TODO: Delete Files and Folder in FStorage inside Folder When Folder is delete
//TODO: Show Simple Notify text At bottom like other Apps
//TODO: Add Search Option of Files and Folders
//TODO: onLongPress Show Alert Box "Are you Sure" and then delete file or Folder if input is yes (true)
//TODO: Pull Down To refresh
//TODO: Add Multiple selection to long press for Delete operation

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mahindra_app/services/crud.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';

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

  // String _extension;
  // FileType _pickType = FileType.custom;
  // GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  // List<StorageUploadTask> _tasks = <StorageUploadTask>[];

  @override
  initState() {
    crudObj.getData(widget.currentLocation).then((results) {
      setState(() {
        dirs = results;
        // print(dirs);
      });
    });

    super.initState();
  }

  Future<void> downloadFile1(StorageReference ref) async {
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
      pr.show();
      print("From Create new File");
      await createNewFile.create().then((_) async {
        await ref.writeToFile(createNewFile).future.then((_) async {
          pr.hide();
          await OpenFile.open(locationOfNewFile);
        });
      });
    }
  }

  Widget build(BuildContext context) {
    pr = new ProgressDialog(context);
    pr.style(message: 'Please wait...');
    _onAdd() {
      crudObj
          .addFolder(widget.currentLocation, _textFieldController.text, false)
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
                  child: new Text('CANCEL'),
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

    AppBar _defaultBar = AppBar(
      title: Text(widget.dirName),
      actions: <Widget>[
        IconButton(
            icon: Icon(
              Icons.create_new_folder,
              color: Colors.white,
            ),
            onPressed: () {
              displayDialog(context);
            }),
      ],
    );

    // AppBar _selectBar = AppBar(
    //   title: Text(widget.dirName),
    //   leading: Icon(Icons.close),
    //   actions: <Widget>[
    //     Icon(Icons.flag),
    //     Icon(Icons.delete),
    //     Icon(Icons.more_vert)
    //   ],
    //   backgroundColor: Colors.deepPurple,
    // );
    AppBar _appBar = _defaultBar;

    // _changeAppbar() {
    //   setState(() {
    //     _appBar = _appBar == _defaultBar ? _selectBar : _defaultBar;
    //   });
    // }

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
          time = "Today " + DateFormat('HH:mm').format(date);
        } else if (aDate == yesterday) {
          time = "Yesterday " + DateFormat('HH:mm').format(date);
        }
        // time = DateFormat('HH:mm a').format(date);

      } else if (diff.inDays > 0 && diff.inDays < 7) {
        if (diff.inDays == 1) {
          time = diff.inDays.toString() + ' Day ago';
        } else {
          time = diff.inDays.toString() + ' Days ago';
        }
      } else {
        if (diff.inDays == 7) {
          time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
        } else {
          time = format.format(date);
        }
      }
      return time;
    }

    Widget bodyBuilder(BuildContext context) {
      // bool isPDF(String nameOfFile) {
      //   if (nameOfFile.startsWith("zzz@PDF_"))
      //     return true;
      //   else
      //     return false;
      // }

      bool isFile(String nameOfFile) {
        if (nameOfFile.startsWith("zzz@"))
          return true;
        else
          return false;
      }

      List<Widget> widgetOfFile(fileName) {
        List<Widget> fileWidget = [];
        if (fileName.startsWith("zzz@PDF_")) {
          String renamedFileName = fileName.replaceAll("zzz@PDF_", "");
          fileWidget.add(Text(renamedFileName + ".pdf"));
          fileWidget.add(Icon(
            Icons.picture_as_pdf,
            color: Colors.red,
            size: 30.0,
          ));

          return fileWidget;
        } else if (fileName.startsWith("zzz@xls_")) {
          String renamedFileName = fileName.replaceAll("zzz@xls_", "");
          fileWidget.add(Text(renamedFileName + ".xls"));
          fileWidget.add(Icon(
            Icons.description,
            color: Colors.green,
            size: 30.0,
          ));

          return fileWidget;
        } else if (fileName.startsWith("zzz@xlsx_")) {
          String renamedFileName = fileName.replaceAll("zzz@xlsx_", "");
          fileWidget.add(Text(renamedFileName + ".xlsx"));
          fileWidget.add(Icon(
            Icons.description,
            color: Colors.green,
            size: 30.0,
          ));

          return fileWidget;
        } else {
          String renamedFileName = fileName.replaceAll("zzz@z_", "");
          String fileExtension =
              renamedFileName.substring(0, renamedFileName.lastIndexOf('^^'));
          renamedFileName =
              renamedFileName.substring(renamedFileName.indexOf('^^') + 2);
          fileWidget.add(Text(renamedFileName + "." + fileExtension));
          fileWidget.add(Icon(
            Icons.insert_drive_file,
            color: Colors.blueGrey,
            size: 30.0,
          ));

          return fileWidget;
        }
      }

//  && timeMillis != null
// || timeMillis.isNotEmpty
      if (dirs != null) {
        if (dirs.documents.length != 0) {
          return Container(
            padding: EdgeInsets.all(5),
            // ! Previous Code of Grid View
            // GridView.count(
            //   crossAxisCount: 2,
            //   childAspectRatio: 3,
            child: ListView(
              children: List.generate(
                dirs.documents.length,
                (index) {
                  String currentDocumentId = dirs.documents[index].documentID;
                  if (isFile(currentDocumentId)) {
                    List<Widget> fileWidgets = widgetOfFile(currentDocumentId);
                    String fileName = fileWidgets[0].toString();
                    fileName = fileWidgets[0].toString().substring(
                        6,
                        fileName.length -
                            2); // * is not working then get name here

                    String firebaseDatabaseLocation =
                        widget.currentLocation.replaceAll("/collection", "");
                    StorageReference storageReference = FirebaseStorage.instance
                        .ref()
                        .child(firebaseDatabaseLocation + "/" + fileName);
                    Timestamp updatedTimeMillis =
                        dirs.documents[index].data["created_timestamp"];
                    var resultOfFileCreatedTime =
                        getConvertedTime(updatedTimeMillis);

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
                          leading: fileWidgets[1],
                          title: Text(
                            fileName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 17),
                          ),
                          subtitle: Text(resultOfFileCreatedTime.toString()),
                        ),
                      ),
                      onTap: () async {
                        downloadFile1(storageReference);
                      },
                      onLongPress: () async {
                        // TODO : Delete file in ExternalStorage Also

                        storageReference.delete();
                        print("Deleting");
                        crudObj
                            .deleteFolder(widget.currentLocation,
                                '${dirs.documents[index].documentID}')
                            .then((results) {
                          print("Folder File");
                          initState();
                        });
                      },
                    ));
                  } else {
                    return Container(
                      // padding: EdgeInsets.all(7),
                      child: InkWell(
                        // ! Previous Code of Grid View
                        // child: Row(
                        //   children: <Widget>[
                        //     Padding(
                        //       padding: const EdgeInsets.only(left: 13.0),
                        //       child: Icon(
                        //         Icons.folder,
                        //         color: Colors.blueGrey,
                        //         size: 30.0,
                        //       ),
                        //     ),
                        //     Flexible(
                        //       child: Container(
                        //         child: Padding(
                        //           padding: const EdgeInsets.only(left: 8.0),
                        //           child: Text(
                        //             (dirs.documents[index].documentID),
                        //             overflow: TextOverflow.ellipsis,
                        //             style: TextStyle(fontSize: 19),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),

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
                              dirs.documents[index].documentID,
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
                                dirName: '${dirs.documents[index].documentID}',
                                currentLocation: widget.currentLocation +
                                    '/${dirs.documents[index].documentID}' +
                                    '/collection',
                              ),
                            ),
                          );
                        },
                        onLongPress: () {
                          // TODO: Delete This Folder in F Storage and try to delete All sub Directory from database
                          print("Deleting");
                          crudObj
                              .deleteFolder(widget.currentLocation,
                                  '${dirs.documents[index].documentID}')
                              .then((results) {
                            print("Folder Deleted");
                            initState();
                          });
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          );
        } else {
          return Center(
              child: Text(
            "Folder is empty",
            style: TextStyle(fontSize: 16),
          ));
        }
      } else {
        return Center(child: CircularProgressIndicator());
      }

      // printAllFilesFromFirebase();
    }

    return Scaffold(
      appBar: _appBar,
      // AppBar(
      //   title: Text(_title),
      //   actions: <Widget>[
      //     IconButton(
      //         icon: Icon(
      //           Icons.add,
      //           color: Colors.white,
      //         ),
      //         onPressed: () {
      //           _displayDialog(context);
      //         }),
      //   ],
      // ),

      body: bodyBuilder(context),
      backgroundColor: Colors.blueGrey[100],

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          openFileExplorer();
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

      _onPDFAdd(String documentFileName) {
        crudObj
            .addFolder(widget.currentLocation, documentFileName, true)
            .then((_) {
          // initState();
        });
      }

      uploadPDF() {
        String fileExtension =
            fileName.contains(".") ? fileName.split('.')[1] : "pdf";

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
            documentFileName = "zzz@PDF_" + fileNameWithoutExtension;
          } else if (fileExtension == "xls") {
            documentFileName = "zzz@xls_" + fileNameWithoutExtension;
          } else if (fileExtension == "xlsx") {
            documentFileName = "zzz@xlsx_" + fileNameWithoutExtension;
          } else {
            documentFileName =
                "zzz@z_" + fileExtension + "^^" + fileNameWithoutExtension;
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
