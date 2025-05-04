//

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/todo_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyCo9vZ9rtxgvR-mvGo4AppNCU7nlm-NyPw",
        authDomain: "flutter-476e2.firebaseapp.com",
        projectId: "flutter-476e2",
        storageBucket: "flutter-476e2.appspot.com",
        messagingSenderId: "1007713627843",
        appId: "1:1007713627843:web:1d53201ad0b13b0eddfc76",
        measurementId: "G-2W2CTVREE6",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Firebase',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TodoPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
