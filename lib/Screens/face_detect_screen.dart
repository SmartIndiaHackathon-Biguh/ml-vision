import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sih_login/Models/child_user_model.dart';
import 'package:sih_login/Models/user_model.dart';
import 'dart:ui' as ui;
import 'package:sih_login/Modules/FaceDetection/FacePainter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:sih_login/Screens/child_info_screen.dart';
import '../Modules/FaceDetection/DynamicDialog.dart';
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: prefer_const_constructors

class FaceDetectScreen extends StatefulWidget {
  FaceDetectScreen({Key? key}) : super(key: key);
  static bool otpVerified = false;
  static int userPhoneNumber = 0;

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
  List<Face>? _faces;
  bool isLoading = false;
  ui.Image? _image;
  final picker = ImagePicker();

  // face recog
  final String serverURL = 'http://13.71.107.179/';

  var childImage;

  // Child Details
  String? childName;
  int? childAge;
  String? childGender;
  String? childLocation;
  String? gdeNo;
  String? gdeDate;
  int? childPhone;

  // User info
  Position? userPosition;

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
          resizeToAvoidBottomInset: false,
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
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildButton(
                        onClick: () {
                          pickImage(ImageSource.gallery);
                        },
                        title: "Open Gallery"),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.02,
                    ),
                    buildButton(
                        onClick: () {
                          pickImage(ImageSource.camera);
                        },
                        title: "Open Camera"),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                analyseButton(),
                SizedBox(
                  height: 50,
                ),
              ],
            ),
          )),
        ));
  }

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
          minWidth: MediaQuery.of(context).size.width * 0.35,
          onPressed: onClick,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
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
              : () async {
                  await showOtpDialog();
                  if (FaceDetectScreen.otpVerified) faceDetectionFunction();
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

  Future showOtpDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return DynamicDialog(title: 'OTP Verification');
        });
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
          if (childAge != null) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => ChildInfoScreen(
                    childName: childName!,
                    childAge: childAge!,
                    childGender: childGender!,
                    childLocation: childLocation!,
                    childContactNumber: childPhone!)));
          } else {
            Fluttertoast.showToast(msg: "Child Not Found.");
          }
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

    // var responseBytes = await response.stream.toBytes();
    // var responseString = utf8.decode(responseBytes);
    // var responseString2 = jsonDecode(responseString);
    var responseString = await response.stream.bytesToString();
    final decodedMap = json.decode(responseString);
    if ((decodedMap['gdeNo'].toString().isNotEmpty)) {
      childName = decodedMap['name'];
      childAge = decodedMap['age'];
      childGender = decodedMap['gender'];
      childLocation = "${decodedMap['District']}, ${decodedMap['State']}";
      childPhone = decodedMap['mobile'];
      gdeDate = decodedMap['gdeDate'];
      gdeNo = decodedMap['gdeNo'];
      createChildScan();
      return responseString;
    }
    return null;
  }

  Future createChildScan() async {
    final doc_id = generateRandomString(15);
    final scanDbInst =
        FirebaseFirestore.instance.collection('scan-details').doc(doc_id);

    final scanTime = DateTime.now();

    userPosition = await _determinePosition();

    final userGeoPoint =
        GeoPoint(userPosition!.latitude, userPosition!.longitude);

    ScanModel newScan = ScanModel();

    newScan.childName = childName;
    newScan.childAge = childAge;
    newScan.childGender = childGender;
    newScan.childLocation = childLocation;
    newScan.childPhone = childPhone;
    newScan.gdeDate = gdeDate;
    newScan.gdeNo = gdeNo;

    newScan.userName = "${loggedInUser.firstName} ${loggedInUser.lastName}";
    newScan.userEmail = loggedInUser.email;
    newScan.userPhone = FaceDetectScreen.userPhoneNumber;
    newScan.userPosition = userGeoPoint;
    newScan.scanTime = scanTime;

    await scanDbInst.set(newScan.toMap());
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  String generateRandomString(int len) {
    var r = math.Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }
}
