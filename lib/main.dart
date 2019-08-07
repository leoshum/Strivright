import 'package:flutter/material.dart';

import 'screens/auth/signin.screen.dart';
import 'screens/signature/signature.screen.dart';
import 'screens/home/home.screen.dart';
import 'screens/legacy/legacy.screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignIn(),
      routes: <String, WidgetBuilder>{
        '/page': (BuildContext context) => new MyApp(),
        '/homepage': (BuildContext context) => new HomePage(),
        '/drawer': (BuildContext context) => new DrawerPage(),
        '/legacy': (BuildContext context) => new LegacyPage()
      },
    );
  }
}
