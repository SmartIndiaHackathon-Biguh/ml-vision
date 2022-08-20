import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
// ignore_for_file: prefer_const_constructors

class TranslatePage extends StatefulWidget {
  TranslatePage({Key? key}) : super(key: key);

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  List<String> inputLanguage = [
    'Bengali',
    'English',
    'Gujarati',
    'Hindi',
    'Kannada',
    'Malayalam',
    'Marathi',
    'Punjabi',
    'Tamil',
    'Telugu'
  ];
  List<String> outputLanguage = [
    'Bengali',
    'English',
    'Gujarati',
    'Hindi',
    'Kannada',
    'Malayalam',
    'Marathi',
    'Punjabi',
    'Tamil',
    'Telugu'
  ];
  List<String> languageCode = [
    'bn',
    'en',
    'gu',
    'hi',
    'kn',
    'ml',
    'mr',
    'pa',
    'ta',
    'te'
  ];

  String? translated = "";
  String? textToTranslate = "";
  String? selectedInput = "English";
  String selectedInputCode = 'en';
  String? selectedOutput = "Hindi";
  String selectedOutputCode = 'hi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Translate Text"),
        centerTitle: true,
      ),
      body: Center(
          child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextField(
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(hintText: 'Enter text'),
              onChanged: (text) async {
                if (text.isNotEmpty) {
                  setState(() {
                    textToTranslate = text;
                    translateText();
                  });
                }
              },
            ),
            const Divider(height: 32),
            SizedBox(
              height: 120,
              child: Text(
                translated!,
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Text("Select Input Language: ",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    fontSize: 15)),
            SizedBox(
              height: 10,
            ),
            Center(
              child: SizedBox(
                width: 240,
                child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                width: 3, color: Colors.blueAccent))),
                    onChanged: (item) => setState(() {
                          selectedInput = item;
                          var pos = inputLanguage.indexOf(item!);
                          selectedInputCode = languageCode[pos];
                          translateText();
                        }),
                    value: selectedInput,
                    items: inputLanguage
                        .map((item) => DropdownMenuItem<String>(
                            value: item, child: Text(item)))
                        .toList()),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text("Select Output Language: ",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    fontSize: 15)),
            SizedBox(
              height: 10,
            ),
            Center(
              child: SizedBox(
                width: 240,
                child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                width: 3, color: Colors.blueAccent))),
                    onChanged: (item) => setState(() {
                          selectedOutput = item;
                          var pos = outputLanguage.indexOf(item!);
                          selectedOutputCode = languageCode[pos];
                          translateText();
                        }),
                    value: selectedOutput,
                    items: outputLanguage
                        .map((item) => DropdownMenuItem<String>(
                            value: item, child: Text(item)))
                        .toList()),
              ),
            ),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      )),
    );
  }

  void translateText() async {
    if (textToTranslate!.isNotEmpty) {
      var translation = await textToTranslate!.translate(
          from: selectedInputCode.toString(),
          to: selectedOutputCode.toString());
      setState(() {
        translated = translation.text;
      });
    }
  }
}
