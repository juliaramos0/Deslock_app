import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'telafavoritos.dart';
import 'telabase.dart'; 
import 'telahistorico.dart';
import 'telaavaliacaorotas.dart'; 

class TelaInicio extends StatefulWidget {
  const TelaInicio({super.key});

  @override
  State<TelaInicio> createState() => _TelaInicioState();
}

class _TelaInicioState extends State<TelaInicio> with TickerProviderStateMixin {
  bool missaoAberta = true;
  bool carregando = true;

  // Controle de Rota
  bool temRotaAtiva = false;

  String nome = 'Usuário';
  String usuario = '@usuario';

  int nivel = 1;
  int xpAtual = 0;
  int xpMaximo = 200;
  int amigosTotal = 0;
  int rotasConcluidas = 0;
  double missaoSemanalProgresso = 0.0;

  late AnimationController _animacaoPino;

  // CONSTANTE DO GRADIENTE DOURADO
  final Gradient _gradienteDourado = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD200), Color(0xFFDDA300)],
  );

  @override
  void initState() {
    super.initState();
    _carregarDados();

    _animacaoPino = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animacaoPino.dispose();
    super.dispose();
  }

  String _formatarUsuario(String valor) {
    final texto = valor.trim();
    if (texto.isEmpty) return '@usuario';
    return texto.startsWith('@') ? texto : '@$texto';
  }

  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      final nomeSalvo = prefs.getString('nome_usuario');
      nome = (nomeSalvo != null && nomeSalvo.trim().isNotEmpty)
          ? nomeSalvo.trim()
          : 'Usuário';

      usuario = _formatarUsuario(prefs.getString('user_usuario') ?? '');

      nivel = prefs.getInt('nivel_usuario') ?? 1;
      xpAtual = prefs.getInt('xp_atual') ?? 0;
      xpMaximo = prefs.getInt('xp_maximo') ?? 200;
      amigosTotal = prefs.getInt('amigos_total') ?? 0;
      rotasConcluidas = prefs.getInt('rotas_concluidas') ?? 0;
      missaoSemanalProgresso = prefs.getDouble('missao_semanal_progresso') ?? 0.0;
      
      // Carrega se tem rota ativa salva
      temRotaAtiva = prefs.getBool('tem_rota_ativa') ?? false;

      carregando = false;
    });
  }

  Future<void> _salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('nivel_usuario', nivel);
    await prefs.setInt('xp_atual', xpAtual);
    await prefs.setInt('xp_maximo', xpMaximo);
    await prefs.setInt('amigos_total', amigosTotal);
    await prefs.setInt('rotas_concluidas', rotasConcluidas);
    await prefs.setDouble('missao_semanal_progresso', missaoSemanalProgresso);
    await prefs.setBool('tem_rota_ativa', temRotaAtiva);
  }

  Future<void> _adicionarXp(int valor) async {
    setState(() {
      xpAtual += valor;
      while (xpAtual >= xpMaximo) {
        xpAtual -= xpMaximo;
        nivel += 1;
        xpMaximo += 100;
      }
    });
    await _salvarDados();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Você ganhou $valor XP!')));
  }

  // Apenas navega para a tela de mapas
  void _planejarNovaRota() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const TelaBase(initialIndex: 1)),
      (route) => false,
    );
  }

  // FINALIZAR VIAGEM COM LÓGICA DO HISTÓRICO REAL
  Future<void> _finalizarViagem() async {
    setState(() {
      temRotaAtiva = false; // Desativa o mapa
      rotasConcluidas += 1; // Soma no histórico
      missaoSemanalProgresso += 0.34; // Enche a missão
      if (missaoSemanalProgresso > 1) {
        missaoSemanalProgresso = 1.0;
      }
    });

    // MÁGICA DO HISTÓRICO: Criar o registo da viagem atual
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Criar o mapa com os dados desta viagem específica
      final novaViagem = {
        'destino': 'Escola Profissional Santo Agostinho', 
        'data': 'Hoje, às ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'xp_ganho': '+25 XP',
        'origem': 'Minha Casa',
        'status_seguranca': 'Segura',
      };

      // 2. Ler o histórico que já existe guardado
      final String? historicoAntigoJson = prefs.getString('lista_historico');
      List<dynamic> listaHistorico = [];
      
      if (historicoAntigoJson != null) {
        listaHistorico = jsonDecode(historicoAntigoJson);
      }

      // 3. Adicionar a nova viagem no início da lista (topo do histórico)
      listaHistorico.insert(0, novaViagem);

      // 4. Gravar a lista atualizada de volta no SharedPreferences
      await prefs.setString('lista_historico', jsonEncode(listaHistorico));
    } catch (e) {
      debugPrint('Erro ao guardar no histórico: $e');
    }

    await _adicionarXp(25); // XP da viagem
    await _salvarDados();

    if (!mounted) return;
    
    // Chama a Tela de Avaliação
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TelaAvaliacaoRota()),
    );
  }

  Future<void> _verFavoritos() async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaFavoritos()));
  }

  // Só resgata a missão se tiver 100%
  Future<void> _resgatarMissao() async {
    if (missaoSemanalProgresso >= 1.0) {
      setState(() {
        missaoSemanalProgresso = 0.0; // Reinicia a missão
      });
      await _adicionarXp(150); 
    }
  }

  Future<void> _abrirPerfil() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const TelaBase(initialIndex: 2)),
      (route) => false,
    );
  }

  Future<void> _abrirHistorico() async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaHistorico()));
  }

  // BOTÃO DE TESTE (Escondido no header para você simular as mudanças da tela)
  void _simularTrocaDeStatusDeRota() async {
    setState(() {
      temRotaAtiva = !temRotaAtiva;
    });
    await _salvarDados();
  }

  @override
  Widget build(BuildContext context) {
    final double progressoXp = xpMaximo > 0 ? (xpAtual / xpMaximo).clamp(0.0, 1.0) : 0.0;
    final double progressoMissao = missaoSemanalProgresso.clamp(0.0, 1.0);
    final bool missaoConcluida = progressoMissao >= 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFFD200),
      body: carregando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5B189A)))
          : SafeArea(
              child: Container(
                height: double.infinity,
                color: const Color(0xFFEAEAEA),
                child: RefreshIndicator(
                  onRefresh: _carregarDados,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // CABEÇALHO DOURADO
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(gradient: _gradienteDourado),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: _abrirPerfil,
                                    child: const CircleAvatar(
                                      radius: 32,
                                      backgroundColor: Color(0xFFBDBDBD),
                                      child: Icon(Icons.person, size: 36, color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(nome, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        Text(usuario),
                                        Text("👥 $amigosTotal Amigos"),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // ÍCONE FANTASMA PARA VOCÊ TESTAR (Play/Pause)
                                      InkWell(
                                        onTap: _simularTrocaDeStatusDeRota,
                                        child: Icon(
                                          temRotaAtiva ? Icons.pause_circle_filled : Icons.play_circle_fill, 
                                          color: const Color(0xFF5B189A)
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text("Nível $nivel"),
                                      Text("⭐ XP: $xpAtual/$xpMaximo"),
                                      Text("Nível ${nivel + 1}"),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  value: progressoXp,
                                  minHeight: 12,
                                  backgroundColor: Colors.white54,
                                  valueColor: const AlwaysStoppedAnimation(Color(0xFF5B189A)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // BARRA DA MISSÃO SEMANAL
                        GestureDetector(
                          onTap: () => setState(() => missaoAberta = !missaoAberta),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            color: const Color(0xFF188C0C),
                            child: Row(
                              children: [
                                const Icon(Icons.eco, color: Colors.white),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text("Missão Semanal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                                Icon(missaoAberta ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white, size: 28),
                              ],
                            ),
                          ),
                        ),
                        
                        // CONTEÚDO DA MISSÃO
                        AnimatedSize(
                          duration: Duration(milliseconds: missaoAberta ? 600 : 250), 
                          curve: missaoAberta ? Curves.easeOutQuart : Curves.easeIn, 
                          child: missaoAberta
                              ? Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF5B189A),
                                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Complete 3 rotas sustentáveis",
                                        style: TextStyle(color: Color(0xFFFFD200), fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Text("Progresso:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                              child: LinearProgressIndicator(
                                                value: progressoMissao,
                                                minHeight: 16,
                                                backgroundColor: Colors.white24,
                                                valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD200)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      const Row(
                                        children: [
                                          Text("Recompensa:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                          SizedBox(width: 8),
                                          Text("+ 150 XP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      
                                      // BOTÃO DA MISSÃO
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          gradient: missaoConcluida ? _gradienteDourado : null,
                                          color: missaoConcluida ? null : Colors.white24, 
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        child: ElevatedButton.icon(
                                          onPressed: missaoConcluida ? _resgatarMissao : null, 
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            disabledBackgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            foregroundColor: missaoConcluida ? const Color(0xFF5B189A) : Colors.white54,
                                          ),
                                          icon: Icon(missaoConcluida ? Icons.card_giftcard : Icons.hourglass_empty),
                                          label: Text(
                                            missaoConcluida ? 'Resgatar Recompensa' : 'Em andamento...',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(width: double.infinity, height: 0),
                        ),
                        
                        // SEÇÃO DE ROTAS E FAVORITOS
                        Container(
                          width: double.infinity,
                          color: const Color(0xFFEAEAEA),
                          padding: const EdgeInsets.fromLTRB(6, 8, 6, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              
                              // SE TEM ROTA ATIVA: Mostra o Mapa e o botão de Finalizar
                              if (temRotaAtiva) ...[
                                const Padding(
                                  padding: EdgeInsets.only(left: 6, bottom: 6),
                                  child: Text('Rota Atual', style: TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold, fontSize: 18)),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4), 
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 128,
                                        width: double.infinity,
                                        child: Stack(
                                          children: [
                                            Positioned.fill(child: CustomPaint(painter: _MapaPainter())),
                                            Center(
                                              child: AnimatedBuilder(
                                                animation: _animacaoPino,
                                                builder: (context, child) {
                                                  return Container(
                                                    width: 32 + (_animacaoPino.value * 20),
                                                    height: 32 + (_animacaoPino.value * 20),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: const Color(0xFF5B189A).withOpacity(0.3 - (_animacaoPino.value * 0.2)),
                                                    ),
                                                    child: Center(
                                                      child: Container(
                                                        width: 16, height: 16,
                                                        decoration: const BoxDecoration(color: Color(0xFF5B189A), shape: BoxShape.circle),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              color: const Color(0xFFD9D9D9),
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              child: const Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('23min', style: TextStyle(color: Color(0xFF5B189A), fontSize: 34, fontWeight: FontWeight.bold, height: 1)),
                                                  SizedBox(height: 4),
                                                  Text('5,6km · 12:50', style: TextStyle(color: Color(0xFF5B189A), fontSize: 15, fontWeight: FontWeight.w500)),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              decoration: BoxDecoration(gradient: _gradienteDourado),
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                              child: const Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text('Rota Ativa', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF5B189A), fontSize: 18, fontWeight: FontWeight.bold, height: 1)),
                                                  SizedBox(height: 6),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.shield_outlined, color: Color(0xFF5B189A), size: 16),
                                                      SizedBox(width: 4),
                                                      Text('Segura', style: TextStyle(color: Color(0xFF5B189A), fontSize: 15, fontWeight: FontWeight.w500)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _finalizarViagem, // Chama a lógica nova!
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent, 
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.stop_circle_outlined, size: 18),
                                    label: const Text('Finalizar Viagem', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ] 
                              
                              // SE NÃO TEM ROTA ATIVA: Mostra só o botão de Planejar
                              else ...[
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _planejarNovaRota,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF5B189A),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.add_circle_outline, size: 18),
                                    label: const Text('Planejar nova Rota', style: TextStyle(fontWeight: FontWeight.w500)),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 24),
                              
                              // HISTÓRICO RECENTE
                              GestureDetector(
                                onTap: _abrirHistorico,
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Row(
                                    children: [
                                      Icon(Icons.history, color: Color(0xFF5B189A), size: 16),
                                      SizedBox(width: 8),
                                      Text('Recentes', style: TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold, fontSize: 18)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              
                              rotasConcluidas == 0
                                  ? Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(horizontal: 6),
                                      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 16),
                                      decoration: BoxDecoration(color: const Color(0xFFD0D0D0), borderRadius: BorderRadius.circular(8)),
                                      child: const Center(
                                        child: Text(
                                          'Você ainda não fez nenhuma rota',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Color(0xFF5B189A), fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            color: const Color(0xFF5B189A),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.calendar_today, color: Color(0xFFFFD200), size: 16),
                                                const SizedBox(width: 6),
                                                const Text("Hoje, agora pouco", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                                                const Spacer(),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(color: const Color(0xFFFFD200), borderRadius: BorderRadius.circular(8)),
                                                  child: const Text("+25 XP", style: TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold, fontSize: 12)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    const Icon(Icons.my_location, color: Color(0xFF5B189A), size: 18),
                                                    Container(height: 24, width: 2, color: Colors.grey[300]),
                                                    const Icon(Icons.location_on, color: Color(0xFF188C0C), size: 18),
                                                  ],
                                                ),
                                                const SizedBox(width: 12),
                                                const Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text("Minha Casa", style: TextStyle(color: Colors.grey, fontSize: 14)),
                                                      SizedBox(height: 18),
                                                      Text("Última Rota Feita", style: TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold, fontSize: 16)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                              const SizedBox(height: 26),
                              
                              // FAVORITOS
                              GestureDetector(
                                onTap: _verFavoritos,
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Row(
                                    children: [
                                      Icon(Icons.favorite_border, color: Color(0xFF5B189A), size: 16),
                                      SizedBox(width: 8),
                                      Text('Favoritos', style: TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold, fontSize: 18)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: _verFavoritos,
                                child: Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 16),
                                  decoration: BoxDecoration(color: const Color(0xFFD0D0D0), borderRadius: BorderRadius.circular(8)),
                                  child: const Center(
                                    child: Text(
                                      'Acesse seus locais salvos',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Color(0xFF5B189A), fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: SizedBox(
                                  width: 140,
                                  height: 38,
                                  child: ElevatedButton(
                                    onPressed: _verFavoritos,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF5B189A),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Ver mais', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _MapaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fundo = Paint()..color = const Color(0xFFE9E9E9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), fundo);
    final rua = Paint()..color = const Color(0xFFD5D5D5)..strokeWidth = 6..style = PaintingStyle.stroke;
    final quadra = Paint()..color = const Color(0xFFF3F3F3)..style = PaintingStyle.fill;
    for (double x = 14; x < size.width; x += 34) canvas.drawLine(Offset(x, 0), Offset(x - 10, size.height), rua);
    for (double y = 18; y < size.height; y += 26) canvas.drawLine(Offset(0, y), Offset(size.width, y + 2), rua);
    for (double x = 8; x < size.width - 20; x += 38) {
      for (double y = 10; y < size.height - 18; y += 28) canvas.drawRect(Rect.fromLTWH(x, y, 20, 12), quadra);
    }
    final parque = Paint()..color = const Color(0xFFCFE8C8);
    canvas.drawRect(Rect.fromLTWH(size.width - 28, size.height / 2 - 8, 24, 16), parque);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}