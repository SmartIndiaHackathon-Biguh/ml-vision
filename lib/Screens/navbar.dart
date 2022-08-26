import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:sih_login/Models/user_model.dart';
import 'package:sih_login/Screens/face_detect_screen.dart';
import 'package:sih_login/Screens/google_maps.dart';
import 'package:sih_login/Screens/home_police.dart';
import 'package:sih_login/Screens/home_screen.dart';
import 'package:sih_login/Screens/ngo_screen.dart';
import 'package:sih_login/Screens/translate_text.dart';

class BottomNavBar extends StatefulWidget {
  BottomNavBar({Key? key}) : super(key: key);
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
 User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  final navigationKey = GlobalKey<CurvedNavigationBarState>();
  int index = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

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
    final screens = [
      loggedInUser.firstName=='dhruv'? ListAppPolice(): ListApp(),
      FaceDetectScreen(),
      TranslatePage(),
      PoliceScreen(),
      ngoScreen(),
    ];
    final items = <Widget>[
      const Icon(Icons.home, size: 30),
      const Icon(Icons.camera_alt, size: 30),
      const Icon(Icons.translate, size: 30),
      const Icon(Icons.map, size: 30),
      const Icon(Icons.settings, size: 30),
    ];
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: screens,
      ),
      extendBody: true,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          iconTheme: IconThemeData(color: Colors.black),
        ),
        child: CurvedNavigationBar(
          buttonBackgroundColor: Colors.white,
          color: Colors.blueAccent,
          backgroundColor: Colors.transparent,
          height: 60,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 500),
          index: index,
          items: items,
          onTap: (index) => setState(() => this.index = index),
        ),
      ),
    );
  }
}
