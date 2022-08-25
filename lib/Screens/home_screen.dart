// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:sih_login/Models/user_model.dart';
// import 'package:sih_login/Screens/login_screen.dart';
// // ignore_for_file: prefer_const_constructors

// class HomeScreen extends StatefulWidget {
//   HomeScreen({Key? key}) : super(key: key);

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
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
//               "Welcome Back",
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
//             ActionChip(
//                 label: Text("LogOut"),
//                 onPressed: () {
//                   logOut(context);
//                 })
//           ],
//         ),
//       )),
//     );
//   }

//   Future<void> logOut(BuildContext context) async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => LoginScreen()));
//     } on FirebaseAuthException catch (e) {
//       Fluttertoast.showToast(msg: e.message.toString());
//     }
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sih_login/Services/list_services.dart';

class ListApp extends StatefulWidget {
  const ListApp({Key? key}) : super(key: key);

  @override
  State<ListApp> createState() => _ListAppState();
}

class _ListAppState extends State<ListApp> {
  final childrenCollection = FirebaseFirestore.instance.collection('victims');
  int numberChildren = 0;

  List<Widget> myList = [Text('Loading')];

  @override
  void initState() {
    getListView();
  }

  //func get an entire list of all people
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Toddlert'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 0.1 * screenHeight,
              width: screenWidth,
              child: Text(
                'Total missing children : $numberChildren',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
                child: ListView(
              children: myList,
            ))
          ]),
    );
  }

  Future<void> getListView() async {
    final _collection = await childrenCollection.get();
    final allData = _collection.docs.map((e) => e.data()).toList();
    setState(() {
      numberChildren = allData.length;
    });

    allData[0];

    setState(() {
      myList = allData
          .map((e) => childInfoView(
              childName: e['name'],
              childGender: e['gender'],
              imgUrl: e['ImageURl'],
              childAge: e['age']))
          .toList();
    });
  }

  Widget childInfoView(
      {required String childName,
      required String childGender,
      required String imgUrl,
      required int childAge}) {
    return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Image.network(
            imgUrl,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(
          child: Column(children: [
            Text(childName),
            Text(childGender),
            Text(childAge.toString())
          ]),
        )
      ],
    );
  }
}
