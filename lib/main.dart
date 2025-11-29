import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kucognition_app/firebase_options.dart';

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
import 'screens/result_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Supabase init
  await Supabase.initialize(
    url: 'https://tsrpxhsdaibzbudapooh.supabase.co', // <-- put your Project URL here
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRzcnB4aHNkYWliemJ1ZGFwb29oIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0MDQ3MTAsImV4cCI6MjA3OTk4MDcxMH0.verlLgyhQ5_yFth-v_Zp5qdWd8ugz6ZloE-hFWlHXh0',
  );

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
      home: const LoginPage(), // ← current start screen
      // home: UploadedPage(),
      // home: DashboardPage(),
      // home: ScanPage(),

      // OPTION B → Use your normal navigation
      // initialRoute: '/start',
      routes: {
        '/start': (context) => StartPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/signup_extra': (context) => const SignUpExtraPage(),
        '/dashboard': (context) => DashboardScreen(),
        '/scan': (context) => ScanPage(),
        '/learnmore': (context) => LearnMorePage(),
        '/history': (context) => const HistoryPage(),
        '/profile': (context) => ProfilePage(),
        '/upload': (context) => const UploadedPage(),
        '/uploaded_result': (context) => const UploadedResult(),
        '/result_page': (context) => const ResultPage(),
      },
    );
  }
}
