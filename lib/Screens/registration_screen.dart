import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sih_login/Models/user_model.dart';
import 'package:sih_login/Screens/face_detect_screen.dart';
import 'package:sih_login/Screens/home_screen.dart';
import 'package:sih_login/Screens/navbar.dart';
// ignore_for_file: prefer_const_constructors

class RegistrationScreen extends StatefulWidget {
  RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => RregistrationScreenState();
}

class RregistrationScreenState extends State<RegistrationScreen> {
  final _formkey = GlobalKey<FormState>();

  final _auth = FirebaseAuth.instance;

  // editing controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // firstName
    final firstNameField = TextFormField(
      autofocus: false,
      controller: firstNameController,
      keyboardType: TextInputType.name,
      validator: (value) {
        RegExp regex = RegExp(r'^.{3,}$');
        if (value!.isEmpty) {
          return ("Please Enter You Name");
        }
        if (!regex.hasMatch(value)) {
          return ("Name must be min. 3 chars");
        }
      },
      onSaved: (newValue) => firstNameController.text = newValue!,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.account_circle_rounded),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "First Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final lastNameField = TextFormField(
      autofocus: false,
      controller: lastNameController,
      keyboardType: TextInputType.name,
      validator: (value) {
        RegExp regex = RegExp(r'^.{1,}$');
        if (value!.isEmpty) {
          return ("Please Enter You Name");
        }
        if (!regex.hasMatch(value)) {
          return ("Name must be min. 3 chars");
        }
      },
      onSaved: (newValue) => lastNameController.text = newValue!,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.account_circle_rounded),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Last Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final emailField = TextFormField(
      autofocus: false,
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      validator: ((value) {
        if (value!.isEmpty) {
          return ("Please Enter Your Email");
        }
        // reg experssion from email
        if (!RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(value)) {
          return ("Please Enter a Valid Email");
        }
        return null;
      }),
      onSaved: (newValue) => emailController.text = newValue!,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.mail),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Email",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final passwordField = TextFormField(
      autofocus: false,
      controller: passwordController,
      onSaved: (newValue) => passwordController.text = newValue!,
      obscureText: true,
      validator: (value) {
        RegExp regex = RegExp(r'^.{6,}$');
        if (value!.isEmpty) {
          return ("Please Enter Your Passwod");
        }
        if (!regex.hasMatch(value)) {
          return ("Enter Valid Password (min. 6 char)");
        }
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.vpn_key),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final confirmPasswordField = TextFormField(
      autofocus: false,
      controller: confirmPasswordController,
      obscureText: true,
      validator: (value) {
        if (confirmPasswordController.text.length < 6) {
          return ("Enter Valid Password (min. 6 char)");
        }
        if (passwordController.text != value) {
          return ("Passwords dont match");
        }
        return null;
      },
      onSaved: (newValue) => confirmPasswordController.text = newValue!,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.vpn_key),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Confirm Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    final signupButton = Material(
      elevation: 5,
      color: Colors.blueAccent,
      borderRadius: BorderRadius.circular(30),
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          SignUp(emailController.text, passwordController.text);
        },
        child: const Text(
          "SignUp",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.blueAccent),
            onPressed: () {
              // pass to root
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
              child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Form(
                  key: _formkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 200,
                        child: Image.asset(
                          "assets/logo.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(
                        height: 35,
                      ),
                      firstNameField,
                      SizedBox(
                        height: 10,
                      ),
                      lastNameField,
                      SizedBox(
                        height: 10,
                      ),
                      emailField,
                      SizedBox(
                        height: 10,
                      ),
                      passwordField,
                      SizedBox(
                        height: 10,
                      ),
                      confirmPasswordField,
                      SizedBox(
                        height: 25,
                      ),
                      signupButton,
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  )),
            ),
          )),
        ));
  }

  void SignUp(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      try {
        _auth
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((value) => {
                  postDetailsToFirestore(),
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => BottomNavBar()),
                      (Route route) => false)
                });
      } on FirebaseAuthException catch (e) {
        Fluttertoast.showToast(msg: e.message.toString());
      }
    }
    final cred = EmailAuthProvider.credential(email: email, password: password);
  }

  void postDetailsToFirestore() async {
    // calling firestore
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    // calling our user model
    User? user = _auth.currentUser;
    UserModel userModel = UserModel();

    // write values
    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.firstName = firstNameController.text;
    userModel.lastName = lastNameController.text;

    await firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toMap());

    Fluttertoast.showToast(msg: "Account created successfully!");
  }
}
