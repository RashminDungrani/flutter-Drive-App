// Get Downloaded fileNames, fileSizes
// Swipe Left and Press delete to Delete Files

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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

Future<bool> openFile(String fileLocation) async {
  if (await File(fileLocation).exists()) {
    await OpenFile.open(fileLocation);
    return true;
  } else {
    return false;
  }
}

class DownloadedFiles extends StatefulWidget {
  @override
  _DownloadedFilesState createState() => _DownloadedFilesState();
}

class _DownloadedFilesState extends State<DownloadedFiles> {
  String directory;
  List downloadedFilePaths = new List();
  List<String> fileNames = [];
  List<String> fileSizes = [];
  List<String> fileLocation = [];

  @override
  initState() {
    _listofFiles();
    super.initState();
  }

  String formatFileSize(int size) {
    String hrSize;
    double b = size.toDouble();
    double k = size / 1024.0;
    double m = ((size / 1024.0) / 1024.0);
    final dec = new NumberFormat("0.00");
    final kbDec = new NumberFormat("0");

    if (m > 1) {
      hrSize = dec.format(m) + " MB";
    } else if (k > 1) {
      hrSize = kbDec.format(k) + " kB";
    } else {
      hrSize = kbDec.format(b) + " bytes";
    }
    return hrSize;
  }

  _listofFiles() async {
    directory = (await getExternalStorageDirectory()).path;
    setState(() {
      downloadedFilePaths = Directory("$directory/").listSync();
    });

    for (var filePath in downloadedFilePaths) {
      String fileName = filePath.toString();
      fileName = fileName?.split("/")?.last.toString().replaceAll("'", "");
      fileNames.add(fileName);
      filePath =
          filePath.toString().replaceAll("File: '", "").replaceAll("'", "");
      fileLocation.add(filePath);
      String fileSize = formatFileSize(File(filePath).lengthSync());
      fileSizes.add(fileSize);
    }
    return fileNames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff0f3f4),
      appBar: AppBar(
        title: Text("Downloads"),
        actions: [
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: FilesSearch(fileNames),
                );
              })
        ],
      ),
      body: bodybuilder(),
    );
  }

  Widget bodybuilder() {
    List<String> leadingIcon(fileName) {
      List<String> fileWidget = [];
      if (fileName.endsWith(".pdf")) {
        fileWidget.add("0xe415"); // picture_as_pdf
        fileWidget.add("0xffff0000"); // red color

        return fileWidget;
      } else if (fileName.endsWith(".xls")) {
        fileWidget.add("0xe873");
        fileWidget.add("0xff4caf50");

        return fileWidget;
      } else if (fileName.endsWith(".xlsx")) {
        fileWidget.add("0xe873");
        fileWidget.add("0xff4caf50");
        return fileWidget;
      } else {
        fileWidget.add("0xe24d"); //insert_drive_file
        fileWidget.add("0xff607d8b");
        return fileWidget;
      }
    }

    if (fileNames != null) {
      if (fileNames.length != 0) {
        return Container(
          child: ListView.builder(
              itemCount: fileNames.length,
              itemBuilder: (BuildContext context, int index) {
                //TODO: Add dismissible and add delete button to Delete Files and setState to remove item
                List<String> leadingIconWidget = leadingIcon(fileNames[index]);
                int iconOfFile = int.parse(leadingIconWidget[0]);
                int iconColor = int.parse(leadingIconWidget[1]);
                return InkWell(
                    child: Slidable(
                        actionPane: SlidableDrawerActionPane(),
                        actionExtentRatio: 0.25,
                        child: Container(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color(iconColor),
                              child: Icon(IconData(iconOfFile,
                                  fontFamily: 'MaterialIcons')),
                              foregroundColor: Colors.white,
                            ),
                            // Icon(
                            //   IconData(iconOfFile, fontFamily: 'MaterialIcons'),
                            //   size: 30.0,
                            //   color: Color(iconColor),
                            // ),
                            title: Text(
                              fileNames[index],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 17),
                            ),
                            subtitle: Text(fileSizes[index]),
                          ),
                        ),
                        secondaryActions: <Widget>[
                          IconSlideAction(
                              caption: 'Delete',
                              color: Colors.red,
                              icon: Icons.delete,
                              // Delete from External Storage and remove item from fileNames
                              onTap: () async {
                                var documentDirectory =
                                    await getExternalStorageDirectory();
                                File createNewFile = new File(join(
                                    documentDirectory.path, fileNames[index]));
                                String locationOfDeleteFile = createNewFile
                                    .toString()
                                    .replaceAll("File: '", "")
                                    .replaceAll("'", "");
                                final deleteFile = File(locationOfDeleteFile);
                                deleteFile.deleteSync(recursive: true);
                                setState(() {
                                  fileNames.remove(fileNames[index]);
                                });
                              }),
                        ]),
                    onTap: () async {
                      bool isStatusTrue = await getPermissionStatus();
                      if (isStatusTrue) {
                        await openFile(fileLocation[index]);
                        // if (!isExist) {}
                      }
                    });
              }),
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
    }
    return Center(child: CircularProgressIndicator());
  }
}

