import 'package:flutter/material.dart';
import 'package:imagetext/Screens/HomePage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Business Card',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: AppBarTheme(
            brightness: Brightness.dark,
          )),
      debugShowCheckedModeBanner: false,
      home: new HomePage(),
    );
  }
}
