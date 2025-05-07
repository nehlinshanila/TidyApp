import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/login_page.dart';
import 'pages/todo_page.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

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
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Container(); // Optionally replace with a custom error widget
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo Firebase',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const TodoPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
