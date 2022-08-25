import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sih_login/Models/user_model.dart';
import 'package:sih_login/Screens/login_screen.dart';
// ignore_for_file: prefer_const_constructors

class ChildInfoScreen extends StatefulWidget {
  ChildInfoScreen(
      {Key? key,
      required this.childName,
      required this.childAge,
      required this.childGender,
      required this.childLocation,
      required this.childContactNumber,
      required this.childImage,
      required this.audioUrl})
      : super(key: key);

  String childName;
  int childAge;
  String childGender;
  int childContactNumber;
  String childLocation;
  String childImage;
  String audioUrl;
  final player = AudioPlayer();

  @override
  State<ChildInfoScreen> createState() => _ChildInfoScreenState();
}

class _ChildInfoScreenState extends State<ChildInfoScreen> {
  String playing = 'Paused';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Child Information"),
        centerTitle: true,
      ),
      body: Center(
          child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          // ignore: prefer_const_literals_to_create_immutables
          children: <Widget>[
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.40,
                child: Image.network(widget.childImage)),
            Text(
              widget.childName,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Age: ${widget.childAge} Gender: ${widget.childGender}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  fontSize: 15),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "Contact Number: ${widget.childContactNumber}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  fontSize: 15),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "Native: ${widget.childLocation}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  fontSize: 15),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                if (playing == 'Paused') {
                  await widget.player.setSourceUrl(widget.audioUrl);
                  await widget.player.resume();
                  setState(() async {
                    playing = 'Playing';
                  });
                } else {
                  await widget.player.pause();

                  setState(() async {
                    playing = 'Paused';
                  });
                }
              },
              child: Text('Audio ${playing}'),
            ),
          ],
        ),
      )),
    );
  }
}
