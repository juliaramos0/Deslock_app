import 'package:flutter/material.dart';

class TelaTutorial extends StatefulWidget {
  const TelaTutorial({super.key});

  @override
  State<TelaTutorial> createState() => _TelaTutorialState();
}

class _TelaTutorialState extends State<TelaTutorial> {
  final PageController _controlador = PageController();
  int _paginaAtual = 0;

  final List<Map<String, dynamic>> _paginas = [
    {
      'icone': Icons.map_outlined,
      'titulo': 'Navegue com Segurança',
      'texto': 'O Deslock prioriza rotas seguras e avaliadas pela comunidade. Descubra os melhores caminhos para o seu destino.',
    },
    {
      'icone': Icons.star_border,
      'titulo': 'Ganhe XP e Suba de Nível',
      'texto': 'Quanto mais você utiliza rotas seguras, mais XP você ganha. Mostre para seus amigos a sua evolução no app!',
    },
    {
      'icone': Icons.eco_outlined,
      'titulo': 'Cumpra Missões',
      'texto': 'Participe de missões semanais e ajude a mapear sua cidade enquanto ganha recompensas exclusivas.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5B189A),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Pular', style: TextStyle(color: Colors.white54, fontSize: 16)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controlador,
                onPageChanged: (index) => setState(() => _paginaAtual = index),
                itemCount: _paginas.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_paginas[index]['icone'], size: 100, color: const Color(0xFFFFD200)),
                        const SizedBox(height: 40),
                        Text(
                          _paginas[index]['titulo'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _paginas[index]['texto'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Indicador de Pontinhos
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _paginas.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 10,
                  width: _paginaAtual == index ? 24 : 10,
                  decoration: BoxDecoration(
                    color: _paginaAtual == index ? const Color(0xFFFFD200) : Colors.white24,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Botão Inferior
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_paginaAtual == _paginas.length - 1) {
                      Navigator.pop(context); // Fim do tutorial, volta pro menu
                    } else {
                      _controlador.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text(
                    _paginaAtual == _paginas.length - 1 ? 'Começar a usar!' : 'Próximo',
                    style: const TextStyle(color: Color(0xFF5B189A), fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}