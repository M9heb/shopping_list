import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ,
    title: "Flutter Groceries",
    theme: ThemeData.dark().copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 15, 160, 226)),
      brightness: Brightness.dark,
      
    ),
    );
  }
}
