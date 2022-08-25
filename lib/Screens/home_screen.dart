import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sih_login/Services/list_services.dart';

import '../Models/user_model.dart';

class ListApp extends StatefulWidget {
  const ListApp({Key? key}) : super(key: key);

  @override
  State<ListApp> createState() => _ListAppState();
}

class _ListAppState extends State<ListApp> {
  final childrenCollection = FirebaseFirestore.instance.collection('victims');
  int numberChildren = 0;

  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  List<Widget> myList = [Text('Loading')];

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
    if (loggedInUser.admin == 1) {
      getListViewAdmin();
    } else {
      getListView();
    }
      
  }

  //func get an entire list of all people
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Toddlert'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 30,
            ),
            SizedBox(
              height: 40,
              width: screenWidth,
              child: Center(
                child: Text(
                  'Total missing children : $numberChildren',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: myList,
              ),
            ),
          ]),
    );
  }

  Future<void> getListView() async {
    final _collection = await childrenCollection.get();
    final allData = _collection.docs.map((e) => e.data()).toList();
    setState(() {
      numberChildren = allData.length;
    });

    setState(() {
      myList = allData
          .map((e) => childInfoView(
              childName: e['name'],
              childGender: e['gender'],
              imgUrl: e['ImageURl'],
              childAge: e['age']))
          .toList();
    });
  }

  Future<void> getListViewAdmin() async {
    final scanCollection =
        FirebaseFirestore.instance.collection('scan-details');
    final collection = await scanCollection.get();
    final allData = collection.docs.map((e) => e.data()).toList();
    setState(() {
      numberChildren = allData.length;
    });

      setState(() {
      myList = allData
          .map((e) => childInfoView(
              childName: e['childName'],
              childGender: e['userName'],
              imgUrl: e['childImage'],
              childAge: e['userPhone']))
          .toList();
    });
    
  }

  Widget childInfoView(
      {required String childName,
      required String childGender,
      required String imgUrl,
      required int childAge}) {
    return ListTile(
      visualDensity: VisualDensity(vertical: 2),
      leading: SizedBox(
        child: Image.network(
          imgUrl,
          fit: BoxFit.contain,
        ),
        height: 200,
      ),
      title: Text(
        childName,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        "Gender: $childGender  |   Age: $childAge",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
