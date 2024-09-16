import 'package:athkar_app/pages/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const AthkarApp());
}

class AthkarApp extends StatelessWidget {
  const AthkarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Athkar-أذكار',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
