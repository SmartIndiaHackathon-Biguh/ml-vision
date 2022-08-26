import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sih_login/Services/list_services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'login_screen.dart';

class ListAppPolice extends StatefulWidget {
  const ListAppPolice({Key? key}) : super(key: key);

  @override
  State<ListAppPolice> createState() => _ListAppPoliceState();
}

class _ListAppPoliceState extends State<ListAppPolice> {
  final childrenCollection =
      FirebaseFirestore.instance.collection('scan-details');
  int numberChildren = 0;
  Timer? timer;
  List<Widget> myList = [Text('Loading')];

  @override
  void initState() {
    getListViewPolice();
    timer =
        Timer.periodic(Duration(seconds: 15), (Timer t) => getListViewPolice());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  //func get an entire list of all people
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Toddlert'),
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  logOut(context);
                },
                child: Icon(Icons.more_vert),
              )),
        ],
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 40,
              width: screenWidth,
              child: Center(
                child: Text(
                  'Total children pings: $numberChildren',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              // child: ListView(
              //   children: myList,
              child: ListView.builder(
                  itemCount: numberChildren,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return myList[index];
                  }),
            ),
          ]),
    );
  }

  Future<void> getListViewPolice() async {
    final _collection = await childrenCollection.get();
    final allData = _collection.docs.map((e) => e.data()).toList();
    allData.sort((a, b) {
      return b['scanTime'].compareTo(a['scanTime']);
    });
    setState(() {
      numberChildren = allData.length;
    });

    setState(() {
      myList = allData
          .map((e) => childInfoView(
              childName: e['childName'],
              childLocation: e['childLocation'],
              userPhone: e['userPhone'],
              userName: e['userName'],
              scanTime: e['scanTime'],
              userPosition: e['userPosition']))
          .toList();
    });
  }

  Widget childInfoView(
      {required String childName,
      required String childLocation,
      required int userPhone,
      required String userName,
      required Timestamp scanTime,
      required GeoPoint userPosition}) {
    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10)
          ]),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  childName,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Text(
                  childLocation,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic),
                ),
                Text(
                  userName.toString(),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$userPhone',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic),
                )
              ],
            ),
            IconButton(
              onPressed: () {
                _launcUrl(userPosition.latitude, userPosition.longitude);
              },
              icon: Icon(Icons.map),
              iconSize: 50,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launcUrl(double lat, double long) async {
    final Uri url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$long');
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
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
