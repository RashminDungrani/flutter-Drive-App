//TODO: Download File to view offline From app pdf
//TODO: Delete Files and Folder in FStorage inside Folder When Folder is delete
//TODO: Add Search Option of Files and Folders
//TODO: onLongPress Show Alert Box "Are you Sure" and then delete file or Folder if input is yes (true)
//TODO: Add CircularProgressIndicator when Downloading File from FStorage or Upload to FStorage
//TODO: Make Better Ui of home Screen
//TODO: Pull Down To refresh
//TODO: Add Multiple Delete option

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mahindra_app/services/crud.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';

class InsideDir extends StatefulWidget {
  final String dirName;
  final String currentLocation;

  @override
  _InsideDirState createState() => _InsideDirState();
  InsideDir({Key key, @required this.dirName, @required this.currentLocation})
      : super(key: key);
}

class _InsideDirState extends State<InsideDir> {
  static TextEditingController _textFieldController = TextEditingController();
  QuerySnapshot dirs;
  CrudMedthods crudObj = new CrudMedthods();
  Map<String, String> _paths;
  String _extension;
  // FileType _pickType = FileType.custom;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<StorageUploadTask> _tasks = <StorageUploadTask>[];

  @override
  void initState() {
    // print("From initState 👉  : " + widget.currentLocation);
    crudObj.getData(widget.currentLocation).then((results) {
      setState(() {
        dirs = results;
      });
    });

    super.initState();
  }

