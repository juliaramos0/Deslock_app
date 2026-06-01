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
    required this.destino, // OBRIGATÓRIO: Força o backend a injetar o destino real escolhido
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
      case 'moto': return Icons.motorcycle;
      default: return Icons.directions_car;
    }
  }

  // --- AÇÃO DO BOTÃO: FINALIZAR VIAGEM ---
  // Backend: Encerra o trajeto, soma o XP conquistado no banco de dados e salva no histórico do servidor.
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

  // --- AÇÃO DO BOTÃO: ENVIAR ALERTA COMMUNITY ---
  // Backend: Coleta as coordenadas de latitude/longitude atuais e realiza um POST para registrar o perigo no mapa global.
  void _enviarAlerta(String tipoAlerta) {
    Navigator.pop(context); // Fecha o BottomSheet de reportes
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Alerta de "$tipoAlerta" enviado à comunidade!'),
          ],
        ),
        backgroundColor: const Color(0xFF188C0C), 
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- COMPONENTE: MENU INFERIOR DE ALERTAS AVANÇADO (ESTILO WAZE + DESLOCK) ---
  void _mostrarMenuAlertas() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF3C096C),
      isScrollControlled: true, // Garante expansão correta para comportar todas as categorias
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 20),
                  const Text('Reportar à Comunidade', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),

                  // CATEGORIA 1: SEGURANÇA PESSOAL
                  const Align(
                    alignment: Alignment.centerLeft, 
                    child: Text('Segurança', style: TextStyle(color: Color(0xFFFFD200), fontSize: 14, fontWeight: FontWeight.bold))
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _botaoAlertaIcone(Icons.gpp_bad, 'Área de Risco', Colors.red),
                      _botaoAlertaIcone(Icons.lightbulb_outline, 'Via Escura', Colors.deepPurpleAccent),
                      _botaoAlertaIcone(Icons.person_search, 'Suspeito', Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // CATEGORIA 2: CONDIÇÕES DA VIA
                  const Align(
                    alignment: Alignment.centerLeft, 
                    child: Text('Condições da Via', style: TextStyle(color: Color(0xFFFFD200), fontSize: 14, fontWeight: FontWeight.bold))
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _botaoAlertaIcone(Icons.construction, 'Buraco/Dano', Colors.brown[400]!),
                      _botaoAlertaIcone(Icons.flood, 'Alagamento', Colors.blue),
                      _botaoAlertaIcone(Icons.block, 'Bloqueio', Colors.redAccent),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // CATEGORIA 3: TRÂNSITO URBANO
                  const Align(
                    alignment: Alignment.centerLeft, 
                    child: Text('Trânsito', style: TextStyle(color: Color(0xFFFFD200), fontSize: 14, fontWeight: FontWeight.bold))
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _botaoAlertaIcone(Icons.car_crash, 'Acidente', Colors.orangeAccent),
                      _botaoAlertaIcone(Icons.traffic, 'Congestionado', Colors.amber),
                      _botaoAlertaIcone(Icons.local_police, 'Polícia', Colors.blueAccent),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _botaoAlertaIcone(IconData icone, String titulo, Color cor) {
    return GestureDetector(
      onTap: () => _enviarAlerta(titulo),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))], border: Border.all(color: cor, width: 2)),
            child: Icon(icone, color: cor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool usaEstrada = widget.modo == 'carro' || widget.modo == 'onibus' || widget.modo == 'moto';

    // Configuração dinâmica de fuso para previsão de chegada (ETA)
    final horaAtual = DateTime.now();
    final horaChegada = horaAtual.add(const Duration(minutes: 23));
    final formatadorHora = '${horaChegada.hour.toString().padLeft(2, '0')}:${horaChegada.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xFFEAEAEA),
      body: Stack(
        children: [
          // ==========================================
          // 1. RENDERIZAÇÃO E ANIMAÇÃO DO MAPA
          // ==========================================
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animacaoController,
              builder: (context, child) {
                return CustomPaint(painter: usaEstrada ? _EstradaPainter(_animacaoController.value) : _CidadePainter(_animacaoController.value));
              },
            ),
          ),

          // ==========================================
          // 2. MIRA DE LOCALIZAÇÃO DO DISPOSITIVO
          // ==========================================
          Center(
            child: AnimatedBuilder(
              animation: _animacaoController,
              builder: (context, child) {
                final pulso = 1.0 + (_animacaoController.value <= 0.5 ? _animacaoController.value : (1.0 - _animacaoController.value)) * 0.3;
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

          // ==========================================
          // 3. PAINEL DE ORIENTAÇÃO DE MANOBRAS (TOP CARD)
          // ==========================================
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F7A1A), 
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.turn_right, color: Colors.white, size: 46),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Em 200 metros', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
                                Text('Av. Olegário Maciel', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.security, color: Color(0xFF188C0C), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Indo para: ${widget.destino}', 
                            style: const TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==========================================
          // 4. MÓDULO VELOCÍMETRO (CORRIGIDO)
          // ==========================================
          Positioned(
            bottom: 230, // Posicionamento elevado para evitar intersecção com o painel inferior
            left: 16,
            child: Container(
              width: 65, height: 65,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF5B189A), width: 3),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(usaEstrada ? '45' : '5', style: const TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold, height: 1.0)),
                  const Text('km/h', style: TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),

          // ==========================================
          // 5. BOTÃO FLUTUANTE DE REPORTES (CORRIGIDO)
          // ==========================================
          // --- BOTÃO: REPORTAR INCIDENTE ---
          Positioned(
            bottom: 230, // Alinhado ao velocímetro fora da área de obstrução do card
            right: 16,
            child: FloatingActionButton(
              heroTag: 'btn_alerta',
              onPressed: _mostrarMenuAlertas,
              backgroundColor: Colors.amber, 
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.report_problem, color: Color(0xFF5B189A), size: 30),
            ),
          ),

          // ==========================================
          // 6. DETALHES DE NAVEGAÇÃO (RODAPÉ)
          // ==========================================
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF5B189A), 
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -4))],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _metricaVisuais('Chegada', formatadorHora, Icons.flag),
                        _metricaVisuais('Tempo', usaEstrada ? '23 min' : '55 min', Icons.timer),
                        _metricaVisuais('Distância', '5.6 km', Icons.route),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // --- BOTÃO: ENCERRAR VIAGEM ---
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _finalizarViagem,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        icon: const Icon(Icons.stop_circle_outlined, size: 20),
                        label: const Text('Encerrar Navegação', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricaVisuais(String label, String valor, IconData icone) {
    return Column(
      children: [
        Icon(icone, color: const Color(0xFFFFD200), size: 20),
        const SizedBox(height: 4),
        Text(valor, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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