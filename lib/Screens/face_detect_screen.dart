// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
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
import 'package:http/http.dart' as http;

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

  final _auth = FirebaseAuth.instance;

  // Face detection values
  File? image;
  bool boundedImage = false;
  List<Face>? _faces;
  bool isLoading = false;
  ui.Image? _image;
  final picker = ImagePicker();

  // face recog
  final String serverURL = 'http://13.71.106.166/';

  // editing controllers
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String verificationId = "";

  String otpPin = "";

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
              : () {
                },
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
      final image =
          await ImagePicker().pickImage(source: source, imageQuality: 20);
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
            boundedImage = true;
          }));

      if (faces.isNotEmpty) {
        Fluttertoast.showToast(msg: "Face Detected!");
        try {
          final response = await uploadImageToContainer(image!.path, serverURL);
          // Fluttertoast.showToast(msg: response.toString());
          Fluttertoast.showToast(msg: "Success");
        } catch (e) {
          Fluttertoast.showToast(msg: e.toString());
        }
      } else {
        Fluttertoast.showToast(msg: "No face found");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future uploadImageToContainer(filepath, url) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('file', filepath));

    http.StreamedResponse response = await request.send();
    log("Data: ${response.statusCode}");

    var responseBytes = await response.stream.toBytes();
    var responseString = utf8.decode(responseBytes);
    print('\n\n');
    print('RESPONSE WITH HTTP');
    log("Data: ${responseString}");
    print('\n\n');
    return responseString;
  }

  Future<void> fetchOtp() async {
    String number = "+91${phoneController.text}";
    await _auth.verifyPhoneNumber(
        phoneNumber: number,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          Fluttertoast.showToast(msg: e.message.toString());
        },
        codeSent: (String verificationId, int? resendToken) async {
          this.verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verifyId) {});
  }

  void verifyOtp() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otpController.text);
      await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "provider-already-linked":
          print("The provider has already been linked to the user.");
          break;
        case "invalid-credential":
          print("The provider's credential is not valid.");
          break;
        case "credential-already-in-use":
          print("The account corresponding to the credential already exists, "
              "or is already linked to a Firebase User.");
          break;
        default:
          print("Unknown error.");
      }
    }
  }
}