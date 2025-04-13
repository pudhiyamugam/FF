import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  String? filePath;
  List<Map<String, dynamic>>? excelData;

  // Function to pick Excel file
  Future<void> pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      var bytes = File(result.files.single.path!).readAsBytesSync();
      var excelFile = Excel.decodeBytes(bytes);

      List<Map<String, dynamic>> convertedList = [];

      // Assuming only one sheet
      for (var table in excelFile.tables.keys) {
        var rows = excelFile.tables[table]!.rows;

        List<String> headers = rows.first.map((cell) => cell?.value.toString() ?? '').toList();

        for (int i = 1; i < rows.length; i++) {
          var row = rows[i];
          Map<String, dynamic> rowData = {};
          for (int j = 0; j < headers.length; j++) {
            rowData[headers[j]] = row[j]?.value;
          }
          convertedList.add(rowData);
        }
        setState(() {
          excelData = convertedList;
        });
      }

      print("Total records loaded: ${excelData?.length}");
      for (var item in excelData!) {
  item.forEach((key, value) {
    print("$key: ${value.runtimeType}");
  });
}

    }
  }

  // Function to upload data to Firestore
  Future<void> uploadToFirestore() async {
  if (excelData != null && excelData!.isNotEmpty) {
    print("Uploading ${excelData!.length} records...");

    for (var item in excelData!) {
      try {
        var cleanItem = item.map((key, value) => MapEntry(key, value?.toString() ?? ""));
        await FirebaseFirestore.instance.collection('exam_data').add(cleanItem);
        print("Uploaded: $cleanItem");
      } catch (e) {
        print("Failed to upload $item: $e");
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Data uploaded successfully!")),
    );
  } else {
    print("No data loaded yet!");
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
              onPressed: pickExcelFile,
              child: Text("Pick Excel File"),
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
