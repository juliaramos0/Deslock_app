import 'package:flutter/material.dart';
import 'telaavaliacaorotas.dart';

class TelaNavegacaoAtiva extends StatefulWidget {
  const TelaNavegacaoAtiva({super.key});

  @override
  State<TelaNavegacaoAtiva> createState() => _TelaNavegacaoAtivaState();
}

class _TelaNavegacaoAtivaState extends State<TelaNavegacaoAtiva> with TickerProviderStateMixin {
  late AnimationController _animacaoUsuario;
  int _instrucaoAtual = 0;

  // CONSTANTE DO GRADIENTE DOURADO
  final Gradient _gradienteDourado = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD200), Color(0xFFDDA300)],
  );

  // Lista de instruções simuladas para o GPS
  final List<Map<String, dynamic>> _instrucoesNavegacao = [
    {'texto': 'Siga em frente na Av. Principal', 'distancia': '400m', 'icone': Icons.arrow_upward},
    {'texto': 'Vire à direita na Rua das Flores', 'distancia': '150m', 'icone': Icons.turn_right},
    {'texto': 'Em frente, entre na rotunda', 'distancia': '1km', 'icone': Icons.loop},
    {'texto': 'Chegou à Escola Profissional!', 'distancia': '0m', 'icone': Icons.place},
  ];

  @override
  void initState() {
    super.initState();
    // Animação para o ponto de localização do utilizador pulsar (efeito GPS real)
    _animacaoUsuario = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animacaoUsuario.dispose();
    super.dispose();
  }

  void _mudarInstrucaoSimulada() {
    setState(() {
      _instrucaoAtual = (_instrucaoAtual + 1) % _instrucoesNavegacao.length;
    });
  }

  void _acionarBotaoPanico() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.red[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('ALERTA SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Deseja enviar a sua localização em tempo real para o seu Contato de Emergência cadastrado?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    content: Text('SOS Ativado! Alerta enviado para o seu contato de emergência.'),
                  ),
                );
              },
              child: const Text('ENVIAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _finalizarRota() {
    // Fecha a navegação ativa e empilha a tela de avaliação de rota
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const TelaAvaliacaoRota()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final instrucao = _instrucoesNavegacao[_instrucaoAtual];

    return Scaffold(
      body: Stack(
        children: [
          // 1. FUNDO DO MAPA NATIVO (Simulado em movimento com CustomPaint)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animacaoUsuario,
              builder: (context, child) {
                return CustomPaint(
                  painter: _MapaNavegacaoPainter(offsetAnimacao: _animacaoUsuario.value),
                );
              },
            ),
          ),

          // PONTO CENTRAL DO UTILIZADOR (Seta clássica de GPS)
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF5B189A).withOpacity(0.2),
              ),
              child: const Icon(
                Icons.navigation,
                size: 36,
                color: Color(0xFF5B189A),
              ),
            ),
          ),

          // 2. PAINEL SUPERIOR: Instrução do GPS (Clicável para simular mudança de ruas)
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: GestureDetector(
                onTap: _mudarInstrucaoSimulada,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3C096C), // Roxo escuro para contraste
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD200).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(instrucao['icone'], color: const Color(0xFFFFD200), size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              instrucao['texto'],
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            const Text('Toque aqui para simular o trajeto', style: TextStyle(color: Colors.white38, fontSize: 11)),
                          ],
                        ),
                      ),
                      Text(
                        instrucao['distancia'],
                        style: const TextStyle(color: Color(0xFFFFD200), fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. BOTÃO DE PÂNICO / SOS FLUTUANTE (Fica logo acima do painel inferior)
          Positioned(
            right: 16,
            bottom: 190,
            child: FloatingActionButton(
              onPressed: _acionarBotaoPanico,
              backgroundColor: Colors.red,
              elevation: 6,
              child: const Icon(Icons.sos, color: Colors.white, size: 32),
            ),
          ),

          // 4. PAINEL INFERIOR: Status da Viagem e Botão de Finalizar
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, -4))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Métricas da Rota
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                '18',
                                style: TextStyle(color: Color(0xFF5B189A), fontSize: 32, fontWeight: FontWeight.bold, height: 1),
                              ),
                              Text(
                                ' min',
                                style: TextStyle(color: Color(0xFF5B189A), fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('4,2 km · Chegada: 12:50', style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      // Tag de Rota Segura
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF188C0C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.shield, color: Color(0xFF188C0C), size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Rota Segura',
                              style: TextStyle(color: Color(0xFF188C0C), fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // BOTÃO DE CHEGADA COM GRADIENTE DOURADO
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: _gradienteDourado,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: ElevatedButton(
                      onPressed: _finalizarRota,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text(
                        'Finalizar Trajeto',
                        style: TextStyle(color: Color(0xFF5B189A), fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// PAINTER: Desenha o mapa de navegação simulando movimento contínuo
class _MapaNavegacaoPainter extends CustomPainter {
  final double offsetAnimacao;
  _MapaNavegacaoPainter({required this.offsetAnimacao});

  @override
  void paint(Canvas canvas, Size size) {
    final fundo = Paint()..color = const Color(0xFFEFEFEF);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), fundo);

    final ruaPrincipal = Paint()
      ..color = Colors.white
      ..strokeWidth = 32
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final linhaCentralRua = Paint()
      ..color = const Color(0xFF5B189A).withOpacity(0.4)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Deslocamento simulado baseado na animação para parecer que o utilizador está a andar
    double movimentoY = offsetAnimacao * 120;

    // Desenha uma grande avenida vertical cruzando o ecrã
    Path rotaVertical = Path();
    rotaVertical.moveTo(size.width / 2, -200 + movimentoY);
    rotaVertical.lineTo(size.width / 2, size.height + 200 + movimentoY);
    canvas.drawPath(rotaVertical, ruaPrincipal);
    canvas.drawPath(rotaVertical, linhaCentralRua);

    // Desenha ruas transversais secundárias
    final ruaSecundaria = Paint()
      ..color = Colors.white
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, 150 + movimentoY), Offset(size.width, 150 + movimentoY), ruaSecundaria);
    canvas.drawLine(Offset(0, 500 + movimentoY), Offset(size.width, 500 + movimentoY), ruaSecundaria);
    canvas.drawLine(Offset(0, -200 + movimentoY), Offset(size.width, -200 + movimentoY), ruaSecundaria);

    // Áreas Verdes de Segurança (Parques simulados)
    final parqueSeguro = Paint()..color = const Color(0xFFCFE8C8).withOpacity(0.7);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(40, 220 + movimentoY, 100, 140), const Radius.circular(12)), parqueSeguro);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width - 140, ThreadLocalSecureY(movimentoY), 100, 120), const Radius.circular(12)), parqueSeguro);
  }

  double ThreadLocalSecureY(double mY) {
    return -50 + mY;
  }

  @override
  bool shouldRepaint(covariant _MapaNavegacaoPainter oldDelegate) => true;
}