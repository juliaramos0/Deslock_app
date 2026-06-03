import 'package:deslock/telas/telacarregamento.dart';
import 'package:flutter/material.dart';

// O "async" foi adicionado aqui
void main() async { 
  // TRAVA DE SEGURANÇA NATIVA (OBRIGATÓRIO)
  // Garante que o motor do Flutter ligue antes de o app tentar ler a memória ou tela
  WidgetsFlutterBinding.ensureInitialized();

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