import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gymnasium/firebaseDB/firebaseDB.dart';
import 'package:gymnasium/model/shopDetails.dart';
import 'package:gymnasium/model/timeDetails.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget{

  final bool account;

  const HomePage({Key key,this.account}):super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();

  ShopDetails shopDetails;
  var timeList = <TimeDetails>[];
  TimeDetails timeDetails;

  var shopList = <ShopDetails>[];
  Firestore _db = Firestore.instance;
  var phoneNo,fullName,userAge;

  @override
  void initState() {
    super.initState();
    loadSharedPref();
    loadShopDetails();
  }

  void loadShopDetails() async{
    await _db
        .collection('shop details')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) async {
        shopList.add(new ShopDetails(id: f.data['id'], name:f.data['name'],owner: f.data['owner'],phone: f.data['phone']));
      });
    });

    shopList.forEach((onew) => print('xperion ${onew.owner}'));
  }

  void loadShopTiming(documentID) async{

    await _db
        .collection('shop details').document(documentID).collection('time').orderBy('start')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) {
        timeList.add(new TimeDetails(count: f.data['count'],end: f.data['end'],start: f.data['start']));
      });
    });
  }


  void loadSharedPref() async{
    final prefs = await SharedPreferences.getInstance();
    phoneNo = prefs.getString('phone') ?? 'nill';
    fullName = prefs.getString('name') ?? 'nill';
    userAge = prefs.getInt('age') ?? 0;
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

  void _register() async{
    var name = _nameController.text.toString().trim();
    var age = int.parse(_ageController.text.toString().trim());
    await FireStoreClass.regUser(name: name,phone: phoneNo,age: age);
    Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
  }

  void bookSlot() {
    print('$fullName has registered for ${shopDetails.id} Gym during the time ${timeDetails.start} - ${timeDetails.end}');
    /*TODO: check counter from time subcollection is less that 10, create new collection Appointment with required details
    TODO: push with


     */
  }

  Widget accountExist(){ // Widget for account already existing
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          DropdownButton<ShopDetails>(
            hint:  Text("Select Shop"),
            value: shopDetails,
            onChanged: (ShopDetails value) {
              setState(() {
                shopDetails = value;
                loadShopTiming(shopDetails.id);
              });
            },
            items: shopList.map((ShopDetails user) {
              return  DropdownMenuItem<ShopDetails>(
                value: user,
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 10,),
                    Text(
                      user.name,
                      style:  TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          DropdownButton<TimeDetails>(
            hint:  Text("Select Time"),
            value: timeDetails,
            onChanged: (TimeDetails value) {
              setState(() {
                timeDetails = value;
              });
            },
            items: timeList.map((TimeDetails time) {
              return  DropdownMenuItem<TimeDetails>(
                value: time,
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 10,),
                    Text(
                      '${time.start} - ${time.end}',
                      style:  TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          RaisedButton(
            child: Text('Book Slot'),
            onPressed: bookSlot,
          )
        ],
      )
    );
  }

  Widget newAccount(){
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
                hintText: 'John Doe',
                labelText: 'Full Name'
            ),
          ),

          TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
                hintText: '18+',
                labelText: 'Age'
            ),
          ),
          RaisedButton(
            child: Text('Register'),
            onPressed: _register,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.account?Text('GymQ'):Text('User Details'),
        actions: <Widget>[
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
      body: widget.account?accountExist():newAccount(),
    );
  }
}