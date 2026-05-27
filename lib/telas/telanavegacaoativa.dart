import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'telaavaliacaorotas.dart'; 

class TelaNavegacaoAtiva extends StatefulWidget {
  final String origem; 
  final String destino;
  final String modo; 

  const TelaNavegacaoAtiva({
    super.key, 
    this.origem = 'Sua localização atual', 
    this.destino = 'Escola Profissional Santo Agostinho',
    this.modo = 'carro',
  });

  @override
  State<TelaNavegacaoAtiva> createState() => _TelaNavegacaoAtivaState();
}

class _TelaNavegacaoAtivaState extends State<TelaNavegacaoAtiva> with SingleTickerProviderStateMixin {
  late AnimationController _animacaoController;

  final Gradient _gradienteDourado = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD200), Color(0xFFDDA300)],
  );

  @override
  void initState() {
    super.initState();
    _animacaoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animacaoController.dispose();
    super.dispose();
  }

  IconData _getIconeModo() {
    switch (widget.modo) {
      case 'pe': return Icons.directions_walk;
      case 'bicicleta': return Icons.pedal_bike;
      case 'onibus': return Icons.directions_bus;
      default: return Icons.directions_car;
    }
  }

  Future<void> _finalizarViagem() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final novaViagem = {
        'origem': widget.origem.trim().isEmpty ? 'Sua localização atual' : widget.origem,
        'destino': widget.destino, 
        'data': 'Hoje, às ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'xp_ganho': '+25 XP',
        'status_seguranca': 'Segura',
        'modo': widget.modo,
      };

      final String? historicoJson = prefs.getString('lista_historico');
      List<dynamic> lista = historicoJson != null ? jsonDecode(historicoJson) : [];
      lista.insert(0, novaViagem);
      await prefs.setString('lista_historico', jsonEncode(lista));

      int xp = (prefs.getInt('xp_atual') ?? 0) + 25;
      await prefs.setInt('xp_atual', xp);

    } catch (e) {
      debugPrint('Erro ao salvar: $e');
    }

    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TelaAvaliacaoRota()));
  }

  @override
  Widget build(BuildContext context) {
    bool usaEstrada = widget.modo == 'carro' || widget.modo == 'onibus';

    return Scaffold(
      backgroundColor: const Color(0xFFEAEAEA),
      body: SafeArea(
        child: Column(
          children: [
            // CABEÇALHO ATUALIZADO: Agora mostra Origem e Destino
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                gradient: _gradienteDourado,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getIconeModo(), color: const Color(0xFF5B189A), size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'De: ${widget.origem}',
                          style: const TextStyle(
                            color: Color(0xFF5B189A), 
                            fontWeight: FontWeight.w500, 
                            fontSize: 13
                          ),
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Para: ${widget.destino}',
                          style: const TextStyle(
                            color: Color(0xFF5B189A), 
                            fontWeight: FontWeight.bold, 
                            fontSize: 16
                          ),
                          maxLines: 1, 
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _animacaoController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: usaEstrada 
                            ? _EstradaPainter(_animacaoController.value) 
                            : _CidadePainter(_animacaoController.value), 
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.security, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text('Rota Monitorada', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: AnimatedBuilder(
                      animation: _animacaoController,
                      builder: (context, child) {
                        final pulso = 1.0 + (_animacaoController.value <= 0.5 
                            ? _animacaoController.value 
                            : (1.0 - _animacaoController.value)) * 0.3;

                        return Container(
                          width: 60 * pulso, height: 60 * pulso,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF5B189A).withOpacity(0.2)),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFF5B189A), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]),
                              child: Icon(_getIconeModo(), color: Colors.white, size: 24),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFF5B189A), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metrica('Tempo', usaEstrada ? '23 min' : '55 min'),
                      _metrica('Distância', '5.6 km'),
                      _metrica('Segurança', 'Alta'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _finalizarViagem,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      icon: const Icon(Icons.stop_circle_outlined, size: 20),
                      label: const Text('Cheguei ao Destino', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metrica(String label, String valor) {
    return Column(
      children: [
        Text(valor, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
}

class _EstradaPainter extends CustomPainter {
  final double progresso;
  _EstradaPainter(this.progresso);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFFEAEAEA));
    final asfalto = Paint()..color = const Color(0xFFD5D5D5)..strokeWidth = 80..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(size.width/2, 0), Offset(size.width/2, size.height), asfalto);
    final bordaRua = Paint()..color = Colors.white..strokeWidth = 4..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(size.width/2 - 35, 0), Offset(size.width/2 - 35, size.height), bordaRua);
    canvas.drawLine(Offset(size.width/2 + 35, 0), Offset(size.width/2 + 35, size.height), bordaRua);
    final faixa = Paint()..color = Colors.white..strokeWidth = 4;
    double step = 50; double offset = progresso * step;
    for (double y = -step + offset; y < size.height; y += step) canvas.drawLine(Offset(size.width/2, y), Offset(size.width/2, y + 25), faixa);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _CidadePainter extends CustomPainter {
  final double progresso;
  _CidadePainter(this.progresso);

  @override
  void paint(Canvas canvas, Size size) {
    final fundo = Paint()..color = const Color(0xFFE9E9E9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), fundo);
    final rua = Paint()..color = const Color(0xFFD5D5D5)..strokeWidth = 10..style = PaintingStyle.stroke;
    final quadra = Paint()..color = const Color(0xFFF3F3F3)..style = PaintingStyle.fill;
    final parque = Paint()..color = const Color(0xFFCFE8C8)..style = PaintingStyle.fill;
    
    double passoY = 140; double passoX = 110; double offset = progresso * passoY;
    
    for (double x = -50; x < size.width + 100; x += passoX) canvas.drawLine(Offset(x, -50), Offset(x - 20, size.height + 50), rua);
    
    for (double y = -passoY + offset; y < size.height + passoY; y += passoY) {
      canvas.drawLine(Offset(-50, y), Offset(size.width + 50, y + 15), rua);
      for (double x = 10; x < size.width; x += passoX) {
        bool isParque = (x > 100 && (y % 280) < 100); 
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y + 15, 70, 90), const Radius.circular(12)), isParque ? parque : quadra);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}