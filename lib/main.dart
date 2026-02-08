import 'package:checkup_mobile/features/splash/presentation/pages/splash_page.dart';
import 'package:checkup_mobile/features/onboarding/presentation/pages/onboarding_page.dart'; 
import 'package:checkup_mobile/features/auth/presentation/pages/signup_page.dart';
import 'package:checkup_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print('Firebase initialized');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CheckUp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF344E41)),
        useMaterial3: true,
      ),
      home: const SplashPage(),  
      routes: {
        '/onboarding': (context) => const OnboardingPage(), 
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(), 
      },
    );
  }
}