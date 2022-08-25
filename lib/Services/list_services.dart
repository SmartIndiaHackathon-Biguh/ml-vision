import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class ListServices {
  List<Category> _categories = [];
  List<Category> getCategories() {
    return _categories;
  }

   getFromFirestore() async {
    var db = FirebaseFirestore.instance;
    // CollectionReference _collection = _instance!.collection('victims');
    // QuerySnapshot querySnapshot = await _instance!.collection('victims').get();
    //final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    await db.collection("victims").get().then((event) {
      var allData;
      for (var doc in event.docs) {
        allData = doc.data()['name'];
        print(allData);
      }
    });
  }
}
