import 'package:firebase_core/firebase_core.dart';
import 'package:kucognition_app/firebase_options.dart';
import 'package:flutter/material.dart';

import 'screens/start_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/profile_page.dart';
import 'screens/scan_page.dart';
import 'screens/history_page.dart';
import 'screens/uploaded_page.dart';
import 'screens/learnmore_page.dart';
import 'screens/diseaseresults_page.dart';   
import 'screens/uploaded_result.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UploadedResult(),     // ← testing page
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

        // ❗ FIXED: Correct screen for disease results
        '/result': (context) => DiseaseDetailsPage(
              disease: "Onychomycosis",   // placeholder
            ),

        '/history': (context) => const HistoryPage(),
        '/profile': (context) => ProfilePage(),
        '/upload': (context) => const UploadedPage(),
        '/uploaded_result': (context) => const UploadedResult(),





      },
    );
  }
}
