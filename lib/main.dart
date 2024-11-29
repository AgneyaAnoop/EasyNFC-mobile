import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/screens/auth_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyNFC',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        // Add other theme customizations
      ),
      home: const AuthScreen(),
    );
  }
}