  Widget build(BuildContext context) {
    // switch (widget.dirName) {
    //   case 'PLCs':
    //     _currentList = _plcs;
    //     break;
    //   case 'Drives':
    //     _currentList = _drives;
    //     break;
    //   case 'Vision Commands':
    //     _currentList = _visionCommands;
    //     break;
    //   case 'Dai-Chi Commands':
    //     _currentList = _daiChiCommands;
    //     break;

    //   default:
    //     _currentList = _currentList;
    // }

    _onAdd() {
      crudObj
          .addFolder(widget.currentLocation, _textFieldController.text)
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

    AppBar _selectBar = AppBar(
      title: Text(widget.dirName),
      leading: Icon(Icons.close),
      actions: <Widget>[
        Icon(Icons.flag),
        Icon(Icons.delete),
        Icon(Icons.more_vert)
      ],
      backgroundColor: Colors.deepPurple,
    );
    AppBar _appBar = _defaultBar;

    _changeAppbar() {
      setState(() {
        _appBar = _appBar == _defaultBar ? _selectBar : _defaultBar;
      });
    }

    // Future<List<String>> getFilesNames() async {
    //   String fileLocation = widget.currentLocation;
    //   fileLocation = fileLocation
    //       .replaceAll("collection", "")
    //       .replaceAll("//", "/collection/");
    //   var document = Firestore.instance.document(fileLocation);
    //   List<String> fileNames = [];
    //   document.get().then((value) {
    //     for (String value in value.data.values) {
    //       print(value);
    //       fileNames.add(value);
    //     }
    //   });

    //   return await fileNames;
    // }

    Widget bodyBuilder(BuildContext context) {
      bool isPDF(String nameOfFile) {
        if (nameOfFile.startsWith("zzz@PDF_"))
          return true;
        else
          return false;
      }

      if (dirs != null) {
        if (dirs.documents.length != 0) {
          return Container(
            padding: EdgeInsets.all(8),
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 3,
              children: List.generate(
                dirs.documents.length,
                (index) {
                  if (isPDF(dirs.documents[index].documentID)) {
                    String pdfFileName = dirs.documents[index].documentID
                        .replaceAll("zzz@PDF_", "");
                    pdfFileName = pdfFileName + ".pdf";
                    return Container(
                        padding: EdgeInsets.all(7),
                        child: InkWell(
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 13.0),
                                child: Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.red,
                                  size: 30.0,
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      pdfFileName,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 19),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onTap: () async {
                            print("Downloading");

                            String firebaseDatabaseLocation = widget
                                .currentLocation
                                .replaceAll("/collection", "");
                            StorageReference storageReference = FirebaseStorage
                                .instance
                                .ref()
                                .child(firebaseDatabaseLocation +
                                    "/" +
                                    pdfFileName);

                            crudObj
                                .downloadFile(storageReference)
                                .then((results) {});
                            // final String url =
                            //     await storageReference.getDownloadURL();
                            // print("😡   " + url);
                            // launch(
                            //     "https://firebasestorage.googleapis.com/v0/b/drive-app-15286.appspot.com/o/Folders%2FPLCs%2FResume.pdf?alt=media&token=fe62901a-91d7-4d87-a482-07df8501662d");
                          },
                          onLongPress: () async {
                            String firebaseDatabaseLocation = widget
                                .currentLocation
                                .replaceAll("/collection", "");
                            StorageReference storageReference = FirebaseStorage
                                .instance
                                .ref()
                                .child(firebaseDatabaseLocation +
                                    "/" +
                                    pdfFileName);
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
                      padding: EdgeInsets.all(7),
                      child: InkWell(
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 13.0),
                              child: Icon(
                                Icons.folder,
                                color: Colors.blueGrey,
                                size: 30.0,
                              ),
                            ),
                            Flexible(
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    (dirs.documents[index].documentID),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 19),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
          return Center(child: Text("No Item Found"));
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

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          openFileExplorer();
          // lauuchPdf();
        },
        child: Icon(Icons.file_upload),
        tooltip: "Upload Files",
      ),
    );
  }

  openFileExplorer() async {
    try {
      _paths = await FilePicker.getMultiFilePath(
          type: FileType.custom, fileExtension: "pdf");
      uploadToFirebase();
    } on PlatformException catch (e) {
      print("Unsupported Opeation " + e.toString());
    }
    if (!mounted) {
      return;
    }
  }

  uploadToFirebase() {
    if (_paths != null) {
      _paths.forEach((fileName, filePath) {
        upload(fileName, filePath, widget.currentLocation);
        print(fileName.toString() + " : " + filePath.toString());
      });
    }
  }

  upload(fileName, filePath, firebaseDatabaseLocation) async {
    _extension = fileName.toString().split('.').last;
    firebaseDatabaseLocation =
        firebaseDatabaseLocation.replaceAll("/collection", "");
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child(firebaseDatabaseLocation + "/" + fileName);
    storageReference.putFile(File(filePath),
        StorageMetadata(contentType: 'application/$_extension'));
    _onPDFAdd(fileName);
    // setState(() {
    //   _tasks.add(uploadTask);

    //   final String url = await storageReference.getDownloadURL();
    //   downloadFile(storageReference, url);
    // });

    // * Generate Download URL
    // final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    // final String url = (await downloadUrl.ref.getDownloadURL());

    // print("URL is $url");

//     I/flutter ( 7480): T.Y.B.C.A. Sem-6 _February - 2019_Computer Graphics.pdf : /data/user/0/com.example.drive/cache/T.Y.B.C.A. Sem-6 _February - 2019_Computer Graphics.pdf
// W/StorageUtil( 7480): no auth token for request
// W/NetworkRequest( 7480): no auth token for request
// I/flutter ( 7480): URL is https://firebasestorage.googleapis.com/v0/b/drive-app-15286.appspot.com/o/T.Y.B.C.A.%20Sem-6%20_February%20-%202019_Computer%20Graphics.pdf?alt=media&token=f0c45c90-fe5d-47c3-b701-b754a68707bf
  }

  _onPDFAdd(String fullPDFname) {
    fullPDFname = fullPDFname.replaceAll(".pdf", "");
    fullPDFname = "zzz@PDF_" + fullPDFname;
    crudObj.addFolder(widget.currentLocation, fullPDFname).then((results) {
      initState();
    });
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
