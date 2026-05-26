import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'telalogin.dart'; 
import 'telabase.dart'; 

class Carregamento extends StatefulWidget {
  const Carregamento({super.key});

  @override
  State<Carregamento> createState() => _CarregamentoState();
}

class _CarregamentoState extends State<Carregamento> {
  @override
  void initState() {
    super.initState();
    _verificarSessao(); 
  }

  Future<void> _verificarSessao() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();
    // Atenção: Na TelaLogin e Cadastro usamos 'usuario_logado'. Estou usando a mesma chave aqui!
    bool estaLogado = prefs.getBool('usuario_logado') ?? false;

    if (!mounted) return;

    if (estaLogado) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TelaBase()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TelaLogin()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4C0B9B), 
      body: SafeArea(
        child: Center(
          
          child: Image.asset("assets/DESLOCK.png"),
        ),
      ),
    );
  }
}