import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sih_login/Screens/face_detect_screen.dart';
import 'package:sih_login/Screens/home_screen.dart';
import 'package:sih_login/Screens/navbar.dart';
import 'package:sih_login/Screens/registration_screen.dart';
// ignore_for_file: prefer_const_constructors

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // form Key
  final _formkey = GlobalKey<FormState>();

  // editing controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // FIREBASE
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // email
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

    // password
    final passwordField = TextFormField(
      autofocus: false,
      controller: passwordController,
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
      onSaved: (newValue) => passwordController.text = newValue!,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.vpn_key),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );

    // Login button
    final loginButton = Material(
      elevation: 5,
      color: Colors.blueAccent,
      borderRadius: BorderRadius.circular(30),
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          signIn(emailController.text, passwordController.text);
        },
        child: const Text(
          "Login",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );

    return Scaffold(
        backgroundColor: Colors.white,
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
                        height: 45,
                      ),
                      emailField,
                      SizedBox(
                        height: 10,
                      ),
                      passwordField,
                      SizedBox(
                        height: 20,
                      ),
                      loginButton,
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Don't have an account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          RegistrationScreen()));
                            },
                            child: Text("SignUp",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                          )
                        ],
                      )
                    ],
                  )),
            ),
          )),
        ));
  }

  //login func
  void signIn(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password)
            .then((value) {
          Fluttertoast.showToast(msg: "Login Successful!");

          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => BottomNavBar()));
        });
      } on FirebaseAuthException catch (e) {
        Fluttertoast.showToast(msg: e.message.toString());
      }
    }
  }
}
