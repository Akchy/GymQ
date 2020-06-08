

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FireStoreClass {
  static final Firestore _db = Firestore.instance;
  static final userCollection = 'user';

  static Future<bool> checkUsername({phoneNo}) async{
    final snapShot = await _db.collection(userCollection).document(phoneNo).get();
    if(snapShot.exists) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', snapShot.data['name']);
      await prefs.setString('phone', snapShot.data['phone']);
      await prefs.setInt('age', snapShot.data['age']);
      return true;
    }
    return false;
  }

  static Future<void> regUser({name,phone,age}) async{
    await _db.collection(userCollection).document(phone).setData({
      'name': name,
      'phone':phone,
      'age':age,
      'appointment': 'nill',
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('phone', phone);
    await prefs.setInt('age', age);
    await prefs.setBool('exist', true);
    await prefs.setBool('login', true);

  }

}