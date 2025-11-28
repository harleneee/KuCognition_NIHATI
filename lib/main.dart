import 'package:firebase_core/firebase_core.dart';
import 'package:kucognition_app/firebase_options.dart';
import 'package:flutter/material.dart';

import 'screens/start_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/signup_extra_page.dart';
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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const NailHealthApp());
}

class NailHealthApp extends StatelessWidget {
  const NailHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nail Health Detection',

      // OPTION A → Use home: when testing a specific screen
      // home: SignUpPage(),
      // home: LoginPage(),       // ← UNCOMMENT when testing login
      // home: UploadedPage(),
      // home: DashboardPage(),
      home: ScanPage(),

      // home: UploadedPage(),

      // OPTION B → Use your normal navigation
      // initialRoute: '/start', // ← your real starting screen
      routes: {
        '/start': (context) => StartPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/signup_extra': (context) => const SignUpExtraPage(),
        '/dashboard': (context) => DashboardScreen(),
        '/scan': (context) => ScanPage(),
        '/learnmore': (context) => LearnMorePage(),
        '/result': (context) => DiseaseDetailsPage(disease: "Onychomycosis"),
        '/history': (context) => const HistoryPage(),
        '/profile': (context) => ProfilePage(),
        '/upload': (context) => const UploadedPage(),
        '/uploaded_result': (context) => const UploadedResult(),
      },
    );
  }
}
