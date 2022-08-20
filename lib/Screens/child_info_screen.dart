// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:sih_login/Models/user_model.dart';
// import 'package:sih_login/Screens/login_screen.dart';
// // ignore_for_file: prefer_const_constructors

// class ChildInfoScreen extends StatefulWidget {
//   ChildInfoScreen({Key? key}) : super(key: key);

//   String childName;
//   String childAge;
//   String childGender;
//   String childContactNumber;
//   String childLocation;

//   @override
//   State<ChildInfoScreen> createState() => _ChildInfoScreenState();
// }

// class _ChildInfoScreenState extends State<ChildInfoScreen> {
//   User? user = FirebaseAuth.instance.currentUser;
//   UserModel loggedInUser = UserModel();

//   @override
//   void initState() {
//     super.initState();
//     FirebaseFirestore.instance
//         .collection('users')
//         .doc(user!.uid)
//         .get()
//         .then((value) {
//       loggedInUser = UserModel.fromMap(value.data());
//       setState(() {});
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Welcome"),
//         centerTitle: true,
//       ),
//       body: Center(
//           child: Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: <Widget>[
//             SizedBox(
//               height: 150,
//               child: Image.asset(
//                 "assets/logo.png",
//                 fit: BoxFit.contain,
//               ),
//             ),
//             Text(
//               "TEST SCREEN 2",
//               style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blueAccent,
//                   fontSize: 20),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Text(
//               "${loggedInUser.firstName} ${loggedInUser.lastName}",
//               style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blueAccent,
//                   fontSize: 15),
//             ),
//             Text(
//               "${loggedInUser.email}",
//               style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blueAccent,
//                   fontSize: 15),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//           ],
//         ),
//       )),
//     );
//   }
// }
