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
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

import '../../Screens/face_detect_screen.dart';

class DynamicDialog extends StatefulWidget {
  DynamicDialog({required this.title});

  final String title;

  @override
  _DynamicDialogState createState() => _DynamicDialogState();
}

class _DynamicDialogState extends State<DynamicDialog> {
  late String _buttonTitle;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  final _auth = FirebaseAuth.instance;

  String verificationId = "";

  String otpPin = "";
  String countryCode = "+91";
  bool otpSent = false;
//   String otpMessage = "Hi";

  @override
  void initState() {
    _buttonTitle = "Enter Phone Number";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final phoneNoField = TextFormField(
      autofocus: false,
      controller: phoneController,
      keyboardType: TextInputType.phone,
      onSaved: (newValue) => phoneController.text = newValue!,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.phone),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Phone Number",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final otpTextFieled1 = OtpTextField(
      numberOfFields: 6,
      borderColor: Color(0xFF512DA8),
      //set to true to show as box or false to show as dash
      showFieldAsBox: true,
      //runs when a code is typed in
      onCodeChanged: (String code) {
        //handle validation or checks here
      },
      //runs when every textfield is filled
      onSubmit: (String verificationCode) {
        otpController.text = verificationCode;
      }, // end onSubmit
    );

    return AlertDialog(
      title: Text("OTP Verification"),
      actions: <Widget>[
        phoneNoField,
        SizedBox(
          height: 10,
        ),
        if (otpSent)
          SizedBox(
            height: 20,
            child: Text(
              "Please Enter the OTP",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
        if (otpSent) otpTextFieled1,
        SizedBox(
          height: 10,
        ),
        Material(
          elevation: 5,
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(30),
          child: MaterialButton(
              padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
              minWidth: MediaQuery.of(context).size.width,
              onPressed: () {
                otpSent ? verifyOtp() : fetchOtp();
                // ignore: prefer_const_declarations
                final newText = 'Verify OTP';
                setState(() {
                  _buttonTitle = newText;
                  otpSent = true;
                });
              },
              child: Text(
                _buttonTitle,
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              )),
        ),
      ],
    );
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
      final testing = await FirebaseAuth.instance.currentUser
          ?.linkWithCredential(credential);
      if (testing.toString().isNotEmpty) {
        log("Data3 ${testing}");
        FaceDetectScreen.otpVerified = true;
        FaceDetectScreen.userPhoneNumber = int.parse(phoneController.text);
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "provider-already-linked":
          print("The provider has already been linked to the user.");
          FaceDetectScreen.otpVerified = true;
          FaceDetectScreen.userPhoneNumber = int.parse(phoneController.text);
          Navigator.pop(context);
          break;
        case "invalid-credential":
          Fluttertoast.showToast(
              msg: "The provider's credential is not valid.");
          print("The provider's credential is not valid.");
          break;
        case "credential-already-in-use":
          Fluttertoast.showToast(
              msg:
                  "The account corresponding to the credential already exists, "
                  "or is already linked to a Firebase User. Please use a different phone number.");
          print("The account corresponding to the credential already exists, "
              "or is already linked to a Firebase User.");
          break;
        default:
          Fluttertoast.showToast(msg: "Please try again.");
          print("Unknown error.");
      }
    }
  }
}
