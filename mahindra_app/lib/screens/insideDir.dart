//TODO: Naviagte to Different Directory using FireStore Database
//TODO: Create Document in FireStore from UI

//TODO: Upload Direcotory name to Firebase
//TODO: Upload inside Direcotories into Current Page
//TODO: Fetch Data From Firebase when uploading new Folder or Navigating new Screen
//TODO: Add Files to Current Page After All Folders with Files View
//TODO: Add Firebase Storage
//TODO: Add Multiple Delete option

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mahindra_app/services/crud.dart';

class InsideDir extends StatefulWidget {
  final String dirName;
  @override
  _InsideDirState createState() => _InsideDirState();
  InsideDir({Key key, @required this.dirName}) : super(key: key);
}

class _InsideDirState extends State<InsideDir> {
  static TextEditingController _textFieldController = TextEditingController();
  QuerySnapshot dirs;
  CrudMedthods crudObj = new CrudMedthods();
  final databaseReference = FirebaseDatabase.instance.reference();
  // List<String> _plcs = ["Simense", "Attoy Bruy", "Another One"];
  // List<String> _drives = ["Servers", "Drives", "Another One"];
  // List<String> _visionCommands = ["list item1", "list item 2", "list item 3"];
  // List<String> _daiChiCommands = ["list item1", "list item 2", "list item 4"];
  List<String> _currentList = [];

  @override
  void initState() {
    crudObj.getData().then((results) {
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
      setState(() {
        _currentList.add(_textFieldController.text);
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
                    _onAdd();
                    Navigator.of(context).pop();
                    _textFieldController.clear();
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

    Widget bodyBuilder(BuildContext context) {
      if (dirs != null) {
        return Container(
          padding: EdgeInsets.all(8),
          child: GridView.count(
              childAspectRatio: 2.9,
              crossAxisCount: 2,
              children: List.generate(
                dirs.documents.length,
                (index) {
                  return Container(
                    padding: EdgeInsets.all(7),
                    child: InkWell(
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 13.0),
                            child: Icon(
                              Icons.folder,
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
                            builder: (context) =>
                                InsideDir(dirName: '${_currentList[index]}'),
                            // Pass the arguments as part of the RouteSettings. The
                            // DetailScreen reads the arguments from these settings.
                            // settings: RouteSettings(
                            //   arguments: index,
                            // ),
                          ),
                        );
                      },
                      onLongPress: () {
                        print("object");
                        _changeAppbar();
                      },
                    ),
                  );
                },
              )),
        );
      } else {
        return Center(child: Text("No Items Found"));
      }
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
        onPressed: () {
          getData();
        },
        child: Icon(Icons.file_upload),
        tooltip: "Upload Files",
      ),
    );
  }

  void getData() {
    print("object");
    databaseReference.once().then((DataSnapshot snapshot) {
      print('Data : ${snapshot.value}');
    });
  }
}
