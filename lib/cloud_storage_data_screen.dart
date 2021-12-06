import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CloudStorageDataScreen extends StatefulWidget {
  const CloudStorageDataScreen({Key? key}) : super(key: key);

  @override
  State<CloudStorageDataScreen> createState() => _CloudStorageDataScreenState();
}

class _CloudStorageDataScreenState extends State<CloudStorageDataScreen> {
  FirebaseStorage storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    final ref = storage.ref("sample.jpeg");
    return Scaffold(
      appBar: AppBar(
        title: Text("access cloud storage"),
      ),
      body: Text("hello"),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
      ),
    );
  }
}
