import 'package:firebase_core/firebase_core.dart';
import 'package:kucognition_app/firebase_options.dart';
import 'package:flutter/material.dart';

import 'screens/start_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/profile_page.dart';
import 'screens/scan_page.dart';
import 'screens/result_page.dart';
import 'screens/history_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // runApp(const NailHealthApp());
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardPage(), // ← Opens dashboard directly
    ),
  );
}

class NailHealthApp extends StatelessWidget {
  const NailHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nail Health Detection',
      initialRoute: '/dashboard',
      routes: {
        '/start': (context) => const StartPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/dashboard': (context) => DashboardPage(),
        '/scan': (context) => const ScanPage(),
        '/result': (context) => const ResultPage(),
        '/history': (context) => const HistoryPage(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}
