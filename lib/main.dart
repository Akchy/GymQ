import 'package:flutter/material.dart';
import 'package:gymnasium/screen/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screen/SplashScreen.dart';
import 'screen/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Phone Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
      routes: <String, WidgetBuilder>{
        '/HomeScreen': (BuildContext context) => new MainScreen()
      },
    );
  }
}

class MainScreen extends StatefulWidget {

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  var loggedIn=false;
  var hasAccount = false;
  @override
  void initState() {
    super.initState();
    loadSharedPref();
  }

  void loadSharedPref() async{
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      loggedIn = prefs.getBool('login') ?? false;
      hasAccount = prefs.getBool('exist') ?? false;
    });
  }


  @override
  Widget build(BuildContext context) {
    loadSharedPref();
    return loggedIn? HomePage(account : hasAccount ): LoginPage();
  }


}