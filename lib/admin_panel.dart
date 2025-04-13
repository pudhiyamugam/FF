import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  String? filePath;
  Map<String, dynamic>? jsonData;

  // Function to pick JSON file
  Future<void> pickJsonFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
  if (result.files.single.bytes != null) {
    // Web — read data from bytes
    final contents = utf8.decode(result.files.single.bytes!);
    setState(() {
      jsonData = json.decode(contents);
    });
  } else if (result.files.single.path != null) {
    // Mobile — read data from file path
    final file = File(result.files.single.path!);
    final contents = await file.readAsString();
    setState(() {
      jsonData = json.decode(contents);
    });
  } else {
    print("No file path or bytes found");
  }
}

  }

  // Function to upload JSON data to Firestore
  Future<void> uploadToFirestore() async {
    if (jsonData != null) {
      jsonData!.forEach((key, value) async {
        await FirebaseFirestore.instance
            .collection('yourCollectionName')
            .doc(key)
            .set(value);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data uploaded successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Panel"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: pickJsonFile,
              child: Text("Pick JSON File"),
            ),
            SizedBox(height: 20),
            Text(filePath ?? "No file selected"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadToFirestore,
              child: Text("Upload to Firestore"),
            ),
          ],
        ),
      ),
    );
  }
}
