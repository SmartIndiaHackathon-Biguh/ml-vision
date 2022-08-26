import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ngoScreen2 extends StatefulWidget {
  const ngoScreen2({Key? key}) : super(key: key);

  @override
  State<ngoScreen2> createState() => _ngoScreen2State();
}

final Uri _url1 = Uri.parse('http://www.missingindiankids.com/index.htm');
final Uri _url2 = Uri.parse('https://www.childlineindia.org/a/issues/missing');
final Uri _url3 =
    Uri.parse('https://trackthemissingchild.gov.in/trackchild/index.php');
final Uri smsLaunchUri = Uri(
  scheme: 'tel',
  path: '+91 7313026998',
);

class _ngoScreen2State extends State<ngoScreen2> {
  @override
  bool _hasCallSupport = false;
  Future<void>? _launched;
  String _phone1 = '+91 7313026998';
  String _phone2 = '1098';
  void initState() {
    super.initState();
    // Check for phone call support.
    canLaunchUrl(Uri(scheme: 'tel', path: '+91 7313026998'))
        .then((bool result) {
      setState(() {
        _hasCallSupport = result;
      });
    });
  }

  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('NGOs and Helplines'),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
        body: ListView(
          children: <Widget>[
            Align(
              heightFactor: 1.3,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  
                  Column(
                    children: [
                      Image.network(
                    'http://www.missingindiankids.com/_images/ncmcmono.gif',
                    fit: BoxFit.contain,
                  ),
                    Text('National Center for Missing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,),
                    Text('Children', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,),
                    ElevatedButton(onPressed: _launchUrl1, child: 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.web),
                        Text('  Website')
                    ],
                  ),
                  ),
                  ElevatedButton(onPressed: _hasCallSupport
                  ? () => setState(() {
                        _launched = _makePhoneCall(_phone1);
                      })
                  : null, 
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.phone),
                        Text('  Call')
                    ],
                  ),)
                    ],
                  ),
                ],
              ),
            ),
            Align(
              heightFactor: 1.3,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  
                  Column(
                    children: [
                      Image.network(
                    'https://www.childlineindia.org/images/logo.jpg',
                    fit: BoxFit.contain,
                  ),
                    Text('CHILDLINE Helpline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,),
                    ElevatedButton(onPressed: _launchUrl2, child: 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.web),
                        Text('  Website')
                    ],
                  ),
                  ),
                  ElevatedButton(onPressed: _hasCallSupport
                  ? () => setState(() {
                        _launched = _makePhoneCall(_phone2);
                      })
                  : null, 
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.phone),
                        Text('  Call')
                    ],
                  ),)
                    ],
                  ),
                ],
              ),
            ),
            Align(
              heightFactor: 1.3,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Image.network(
                    'https://trackthemissingchild.gov.in/trackchild/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                    Text('National Tracking System', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,),
                    Text('for', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,),
                    Text('Missing & Vulnerable Children', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,),
                    ElevatedButton(onPressed: _launchUrl3, child: 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.web),
                        Text('  Website')
                    ],
                  ),
                  ),
                  ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}

Future<void> _launchUrl1() async {
  if (!await launchUrl(_url1)) {
    throw 'Could not launch $_url1';
  }
}

Future<void> _makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  await launchUrl(launchUri);
}

Future<void> _launchUrl2() async {
  if (!await launchUrl(_url2)) {
    throw 'Could not launch $_url2';
  }
}

Future<void> _launchUrl3() async {
  if (!await launchUrl(_url3)) {
    throw 'Could not launch $_url3';
  }
}
