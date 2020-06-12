import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gymnasium/screen/login.dart';
import 'package:gymnasium/screen/qrPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screen/SplashScreen.dart';
import 'screen/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final MaterialColor blackColor = const MaterialColor(
    0xFF000000,
    const <int, Color>{
      50: const Color(0xFF000000),
      100: const Color(0xFF000000),
      200: const Color(0xFF000000),
      300: const Color(0xFF000000),
      400: const Color(0xFF000000),
      500: const Color(0xFF000000),
      600: const Color(0xFF000000),
      700: const Color(0xFF000000),
      800: const Color(0xFF000000),
      900: const Color(0xFF000000),
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymQ',
      theme: ThemeData(
        primarySwatch: blackColor,
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

  static final Firestore _db = Firestore.instance;
  var loggedIn=false;
  var hasAccount = false;
  var phone = 'nill';
  var apptTaken = false;
  var appt = false;
  var docID = 'nill';
  @override
  void initState() {
    super.initState();
    loadSharedPref();
    loadApptDB();
  }

  void loadApptDB() async{
    final prefs = await SharedPreferences.getInstance();
    phone = prefs.getString('phone')??'nill';
    appt = prefs.getBool('appointment') ?? false;
    if(phone != 'nill') {
      final snapShot = await _db.collection('user').document(phone).get();
      if (snapShot.exists) {
        setState(() {
          apptTaken = snapShot.data['appointment'] ?? false;
          if (apptTaken != appt)
            appt = apptTaken;
        });
      }
      _db.collection('user').document(phone)
          .snapshots()
          .listen((result) async {   // Listens to update in appointment collection

        await prefs.setBool('appointment', result.data['appointment']);

      });
    }
  }


  void loadSharedPref() async{
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      loggedIn = prefs.getBool('login') ?? false;
      hasAccount = prefs.getBool('exist') ?? false;
      phone = prefs.getString('phone')??'nill';
      appt = prefs.getBool('appointment') ?? false;
      docID = prefs.getString('uniqueID') ?? 'nill';
    });

  }


  @override
  Widget build(BuildContext context) {
    loadSharedPref();
    return loggedIn? appt? QRPage(docID: docID,): HomePage(account : hasAccount ): LoginPage();
  }


}