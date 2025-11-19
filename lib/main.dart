import 'package:flutter/material.dart';
import 'screens/start_page.dart';
import 'screens/login_page.dart';
import 'screens/scan_page.dart';
import 'screens/result_page.dart';
import 'screens/history_page.dart';

void main() => runApp(const NailHealthApp());

class NailHealthApp extends StatelessWidget {
  const NailHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nail Health Detection',
      initialRoute: '/start',
      routes: {
        '/start': (context) => const StartPage(),
        '/login': (context) => const LoginPage(),
        '/scan': (context) => const ScanPage(),
        '/result': (context) => const ResultPage(),
        '/history': (context) => const HistoryPage(),
      },
    );
  }
}
