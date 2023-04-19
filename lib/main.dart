import 'package:computer_says_no/console.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
        colorScheme: const ColorScheme.light(primary: Colors.green),
        useMaterial3: true
      ),
      home: const Scaffold(
        body: Console(),
      ),
    );
  }
}
