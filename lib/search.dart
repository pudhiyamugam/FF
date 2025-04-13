import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  void searchFirestore() async {
  String input = _controller.text.trim();

  final snapshot = await FirebaseFirestore.instance
      .collection('exam_data')
      .get();

  bool found = false;
  for (var doc in snapshot.docs) {
    var data = doc.data();
    if (data.values.contains(input)) {
      found = true;
      break;
    }
  }

  String status = found ? "yes" : "no";

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Search Result"),
      content: Text("Found: $status"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("OK"),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("find"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "enter the reg number",
              ),
            ),
            ElevatedButton(
              onPressed: searchFirestore,
              child: Text("Search"),
            ),
            SizedBox(height: 10)
          ],
        ),
      ),
    );
  }
}