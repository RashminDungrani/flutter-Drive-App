import 'package:flutter/material.dart';
import 'package:drive_app/screens/downloadFilesScreen.dart';
import 'package:drive_app/screens/insideDir.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _manualsList = [
    "PLCs",
    "Drives",
    "Vision Commands",
    "Dai Chi Commands",
  ];
  List<String> _manualsList1 = [
    "PLCs",
    "Drives",
    "Vision\nCommands",
    "Dai Chi\nCommands",
  ];

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2;
    final double itemWidth = size.width / 2;

    return Scaffold(
        appBar: AppBar(
          title: Text('Manuals'),
          actions: <Widget>[
            new IconButton(
                icon: new Icon(
                  Icons.file_download,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DownloadedFiles(),
                    ),
                  );
                })
          ],
        ),
        backgroundColor: Colors.blueGrey[100],
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: (itemWidth / itemHeight),
              controller: new ScrollController(keepScrollOffset: false),
              shrinkWrap: true,
              children: List.generate(_manualsList.length, (index) {
                return Hero(
                  tag: '${_manualsList1[index]}',
                  child: InkWell(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color: Colors.blueGrey[600],
                        child: Center(
                          child: Text(
                            ('${_manualsList1[index]}'),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.8),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InsideDir(
                              dirName: '${_manualsList[index]}',
                              currentLocation:
                                  "Folders/${_manualsList[index]}/collection",
                            ),
                            // Pass the arguments as part of the RouteSettings. The
                            // DetailScreen reads the arguments from these settings.
                            // settings: RouteSettings(
                            //   arguments: index,
                            // ),
                          ),
                        );
                      }),
                );
              }),
            ),
          ),
        ));
  }
}
