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
  var timeListAgain = <TimeDetails>[];
  TimeDetails timeDetails,finalTimeDetail;


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

    shopList = <ShopDetails>[];
    await _db
        .collection('shop details')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) async {
        shopList.add(new ShopDetails(id: f.data['id'], name:f.data['name'],owner: f.data['owner'],phone: f.data['phone']));
      });
    });
  }

  void loadShopTiming(shop) async{

    timeList = <TimeDetails>[];

    await _db
        .collection('shop details').document(shop.id).collection('time').orderBy('start')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) {
        if(f.data['count']<10)
          timeList.add(new TimeDetails(count: f.data['count'],end: f.data['end'],start: f.data['start'],id: f.documentID));
      });
    });
  }

  Future<void> loadShopTimingAgain(shop,sTime,doc) async{

    var snapShot = await _db.collection('shop details').document(shop.id).collection('time').document(doc).get();

    finalTimeDetail = new TimeDetails(id: snapShot.documentID,end: snapShot.data['end'],start: snapShot.data['start'],count: snapShot['count']);
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

  void bookSlot() async{
    /*
    TODO: push with Named in navigator for QR code generation
     */
    await loadShopTimingAgain(shopDetails,timeDetails.start,timeDetails.id);
    print('asd: ${finalTimeDetail.start}');
    if(finalTimeDetail.count<10){ // do when there is time slot left
      var docID = await FireStoreClass.createAppt(phoneNo: phoneNo,shopName: shopDetails.name,sTime: timeDetails.start,eTime: timeDetails.end,shopID: shopDetails.id,timeDoc: timeDetails.id,count: timeDetails.count);

      Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));

    }


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
                loadShopTiming(shopDetails);
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