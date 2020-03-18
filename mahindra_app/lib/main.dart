// TODO: Material App for Dark mode

import 'package:flutter/material.dart';

import 'screens/homeScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return
//     MaterialApp(
//   theme: ThemeData(
//     brightness: Brightness.light,
//     primaryColor: Colors.red,
//   ),
//   darkTheme: ThemeData(
//     brightness: Brightness.dark,
//   ),
// );

        MaterialApp(
      title: 'Mahindra App',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(),
      // debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manuals'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Icon(Icons.search),
          )
        ],
      ),
      body: HomeScreen(),
    );
  }
}
