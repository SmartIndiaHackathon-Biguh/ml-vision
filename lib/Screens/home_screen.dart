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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 40,
              width: screenWidth,
              child: Center(
                child: Text(
                  'Total missing children : $numberChildren',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              // child: ListView(
              //   children: myList,
              child: ListView.builder(
                  itemCount: numberChildren,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return myList[index];
                  }),
            ),
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
    // return Row(
    //   children: [
    //     SizedBox(
    //       width: MediaQuery.of(context).size.width * 0.3,
    //       child: Image.network(
    //         imgUrl,
    //         fit: BoxFit.contain,
    //       ),
    //     ),
    //     SizedBox(
    //       child: Column(children: [
    //         Text(childName),
    //         Text(childGender),
    //         Text(childAge.toString())
    //       ]),
    //     )
    //   ],
    // );
    // return ListTile(
    //   visualDensity: VisualDensity(vertical: 2),
    //   leading: SizedBox(
    //     child: Image.network(
    //       imgUrl,
    //       fit: BoxFit.contain,
    //     ),
    //     height: 200,
    //   ),
    //   title: Text(
    //     childName,
    //     style: TextStyle(fontWeight: FontWeight.bold),
    //   ),
    //   subtitle: Text(
    //     "Gender: $childGender  |   Age: $childAge",
    //     style: TextStyle(fontWeight: FontWeight.bold),
    //   ),
    // );
    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),
      color: Colors.white,
      boxShadow: [BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10)]),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(childName, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
                Text(childGender, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                Text(childAge.toString(), style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),)
              ],
              
            ),
            Image.network(imgUrl, fit: BoxFit.contain,)
          ]),
      ),
    );
  }
}