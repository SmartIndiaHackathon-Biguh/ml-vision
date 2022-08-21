import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScanModel {
  // Child data
  String? childName;
  int? childAge;
  String? childGender;
  String? childLocation;
  String? gdeNo;
  String? gdeDate;
  int? childPhone;

  //userData
  GeoPoint? userPosition;
  DateTime? scanTime;
  String? userName;
  int? userPhone;
  String? userEmail;

  ScanModel(
      {
      this.childName,
      this.childAge,
      this.childGender,
      this.childLocation,
      this.gdeNo,
      this.gdeDate,
      this.childPhone,
      this.userName,
      this.userPhone,
      this.userEmail,
      this.userPosition,
      this.scanTime});

  // get data from server
  factory ScanModel.fromMap(map) {
    return ScanModel(
      childName: map['childName'],
      childAge: map['childAge'],
      childGender: map['childGender'],
      childLocation: map['childLocation'],
      gdeNo: map['gdeNo'],
      gdeDate: map['gdeDate'],
      childPhone: map['childPhone'],
      userPosition: map['userPosition'],
      scanTime: map['scanTime'],
      userName: map['userName'],
      userPhone: map['userPhone'],
      userEmail: map['userEmail'],
    );
  }

  // send data to server
  Map<String, dynamic> toMap() {
    return {
      'childName': childName,
      'childAge': childAge,
      'childGender': childGender,
      'childLocation': childLocation,
      'gdeNo': gdeNo,
      'gdeDate': gdeDate,
      'childPhone': childPhone,
      'userPosition': userPosition,
      'scanTime': scanTime,
      'userName': userName,
      'userPhone': userPhone,
      'userEmail': userEmail,
    };
  }
}
