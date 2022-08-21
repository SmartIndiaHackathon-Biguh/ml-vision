import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ngoScreen extends StatefulWidget {
  const ngoScreen({Key? key}) : super(key: key);

  @override
  State<ngoScreen> createState() => _ngoScreenState();
}

final Uri _url1 = Uri.parse('http://www.missingindiankids.com/index.htm');
final Uri _url2 = Uri.parse('https://www.childlineindia.org/a/issues/missing');
final Uri _url3 =
    Uri.parse('https://trackthemissingchild.gov.in/trackchild/index.php');
final Uri smsLaunchUri = Uri(
  scheme: 'tel',
  path: '+91 7313026998',
);

class _ngoScreenState extends State<ngoScreen> {
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
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('List of NGOs'),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
        body: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Text(
                'National Centre for Missing Children',
                style: TextStyle(
                  fontSize: 20,
                  decoration: TextDecoration.underline,
                  height: 2,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _launchUrl1,
              child: Text('Website'),
            ),
            ElevatedButton(
              onPressed: _hasCallSupport
                  ? () => setState(() {
                        _launched = _makePhoneCall(_phone1);
                      })
                  : null,
              child: _hasCallSupport
                  ? const Text('Make phone call')
                  : const Text('Calling not supported'),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                'CHILDLINE Helpline',
                style: TextStyle(
                  fontSize: 20,
                  decoration: TextDecoration.underline,
                  height: 3,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _launchUrl2,
              child: Text('Website'),
            ),
            ElevatedButton(
              onPressed: _hasCallSupport
                  ? () => setState(() {
                        _launched = _makePhoneCall(_phone2);
                      })
                  : null,
              child: _hasCallSupport
                  ? const Text('Make phone call')
                  : const Text('Calling not supported'),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                'National Tracking System',
                style: TextStyle(
                  fontSize: 20,
                  decoration: TextDecoration.underline,
                  height: 3,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _launchUrl3,
              child: Text('Website'),
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
