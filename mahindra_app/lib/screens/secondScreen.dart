import 'package:flutter/material.dart';
import 'package:mahindra_app/screens/thirdScreen.dart';

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  List<String> _plcs = ["Simense", "Attoy Bruy", "Another One"];
  List<String> _drives = ["Servers", "Drives", "Another One"];
  List<String> _visionCommands = ["list item1", "list item 2", "list item 3"];
  List<String> _daiChiCommands = ["list item1", "list item 2", "list item 4"];
  @override
  Widget build(BuildContext context) {
    final int todo = ModalRoute.of(context).settings.arguments;
    List<String> _currentList;
    String _title;
    switch (todo) {
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

    return Scaffold(
        appBar: AppBar(
          title: Text(_title),
        ),
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ThirdScreen(),
                          // Pass the arguments as part of the RouteSettings. The
                          // DetailScreen reads the arguments from these settings.
                          settings: RouteSettings(
                            arguments: index,
                          ),
                        ),
                      );
                    },
                  );
                },
              )),
        )));
  }
}