searchAndOpen(String fileName) async {
  var documentDirectory = await getExternalStorageDirectory();
  File createNewFile = new File(join(documentDirectory.path, fileName));
  String locationOfNewFile =
      createNewFile.toString().replaceAll("File: '", "").replaceAll("'", "");

  // createNewFile.existsSync()
  if (await File(locationOfNewFile).exists()) {
    await OpenFile.open(locationOfNewFile);
    return true;
  } else {
    return false;
  }
}

class FilesSearch extends SearchDelegate {
  final List<String> fileNames;

  FilesSearch(
    this.fileNames,
  );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: Colors.blueGrey,
      textTheme: TextTheme(title: TextStyle(color: Colors.white, fontSize: 19)),
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
    List<String> results = fileNames
        .where((a) => a.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return searchBodyBuilder(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> results = fileNames
        .where((a) => a.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return searchBodyBuilder(context, results);
  }
}

Widget searchBodyBuilder(BuildContext context, List<String> fileNames) {
  List<String> leadingIcon(fileName) {
    List<String> fileWidget = [];
    if (fileName.endsWith(".pdf")) {
      fileWidget.add("0xe415"); // picture_as_pdf
      fileWidget.add("0xffff0000"); // red color

      return fileWidget;
    } else if (fileName.endsWith(".xls")) {
      fileWidget.add("0xe873");
      fileWidget.add("0xff4caf50");

      return fileWidget;
    } else if (fileName.endsWith(".xlsx")) {
      fileWidget.add("0xe873");
      fileWidget.add("0xff4caf50");
      return fileWidget;
    } else {
      fileWidget.add("0xe24d"); //insert_drive_file
      fileWidget.add("0xff607d8b");
      return fileWidget;
    }
  }

  if (fileNames != null) {
    if (fileNames.length != 0) {
      return Container(
        color: Color(0xfff0f3f4),
        child: ListView.builder(
            itemCount: fileNames.length,
            itemBuilder: (BuildContext context, int index) {
              //TODO: Add dismissible and add delete button to Delete Files and setState to remove item
              List<String> leadingIconWidget = leadingIcon(fileNames[index]);
              int iconOfFile = int.parse(leadingIconWidget[0]);
              int iconColor = int.parse(leadingIconWidget[1]);
              return InkWell(
                  child: ListTile(
                    leading: Icon(
                      IconData(iconOfFile, fontFamily: 'MaterialIcons'),
                      size: 30.0,
                      color: Color(iconColor),
                    ),
                    title: Text(
                      fileNames[index],
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                  onTap: () async {
                    bool isStatusTrue = await getPermissionStatus();
                    if (isStatusTrue) {
                      await searchAndOpen(fileNames[index]);
                      // if (!isExist) {}
                    }
                  });
            }),
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
  }
  return Center(child: CircularProgressIndicator());
}
