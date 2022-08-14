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
import 'package:sih_login/Modules/FaceDetection/FacePainter.dart';
// ignore_for_file: prefer_const_constructors

class FaceDetectScreen extends StatefulWidget {
  FaceDetectScreen({Key? key}) : super(key: key);

  @override
  State<FaceDetectScreen> createState() => _FaceDetectScreenState();
}

class _FaceDetectScreenState extends State<FaceDetectScreen> {
  bool isAnalyse = false;

  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  // Face detection values
  File? image;
  bool boundedImage = false;
  File? _imageFile;
  List<Face>? _faces;
  bool isLoading = false;
  ui.Image? _image;
  final picker = ImagePicker();
  var imageFile;

  Widget buildButton({
    required String title,
    required VoidCallback? onClick,
  }) =>
      Material(
        elevation: 5,
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(30),
        child: MaterialButton(
          height: 50,
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width * 0.55,
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
        color: isAnalyse ? Colors.indigo.shade900 : Colors.grey,
        borderRadius: BorderRadius.circular(30),
        child: MaterialButton(
          height: 50,
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width * 0.75,
          onPressed: image == null
              ? () {
                  Fluttertoast.showToast(msg: "Please Select an Image");
                }
              : faceDetectionFunction,
          child: Text(
            "Analyse Image",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );

  Widget DisplayImage() {
    return image == null
        ? SizedBox(
            height: 150,
            child: Image.asset(
              "assets/logo.png",
              fit: BoxFit.contain,
            ))
        : selectedImage();
  }

  Widget selectedImage() {
    return !boundedImage
        ? Image.file(
            image!,
            width: MediaQuery.of(context).size.width * 0.70,
            height: MediaQuery.of(context).size.height * 0.50,
            fit: BoxFit.contain,
          )
        : SizedBox(
            width: MediaQuery.of(context).size.width * 0.70,
            height: MediaQuery.of(context).size.height * 0.50,
            child: Center(
                child: FittedBox(
              child: SizedBox(
                width: (_image?.width.toDouble()),
                height: _image?.height.toDouble(),
                child: CustomPaint(
                  painter: FacePainter(_image!, _faces!),
                ),
              ),
            )));
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
      isLoading = true;
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final temporaryImage = File(image.path);
      setState(() {
        this.image = temporaryImage;
        boundedImage = false;
        isAnalyse = true;
        isLoading = false;
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
      faceDetector.close();

      final data = await image?.readAsBytes();
      await decodeImageFromList(data!).then((value) => setState(() {
            _image = value;
            _faces = faces;
            imageFile = image;
            boundedImage = true;
          }));

      if (faces.isNotEmpty) {
        Fluttertoast.showToast(msg: "Face Detected!");
      } else {
        Fluttertoast.showToast(msg: "No face found");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
