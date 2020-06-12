import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRPage extends StatefulWidget{

  final String docID;

  const QRPage({Key key,this.docID}):super(key: key);
  @override
  _QRPageState createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  var name, shopName, sTime, eTime, docID;

  static final Firestore _db = Firestore.instance;
  @override
  initState(){
    super.initState();
    loadSharedPref();
    docID = widget.docID;
  }



  void loadSharedPref() async{
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString('name') ?? 'nill';

    });

    print('Xperion $docID');
    final snapShot = await _db.collection('appointment').document(docID).get();
    setState(() {
      shopName = snapShot.data['shopName'] ?? 'nill';
      sTime = snapShot.data['sTime'] ?? 0;
      eTime = snapShot.data['eTime'] ?? 0;

    });

  }


  Future<void> _logout() async {
    try {
      // signout code
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      prefs.clear();
    } catch (e) {
      print(e.toString());
    }
  }

  void _refresh() {
    Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment'),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap:_refresh,
                child: Icon(
                    Icons.refresh
                ),
              )
          ),
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: _logout,
                child: Icon(
                    Icons.exit_to_app
                ),
              )
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            QrImage(
              data: docID,
              version: 3,
              size: 300,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
              gapless: true,
              errorStateBuilder: (cxt, err) {
                return Container(
                  child: Center(
                    child: Text(
                      "Uh oh! Something went wrong... $err",
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
            Text('Hey $name, your booking at $shopName is successfull from $sTime - $eTime'),
          ],
        ),
      ),
    );
  }
}