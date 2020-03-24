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
      title: 'Manuals',
      theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          })),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
