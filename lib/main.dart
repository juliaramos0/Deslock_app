import 'package:deslock/telas/telacarregamento.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Deslock',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const Carregamento(),
    );
  }
}