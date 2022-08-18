import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sih_login/Models/user_model.dart';
import 'package:sih_login/Screens/login_screen.dart';
// ignore_for_file: prefer_const_constructors


// DS AURGAAAAAAAAAAAAAAg

//Anurag code

//part a
// make a get request to db, return list of missing children objects
// return for each child -> image, name, age, gender, location

//fist steps
//From the root of your Flutter project,run this command
flutter pub add cloud_firestore
//rebuild your Flutter application
flutter run
//initialize db
db = FirebaseFirestore.instance;
//read data
await db.collection("users").get().then((event) {
  for (var doc in event.docs) {
    print("${doc.id} => ${doc.data()}");
  }
});
//doc data has the dictionary value

//partb
//merging 2 dbs
// Add a new document with a generated ID
// TODO MERGE doc.data() and user data
//idk where user data is
db.collection("police_side_dual_db").add(doc.data()).then((DocumentReference doc) =>
    print('DocumentSnapshot added with ID: ${doc.id}'));


class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome"),
        centerTitle: true,
      ),
      body: Center(
          child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 150,
              child: Image.asset(
                "assets/logo.png",
                fit: BoxFit.contain,
              ),
            ),
            Text(
              "Welcome Back",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "${loggedInUser.firstName} ${loggedInUser.lastName}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  fontSize: 15),
            ),
            Text(
              "${loggedInUser.email}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  fontSize: 15),
            ),
            SizedBox(
              height: 20,
            ),
            ActionChip(
                label: Text("LogOut"),
                onPressed: () {
                  logOut(context);
                })
          ],
        ),
      )),
    );
  }

  Future<void> logOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()));
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message.toString());
    }
  }
}
