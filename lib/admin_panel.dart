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
  List<dynamic>? jsonData;

  // Function to pick JSON file
  Future<void> pickJsonFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result?.files.single.path != null) {
  final file = File(result!.files.single.path!);
  final contents = await file.readAsString();
  List<dynamic> data = json.decode(contents);
  setState(() {
    jsonData = data;
  });
  print("File loaded successfully.");
} else {
  print("No file selected.");
}


  }

  // Function to upload JSON data to Firestore
  Future<void> uploadToFirestore() async {
  if (jsonData != null) {
    for (var item in jsonData!) {
      await FirebaseFirestore.instance
          .collection('exam_data')
          .add(item); // using .add() since we don't have a specific doc ID
    }

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
