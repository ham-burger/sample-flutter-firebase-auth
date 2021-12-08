import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class CloudStorageDataScreen extends StatefulWidget {
  const CloudStorageDataScreen({Key? key}) : super(key: key);

  @override
  State<CloudStorageDataScreen> createState() => _CloudStorageDataScreenState();
}

class _CloudStorageDataScreenState extends State<CloudStorageDataScreen> {
  FirebaseStorage storage = FirebaseStorage.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("access cloud storage"),
      ),
      body: Column(
        children: [
          FutureBuilder(
              future: storage.ref("sample.jpeg").getDownloadURL(),
              builder:
                  (BuildContext context, AsyncSnapshot<String> asyncSnapshot) {
                if (asyncSnapshot.hasError) {
                  return Text("error occuered!!");
                }
                if (asyncSnapshot.hasData) {
                  return Image.network(asyncSnapshot.data!);
                }
                return Text("no data");
              }),
          FutureBuilder(
            future: storage.ref().listAll(),
            builder: (BuildContext context,
                AsyncSnapshot<ListResult> asyncSnapshot) {
              if (asyncSnapshot.hasError) {
                return Text("error occuered!!");
              }
              if (asyncSnapshot.hasData) {
                final length = asyncSnapshot.data?.items.length ?? 0;
                return Text("data length = $length");
              }
              return Text("no data");
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'upload file',
        child: const Icon(Icons.add),
        onPressed: () {
          _upload();
        },
      ),
    );
  }

  void _upload() async {
    // imagePickerで画像を選択する
    // upload
    final picker = ImagePicker();
    final pickerFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickerFile == null) {
      return;
    }
    File file = File(pickerFile.path);
    try {
      await storage
          .ref(DateTime.now().microsecondsSinceEpoch.toString() + ".jpg")
          .putFile(file);
    } catch (e) {
      print(e);
    } finally {}
  }
}
