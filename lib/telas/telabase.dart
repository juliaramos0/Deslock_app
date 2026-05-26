import 'package:flutter/material.dart';
import 'teladeinicio.dart'; 
import 'rotas.dart';        
import 'telavoce.dart';     

class TelaBase extends StatefulWidget {
  // A TelaBase agora pode receber uma aba inicial específica
  final int initialIndex;
  
  const TelaBase({super.key, this.initialIndex = 0});

  @override
  State<TelaBase> createState() => _TelaBaseState();
}

class _TelaBaseState extends State<TelaBase> {
  late int indexAtual;

  // CONSTANTE DO GRADIENTE DOURADO
  final Gradient _gradienteDourado = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD200), Color(0xFFDDA300)],
  );

  final List<Widget> telas = const [
    TelaInicio(),
    TelaRotas(),
    TelaVoce(),
  ];

  @override
  void initState() {
    super.initState();
    // Define a aba inicial com base no que foi passado para a tela
    indexAtual = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: indexAtual,
        children: telas,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: _gradienteDourado, // GRADIENTE APLICADO AQUI!
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: indexAtual,
          type: BottomNavigationBarType.fixed,
          // Fundo transparente para o gradiente do Container brilhar:
          backgroundColor: Colors.transparent, 
          selectedItemColor: const Color(0xFF5B189A),
          unselectedItemColor: const Color(0xFF5B189A).withValues(alpha: 0.4),
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          onTap: (index) {
            setState(() {
              indexAtual = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              activeIcon: Icon(Icons.home),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Rotas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Você',
            ),
          ],
        ),
      ),
    );
  }
}