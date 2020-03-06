///TODO : Debug Code at add list item
///TODO : Refesh Page After Add new item

import 'package:flutter/material.dart';

class InsideDir extends StatefulWidget {
  final String dirName;
  @override
  _InsideDirState createState() => _InsideDirState();
  InsideDir({Key key, @required this.dirName}) : super(key: key);
}

class _InsideDirState extends State<InsideDir> {
  static List<String> _currentList;
  static TextEditingController _textFieldController = TextEditingController();

  List<String> _plcs = ["Simense", "Attoy Bruy", "Another One"];
  List<String> _drives = ["Servers", "Drives", "Another One"];
  List<String> _visionCommands = ["list item1", "list item 2", "list item 3"];
  List<String> _daiChiCommands = ["list item1", "list item 2", "list item 4"];
  List<String> _emptyList = [];

  Widget build(BuildContext context) {
    print(widget.dirName);
    switch (widget.dirName) {
      case 'PLCs':
        _currentList = _plcs;
        break;
      case 'Drives':
        _currentList = _drives;
        break;
      case 'Vision Commands':
        _currentList = _visionCommands;
        break;
      case 'Dai-Chi Commands':
        _currentList = _daiChiCommands;
        break;

      default:
        _currentList = _emptyList;
    }
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
              Icons.add,
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
      if (_currentList.length == 0) {
        return Center(child: Text("No Items Found"));
      }
      return Container(
        child: GridView.count(
            crossAxisCount: 2,
            children: List.generate(
              _currentList.length,
              (index) {
                return InkWell(
                  child: Center(
                    child: Text(
                      ('${_currentList[index]}'),
                      style: Theme.of(context).textTheme.headline,
                    ),
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
                );
              },
            )),
      );
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

        body: bodyBuilder(context));
  }
}
