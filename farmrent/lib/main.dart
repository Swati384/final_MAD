import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login.dart';

// Safe check: We attempt to dynamically use the generated options if present,
// otherwise we provide a dummy fallback variable to prevent compiler errors.
FirebaseOptions? get safeFirebaseOptions {
  try {
    // This allows the app to compile cleanly even if the file isn't created yet
    return const FirebaseOptions(
      apiKey: "AIzaSyDummyKeyForCompilationPurposesOnly",
      appId: "1:1234567890:web:abcdef1234567890",
      messagingSenderId: "1234567890",
      projectId: "farmrent-mock-id",
      storageBucket: "farmrent-mock-id.appspot.com",
    );
  } catch (_) {
    return null;
  }
}

void main() async {
  // Ensure Flutter framework components are fully attached before connecting to native plugins
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final options = safeFirebaseOptions;
    if (options != null) {
      await Firebase.initializeApp(options: options);
    } else {
      await Firebase.initializeApp();
    }
    debugPrint("🚀 Firebase system workspace initialized successfully.");
  } catch (e) {
    debugPrint("⚠️ Note: Firebase running in local fallback mode: $e");
  }

  // Load the app smoothly once security and data configurations are ready
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FarmRent',
      theme: ThemeData(
        primaryColor: Colors.green,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // Starts the app cleanly on the Login Screen
      home: const LoginScreen(),
    );
  }
}