import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false;
  bool _isLogin = false;
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _auth.authStateChanges().listen((User? user) {
      setState(() {
        _isLogin = user != null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isLoading) const CircularProgressIndicator(),
            // const Text(
            //   'You have pushed the button this many times:',
            // ),
            if (_isLogin)
              OutlinedButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  await _auth.signOut();
                  setState(() {
                    _isLoading = false;
                  });
                },
                child: Text("ログアウト"),
              ),
            if (!_isLogin)
              ElevatedButton(
                onPressed: () async {
                  try {
                    setState(() {
                      _isLoading = true;
                    });
                    final userCredential = await _auth.signInAnonymously();
                  } on FirebaseAuthException catch (e) {
                    print(e);
                    print(e.code);
                    print(e.message);
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                child: Text("ログイン"),
              ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}