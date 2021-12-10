import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CloudStorageDataScreen extends StatefulWidget {
  const CloudStorageDataScreen({Key? key}) : super(key: key);

  @override
  State<CloudStorageDataScreen> createState() => _CloudStorageDataScreenState();
}

class _CloudStorageDataScreenState extends State<CloudStorageDataScreen> {
  FirebaseStorage storage = FirebaseStorage.instance;

  var _isLoading = false;
  File? file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("access cloud storage"),
      ),
      body: Column(
        children: [
          if (_isLoading) CircularProgressIndicator(),
          if (file == null)
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
              },
            ),
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
          if (file != null) Image.file(file!)
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            tooltip: 'upload file',
            child: const Icon(Icons.add),
            onPressed: () {
              _upload();
            },
          ),
          SizedBox(
            height: 8,
          ),
          FloatingActionButton(
            tooltip: 'download file',
            child: const Icon(Icons.download),
            onPressed: () async {
              await _download();
            },
          ),
        ],
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
      setState(() {
        _isLoading = true;
      });
      await storage.ref(fileName).putFile(file);
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String get fileName =>
      DateTime.now().microsecondsSinceEpoch.toString() + ".jpg";

  Future<void> _download() async {
    var status = await Permission.storage.status;
    print(status);
    if (status == PermissionStatus.denied) {
      // 一度もリクエストしてないので権限のリクエスト.
      status = await Permission.storage.request();
    }
    Directory? appDocDir = await getExternalStorageDirectory();
    print("appDocDir is null " + (appDocDir == null).toString());
    if (appDocDir == null) return;
    File downloadToFile = File(appDocDir.path + "/" + fileName);

    if (downloadToFile.existsSync()) await downloadToFile.delete();

    print(downloadToFile.path);
    try {
      setState(() {
        _isLoading = true;
      });
      final ref = storage.ref('sample.jpeg');
      await ref.writeToFile(downloadToFile);
      print("file downloaded");
    } on FirebaseException catch (e) {
      // e.g, e.code == 'canceled'
      print("error occured!");
    } finally {
      final file = File(downloadToFile.path);
      print("file exist : ${file.existsSync()}");

      this.file = file;
      setState(() {
        _isLoading = false;
      });
    }
  }
}
