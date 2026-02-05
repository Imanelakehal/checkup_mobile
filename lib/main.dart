import 'package:checkup_mobile/features/presentation/pages/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Make sure Flutter is ready
  await Firebase.initializeApp(              // Initialize Firebase
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('Firebase initialized');


  runApp(const MyApp());      
               // Then run your app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedFinder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SignUpPage(),
    );
  }
}
