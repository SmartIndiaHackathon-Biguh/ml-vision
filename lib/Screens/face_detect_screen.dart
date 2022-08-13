import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sih_login/Models/user_model.dart';
import 'dart:ui' as ui;
// ignore_for_file: prefer_const_constructors

class FaceDetectScreen extends StatefulWidget {
  FaceDetectScreen({Key? key}) : super(key: key);

  @override
  State<FaceDetectScreen> createState() => _FaceDetectScreenState();
}

class _FaceDetectScreenState extends State<FaceDetectScreen> {
  VoidCallback? analyseFunc = null;
  bool isAnalyse = false;

  File? image;

  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  // Face detector options

  Widget buildButton({
    required String title,
    required VoidCallback? onClick,
  }) =>
      Material(
        elevation: 5,
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(30),
        child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width * 0.65,
          onPressed: onClick,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );

  Widget analyseButton() => Material(
        elevation: 5,
        color: isAnalyse ? Colors.amberAccent : Colors.grey,
        borderRadius: BorderRadius.circular(30),
        child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: analyseFunc,
          child: Text(
            "Analyse Image",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );

  Widget DisplayImage() {
    return image != null
        ? Image.file(
            image!,
            width: MediaQuery.of(context).size.width * 0.70,
            height: MediaQuery.of(context).size.height * 0.50,
            fit: BoxFit.contain,
          )
        : SizedBox(
            height: 150,
            child: Image.asset(
              "assets/logo.png",
              fit: BoxFit.contain,
            ),
          );
  }

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
    return AbsorbPointer(
        absorbing: false,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Recognise Child"),
            centerTitle: true,
          ),
          body: Center(
              child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                DisplayImage(),
                SizedBox(
                  height: 20,
                ),
                buildButton(
                    onClick: () {
                      pickImage(ImageSource.camera);
                    },
                    title: "Open Camera"),
                SizedBox(
                  height: 20,
                ),
                buildButton(
                    onClick: () {
                      pickImage(ImageSource.gallery);
                    },
                    title: "Open Gallery"),
                SizedBox(
                  height: 40,
                ),
                analyseButton(),
              ],
            ),
          )),
        ));
  }

  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final temporaryImage = File(image.path);
      setState(() {
        this.image = temporaryImage;
        isAnalyse = true;
        this.analyseFunc = faceDetectionFunction;
      });
    } on PlatformException catch (e) {
      Fluttertoast.showToast(msg: e.message.toString());
    }
  }

  Future faceDetectionFunction() async {
    try {
      final inputImage = InputImage.fromFile(image!);
      final options = FaceDetectorOptions();
      final faceDetector = FaceDetector(options: options);

      final List<Face> faces = await faceDetector.processImage(inputImage);

      for (Face face in faces) {
        final Rect boundingBox = face.boundingBox;

        final double? rotX =
            face.headEulerAngleX; // Head is tilted up and down rotX degrees
        final double? rotY =
            face.headEulerAngleY; // Head is rotated to the right rotY degrees
        final double? rotZ =
            face.headEulerAngleZ; // Head is tilted sideways rotZ degrees

      }

      faceDetector.close();

      if (faces.isNotEmpty) {
        Fluttertoast.showToast(msg: faces[0].toString());
      } else {
        Fluttertoast.showToast(msg: "No face found");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}


