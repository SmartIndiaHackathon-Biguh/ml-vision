// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:sih_login/Screens/face_detect_screen.dart';
// import 'package:sih_login/Screens/home_screen.dart';
// import 'package:sih_login/Screens/registration_screen.dart';
// // ignore_for_file: prefer_const_constructors

// class PhoneScreen extends StatefulWidget {
//   PhoneScreen({Key? key}) : super(key: key);

//   @override
//   State<PhoneScreen> createState() => _PhoneScreenState();
// }

// class _PhoneScreenState extends State<PhoneScreen> {
//   final _formkey = GlobalKey<FormState>();

//   // editing controllers
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController otpController = TextEditingController();

//   String verificationId = "";

//   String otpPin = "";
//   String countryCode = "+91";

//   bool otp = false;
//   String otpMessage = "Hi";

//   // FIREBASE
//   final _auth = FirebaseAuth.instance;

//   @override
//   Widget build(BuildContext context) {
//     // email
//     final emailField = TextFormField(
//       autofocus: false,
//       controller: phoneController,
//       keyboardType: TextInputType.phone,
//       onSaved: (newValue) => phoneController.text = newValue!,
//       textInputAction: TextInputAction.next,
//       decoration: InputDecoration(
//           prefixIcon: Icon(Icons.mail),
//           contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
//           hintText: "Phone Number",
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//           )),
//     );

//     // password
//     final passwordField = TextFormField(
//       autofocus: false,
//       controller: otpController,
//       obscureText: true,
//       onSaved: (newValue) => otpController.text = newValue!,
//       textInputAction: TextInputAction.done,
//       decoration: InputDecoration(
//           prefixIcon: Icon(Icons.vpn_key),
//           contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
//           hintText: "Password",
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//           )),
//     );

//     // Login button
//     final loginButton = Material(
//       elevation: 5,
//       color: Colors.blueAccent,
//       borderRadius: BorderRadius.circular(30),
//       child: MaterialButton(
//         padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
//         minWidth: MediaQuery.of(context).size.width,
//         onPressed: () {
//           fetchOtp();
//         },
//         child: const Text(
//           "Login",
//           textAlign: TextAlign.center,
//           style: TextStyle(
//               fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );

//     final finalButton = Material(
//       elevation: 5,
//       color: Colors.blueAccent,
//       borderRadius: BorderRadius.circular(30),
//       child: MaterialButton(
//         padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
//         minWidth: MediaQuery.of(context).size.width,
//         onPressed: () {
//           verifyOtp();
//         },
//         child: Text(
//           otpMessage,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//               fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );

//     return Dialog(
//         backgroundColor: Colors.white,
//         child: Center(
//           child: SingleChildScrollView(
//               child: Container(
//             color: Colors.white,
//             child: Padding(
//               padding: const EdgeInsets.all(40.0),
//               child: Form(
//                   key: _formkey,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: <Widget>[
//                       SizedBox(
//                         height: 200,
//                         child: Image.asset(
//                           "assets/logo.png",
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                       SizedBox(
//                         height: 45,
//                       ),
//                       emailField,
//                       SizedBox(
//                         height: 10,
//                       ),
//                       passwordField,
//                       SizedBox(
//                         height: 20,
//                       ),
//                       loginButton,
//                       SizedBox(
//                         height: 15,
//                       ),
//                       finalButton,
//                       SizedBox(
//                         height: 15,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: <Widget>[
//                           Text("Don't have an account? "),
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) =>
//                                           RegistrationScreen()));
//                             },
//                             child: Text("SignUp",
//                                 style: TextStyle(
//                                     color: Colors.blue,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 15)),
//                           )
//                         ],
//                       )
//                     ],
//                   )),
//             ),
//           )),
//         ));
//   }

//   //login func
//   void signIn(String email, String password) async {
//     if (_formkey.currentState!.validate()) {
//       try {
//         await FirebaseAuth.instance
//             .signInWithEmailAndPassword(email: email, password: password)
//             .then((value) {
//           Fluttertoast.showToast(msg: "Login Successful!");

//           Navigator.of(context).pushReplacement(
//               MaterialPageRoute(builder: (context) => FaceDetectScreen()));
//         });
//       } on FirebaseAuthException catch (e) {
//         Fluttertoast.showToast(msg: e.message.toString());
//       }
//     }
//   }

//   Future<void> fetchOtp() async {
//     await _auth.verifyPhoneNumber(
//         phoneNumber: phoneController.text.toString(),
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           await _auth.signInWithCredential(credential);
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           Fluttertoast.showToast(msg: e.message.toString());
//         },
//         codeSent: (String verificationId, int? resendToken) async {
//           this.verificationId = verificationId;
//           setState(() {
//             otpMessage = "Hello";
//           });
//         },
//         codeAutoRetrievalTimeout: (String verifyId) {});
//   }

//   void verifyOtp() async {
//     PhoneAuthCredential cred = PhoneAuthProvider.credential(
//         verificationId: verificationId, smsCode: otpController.text);

//     await _auth.signInWithCredential(cred).then((value) {
//       Fluttertoast.showToast(msg: "Logged in");
//     });
//   }
// }

















  // Future<bool?> openDialog() => showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //           title: Text("Otp Verification"),
  //           content: SingleChildScrollView(
  //               child: Container(
  //             color: Colors.white,
  //             child: Padding(
  //               padding: const EdgeInsets.all(40.0),
  //               child: Form(
  //                   child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: <Widget>[
  //                   TextFormField(
  //                     autofocus: false,
  //                     controller: phoneController,
  //                     keyboardType: TextInputType.phone,
  //                     onSaved: (newValue) => phoneController.text = newValue!,
  //                     textInputAction: TextInputAction.next,
  //                     decoration: InputDecoration(
  //                         prefixIcon: Icon(Icons.mail),
  //                         contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
  //                         hintText: "Phone Number",
  //                         border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(10),
  //                         )),
  //                   ),
  //                   SizedBox(
  //                     height: 10,
  //                   ),
  //                   Visibility(
  //                       visible: otpSent,
  //                       child: TextFormField(
  //                         autofocus: false,
  //                         controller: otpController,
  //                         obscureText: true,
  //                         onSaved: (newValue) => otpController.text = newValue!,
  //                         textInputAction: TextInputAction.done,
  //                         decoration: InputDecoration(
  //                             prefixIcon: Icon(Icons.vpn_key),
  //                             contentPadding:
  //                                 EdgeInsets.fromLTRB(20, 15, 20, 15),
  //                             hintText: "Password",
  //                             border: OutlineInputBorder(
  //                               borderRadius: BorderRadius.circular(10),
  //                             )),
  //                       )),
  //                   SizedBox(
  //                     height: 20,
  //                   ),
  //                   Material(
  //                     elevation: 5,
  //                     color: Colors.blueAccent,
  //                     borderRadius: BorderRadius.circular(30),
  //                     child: MaterialButton(
  //                       padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
  //                       minWidth: MediaQuery.of(context).size.width,
  //                       onPressed: () {
  //                         otpSent ? verifyOtp() : fetchOtp();
  //                       },
  //                       child: Text(
  //                         otpSent ? "Verify" : "Get OTP",
  //                         textAlign: TextAlign.center,
  //                         style: TextStyle(
  //                             fontSize: 20,
  //                             color: Colors.white,
  //                             fontWeight: FontWeight.bold),
  //                       ),
  //                     ),
  //                   ),
  //                   SizedBox(
  //                     height: 15,
  //                   ),
  //                 ],
  //               )),
  //             ),
  //           )),
  //         ));