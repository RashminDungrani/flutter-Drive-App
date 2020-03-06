import 'package:flutter/material.dart';

class SecondScreen extends StatefulWidget {
  final int listNum;
  @override
  _SecondScreenState createState() => _SecondScreenState();
  SecondScreen({Key key, @required this.listNum}) : super(key: key);
}

class _SecondScreenState extends State<SecondScreen> {
  String _title = "1";
  List<String> _currentList;
  TextEditingController _textFieldController = TextEditingController();

  List<String> _plcs = ["Simense", "Attoy Bruy", "Another One"];
  List<String> _drives = ["Servers", "Drives", "Another One"];
  List<String> _visionCommands = ["list item1", "list item 2", "list item 3"];
  List<String> _daiChiCommands = ["list item1", "list item 2", "list item 4"];

  @override
  Widget build(BuildContext context) {
    _onAdd() {
      setState(() {
        _currentList.add(_textFieldController.text);
      });
    }

    _displayDialog(BuildContext context) async {
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
                  child: new Text('Add'),
                  onPressed: () {
                    _onAdd();
                    Navigator.of(context).pop();
                    _textFieldController.clear();
                  },
                ),
                new FlatButton(
                  child: new Text('CANCEL'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _textFieldController.clear();
                  },
                ),
              ],
            );
          });
    }

    switch (widget.listNum) {
      case 0:
        _currentList = _plcs;
        _title = "PlCs";
        break;
      case 1:
        _currentList = _drives;
        _title = "Drives";

        break;
      case 2:
        _currentList = _visionCommands;
        _title = "Vision Commands";

        break;
      case 3:
        _currentList = _daiChiCommands;
        _title = "Dai Chi Commands";
        break;

      default:
        _currentList = null;
    }

    AppBar _defaultBar = AppBar(
      title: Text(_title),
      actions: <Widget>[
        IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              // displayDialog(context);
              _displayDialog(context);
            }),
      ],
    );

    AppBar _selectBar = AppBar(
      title: Text('1'),
      leading: Icon(Icons.close),
      actions: <Widget>[
        Icon(Icons.flag),
        Icon(Icons.delete),
        Icon(Icons.more_vert)
      ],
      backgroundColor: Colors.deepPurple,
    );

    AppBar _appBar = _defaultBar;

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
        body: (Container(
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
                    onLongPress: () {
                      print("object");
                      setState(() {
                        _appBar =
                            _appBar == _defaultBar ? _selectBar : _defaultBar;
                      });
                    },
                  );
                },
              )),
        )));
  }
}
