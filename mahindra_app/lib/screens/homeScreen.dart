import 'package:flutter/material.dart';
import 'package:mahindra_app/screens/secondScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _manualsList = [
    "PLCs",
    "Drives",
    "Vision Commands",
    "Dai-Chi Commands",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: GridView.count(
        crossAxisCount: 2,
        children: List.generate(_manualsList.length, (index) {
          return Scaffold(
            body: InkWell(
                child: Center(
                  child: Text(
                    ('${_manualsList[index]}'),
                    style: Theme.of(context).textTheme.headline,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SecondScreen(),
                      // Pass the arguments as part of the RouteSettings. The
                      // DetailScreen reads the arguments from these settings.
                      settings: RouteSettings(
                        arguments: index,
                      ),
                    ),
                  );
                }),
          );
        }),
      )),
    );
  }
}
