import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FirestoreDataScreen extends StatefulWidget {
  const FirestoreDataScreen({Key? key}) : super(key: key);

  @override
  State<FirestoreDataScreen> createState() => _FirestoreDataScreenState();
}

class _FirestoreDataScreenState extends State<FirestoreDataScreen> {
  final CollectionReference _samples =
      FirebaseFirestore.instance.collection('samples');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("access firestore"),
      ),
      body: ListView(
        children: [
          Samples2Data(),
          SamplesData(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _samples
              .add({
                'title': "added title ${Random().nextInt(10000)}",
                'body': "added body ${Random().nextInt(10000)}",
              })
              .then((value) => print("add data"))
              .catchError((error) => print("Failed to add user: $error"));
        },
        tooltip: 'add sample data',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SamplesData extends StatelessWidget {
  const SamplesData();

  @override
  Widget build(BuildContext context) {
    final samples =
        FirebaseFirestore.instance.collection('samples').snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: samples,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        final listTiles = snapshot.data!.docs.map((element) {
          Map<String, dynamic> data = element.data()! as Map<String, dynamic>;
          return ListTile(
            title: Text(data['title']),
            subtitle: Text(data['body']),
          );
        }).toList();
        return Column(
          children: listTiles,
        );
      },
    );
  }
}

class Samples2Data extends StatelessWidget {
  const Samples2Data();

  @override
  Widget build(BuildContext context) {
    final samples2 = FirebaseFirestore.instance.collection('samples2');
    return FutureBuilder<DocumentSnapshot>(
      future: samples2.doc("set doc id").get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          var a = DateTime.parse(data['created_at'].toDate().toString());
          return ListTile(
            title: Text(data['body']),
            subtitle: Text(
              a.toIso8601String(),
            ),
          );
        }

        return Text("loading");
      },
    );
  }
}
