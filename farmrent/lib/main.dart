import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/login.dart';
import 'screens/auth_service.dart';
import 'screens/central_dashboard_hub.dart';
import 'init_firestore_data.dart';

FirebaseOptions? get safeFirebaseOptions {
  try {
    return const FirebaseOptions(
      // 🔑 Your real web production key from the console snippet!
      apiKey: "AIzaSyB0UCwbesmvi8sLiXG_7cwIcQquVIWocmg",

      // 📱 Keeping your Android App ID link stable
      appId: "1:836811272478:android:5fe318dacade8d371a990f",
      messagingSenderId: "836811272478",
      projectId: "farmrent-fe8af",
      storageBucket: "farmrent-fe8af.firebasestorage.app", // Updated to matches your exact snippet address
    );
  } catch (_) {
    return null;
  }
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final options = safeFirebaseOptions;
    if (options != null) {
      await Firebase.initializeApp(options: options);
    } else {
      await Firebase.initializeApp();
    }
    debugPrint("🚀 Firebase system workspace initialized successfully.");
    await FirestoreInitializer.addSampleEquipment();
  } catch (e) {
    debugPrint("⚠️ Note: Firebase running in local fallback mode: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FarmRent',
        theme: ThemeData(
          primaryColor: Colors.green,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: Consumer<AuthService>(
          builder: (context, auth, _) {
            if (auth.user != null) {
              return const CentralDashboardHub();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
} // 👈 Added this missing bracket to completely close out the MyApp class!