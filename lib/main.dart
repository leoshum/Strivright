import 'package:app_flutter/screens/splash/splash.screen.dart';
import 'package:flutter/material.dart';
import 'screens/auth/signin.screen.dart';
import 'screens/signature/drawer.page.dart';
import 'screens/home/home.screen.dart';
import 'screens/legacy/legacy.screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      routes: <String, WidgetBuilder>{
        '/page': (BuildContext context) => MyApp(),
        '/homepage': (BuildContext context) => HomePage(),
        '/login': (BuildContext context) => SignIn(),
        '/drawer': (BuildContext context) => DrawerPage(),
        '/legacy': (BuildContext context) => LegacyPage()
      },
    );
  }
}
