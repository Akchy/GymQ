

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FireStoreClass {
  static final Firestore _db = Firestore.instance;
  static final userCollection = 'user';
  static final apptCollection = 'appointment';
  static final shopCollection = 'shop details';

  static Future<bool> checkUsername({phoneNo}) async{
    final snapShot = await _db.collection(userCollection).document(phoneNo).get();
    if(snapShot.exists) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', snapShot.data['name']);
      await prefs.setString('phone', snapShot.data['phone']);
      await prefs.setInt('age', snapShot.data['age']);
      await prefs.setBool('appointment', snapShot.data['appointment']);
      await prefs.setString('uniqueID', snapShot.data['apptID']);



      return true;
    }
    return false;
  }

  static Future<String> createAppt({phoneNo,shopName,sTime,eTime,shopID,timeDoc,count}) async{
    DocumentReference ref = await _db.collection(apptCollection)
        .add({
      'userPhone':phoneNo,
      'shopName':shopName,
      'sTime':sTime,
      'eTime':eTime,
    });
    _db.collection(userCollection).document(phoneNo).updateData({
      'appointment':true,
      'apptID':ref.documentID
    });
    _db.collection(shopCollection).document(shopID).collection('time').document(timeDoc).updateData({
      'count':count+1
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uniqueID', ref.documentID);
    print('akchy ${ref.documentID}');
    await prefs.setBool('appointment', true);
    return ref.documentID;
  }

  static Future<void> regUser({name,phone,age}) async{
    await _db.collection(userCollection).document(phone).setData({
      'name': name,
      'phone':phone,
      'age':age,
      'appointment': false,
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('phone', phone);
    await prefs.setInt('age', age);
    await prefs.setBool('exist', true);
    await prefs.setBool('login', true);

  }

}