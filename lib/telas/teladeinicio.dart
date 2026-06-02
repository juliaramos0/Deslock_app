import 'dart:convert'; 
import 'dart:typed_data'; // NOVO: Para lidar com a foto em memória (Base64)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'telafavoritos.dart';
import 'telabase.dart'; 
import 'telahistorico.dart';
import 'telanavegacaoativa.dart'; 

class TelaInicio extends StatefulWidget {
  const TelaInicio({super.key});

  @override
  State<TelaInicio> createState() => _TelaInicioState();
}

class _TelaInicioState extends State<TelaInicio> {
  bool missaoAberta = true;
  bool carregando = true;

  String nome = 'Usuário';
  String usuario = '@usuario';
  
  // NOVO: Lê a imagem em formato de bytes para funcionar em qualquer PC/Celular
  Uint8List? _bytesFoto; 

  int nivel = 1;
  int xpAtual = 0;
  int xpMaximo = 200;
  int amigosTotal = 0;
  double missaoSemanalProgresso = 0.0;

  Map<String, dynamic>? ultimaRota;
  List<Map<String, dynamic>> favoritesHome = [];

  final Gradient _gradienteDourado = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD200), Color(0xFFDDA300)],
  );

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  String _formatarUsuario(String valor) {
    final texto = valor.trim();
    if (texto.isEmpty) return '@usuario';
    return texto.startsWith('@') ? texto : '@$texto';
  }

  // --- FUNÇÃO CORRIGIDA ---
  // O bug do XP estava aqui. Ele estava sempre forçando os dados padrão em vez de ler da memória.
  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      nome = prefs.getString('nome_usuario') ?? 'Usuário';
      usuario = _formatarUsuario(prefs.getString('user_usuario') ?? '');
      
      // LÓGICA DE FOTO BASE64
      final fotoSalvaBase64 = prefs.getString('foto_perfil_base64');
      if (fotoSalvaBase64 != null && fotoSalvaBase64.isNotEmpty) {
        _bytesFoto = base64Decode(fotoSalvaBase64);
      } else {
        _bytesFoto = null;
      }

      // CORREÇÃO: Agora ele lê corretamente o nível e XP da memória e só usa o fallback (1 ou 0) se não existir
      nivel = prefs.getInt('nivel_usuario') ?? 1;
      xpAtual = prefs.getInt('xp_atual') ?? 0;
      xpMaximo = prefs.getInt('xp_maximo') ?? 200;
      amigosTotal = prefs.getInt('amigos_total') ?? 0;
      
      // Simula uma missão quase completa (Para testes do usuário)
      missaoSemanalProgresso = prefs.getDouble('missao_semanal_progresso') ?? 1.0;

      final String? historicoJson = prefs.getString('lista_historico');
      if (historicoJson != null) {
        final List<dynamic> historico = jsonDecode(historicoJson);
        if (historico.isNotEmpty) {
          ultimaRota = Map<String, dynamic>.from(historico.first);
        }
      }

      final String? favoritosJson = prefs.getString('lista_favoritos');
      if (favoritosJson != null) {
        final List<dynamic> todosFavoritos = jsonDecode(favoritosJson);
        favoritesHome = todosFavoritos.take(2).map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        favoritesHome = [];
      }

      carregando = false;
    });
  }

  // Função que envia o XP novo para o Banco de Dados (ou SharedPreferences)
  Future<void> _salvarDados() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('xp_atual', xpAtual);
    await prefs.setInt('nivel_usuario', nivel);
    await prefs.setInt('xp_maximo', xpMaximo);
    await prefs.setDouble('missao_semanal_progresso', missaoSemanalProgresso);
  }

  // A Lógica matemática de Upar de Nível (Subir de Level)
  Future<void> _adicionarXp(int valor) async {
    setState(() {
      xpAtual += valor;
      // Laço "While" garante que se o usuário ganhar 500 XP de uma vez, ele sobe vários níveis juntos
      while (xpAtual >= xpMaximo) {
        xpAtual -= xpMaximo;
        nivel += 1;
        xpMaximo += 100; // Cada nível fica 100 XP mais difícil
      }
    });
    
    // Chama o salvar para garantir que a memória não resete o nível
    await _salvarDados();
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Você ganhou $valor XP! Parabéns!'),
        backgroundColor: const Color(0xFF188C0C),
      ),
    );
  }

  // AÇÃO DO BOTÃO: "IR" (Nos cards de Favoritos)
  // Backend: Essa função recebe o 'destino' e inicia a navegação ativa no GPS.
  void _iniciarRotaRapida(String destino) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Iniciando rota rápida para: $destino...')),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TelaNavegacaoAtiva(
            destino: destino,
            modo: 'carro', // Backend: Aqui você pode configurar para puxar o modo favorito da API
          ),
        ),
      );
    });
  }

  // AÇÃO DO BOTÃO: "Atalhos Rápidos" ou "Ver todos os favoritos"
  // Backend: Apenas navegação para a tela que lista os Favoritos do usuário.
  Future<void> _verFavoritos() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaFavoritos()));
    _carregarDados(); 
  }

  // AÇÃO DO BOTÃO: "Resgatar Recompensa" (No card da Missão Semanal)
  // Backend: Chama API para validar missão e credita XP na conta do usuário no servidor.
  Future<void> _resgatarMissao() async {
    if (missaoSemanalProgresso >= 1.0) {
      setState(() {
        missaoSemanalProgresso = 0.0; 
      });
      // Adiciona o XP na conta
      await _adicionarXp(150); 
    }
  }

  // AÇÃO DO BOTÃO: Foto de Perfil (Avatar no topo da tela)
  // Backend: Leva o usuário para a tela de Perfil
  Future<void> _abrirPerfil() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const TelaBase(initialIndex: 2)),
      (route) => false,
    );
  }

  // AÇÃO DO BOTÃO: "Última Rota"
  // Backend: Direciona para o Histórico de viagens do usuário puxado do servidor
  Future<void> _abrirHistorico() async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaHistorico()));
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
                        // ==========================================
                        // CABEÇALHO DOURADO (Perfil e Progresso)
                        // ==========================================
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(gradient: _gradienteDourado),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // --- BOTÃO: ABRIR PERFIL (AVATAR) ---
                                  GestureDetector(
                                    onTap: _abrirPerfil,
                                    child: CircleAvatar(
                                      radius: 32,
                                      backgroundColor: const Color(0xFFBDBDBD),
                                      // Renderiza a foto em Base64
                                      backgroundImage: _bytesFoto != null ? MemoryImage(_bytesFoto!) : null,
                                      child: _bytesFoto == null ? const Icon(Icons.person, size: 36, color: Colors.white) : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(nome, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        Text(usuario),
                                        Text("👥 $amigosTotal Amigos"), // Backend: Contar amigos da lista da API
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("Nível $nivel", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5B189A))),
                                      const SizedBox(height: 4),
                                      Text("⭐ XP: $xpAtual/$xpMaximo"),
                                      Text("Nível ${nivel + 1}"),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
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
                        
                        // ==========================================
                        // BARRA DA MISSÃO SEMANAL (Retrátil)
                        // ==========================================
                        // --- BOTÃO: EXPANDIR/RECOLHER MISSÃO ---
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
                                      const Text("Complete 3 rotas sustentáveis", style: TextStyle(color: Color(0xFFFFD200), fontWeight: FontWeight.bold, fontSize: 14)), // Backend: Puxar texto da missão atual da API
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
                                          Text("+ 150 XP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)), // Backend: Puxar XP da recompensa
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(gradient: missaoConcluida ? _gradienteDourado : null, color: missaoConcluida ? null : Colors.white24, borderRadius: BorderRadius.circular(25)),
                                        // --- BOTÃO: RESGATAR RECOMPENSA DA MISSÃO ---
                                        // Só fica ativo (clickable) quando missaoConcluida for verdadeira
                                        child: ElevatedButton.icon(
                                          onPressed: missaoConcluida ? _resgatarMissao : null, 
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, disabledBackgroundColor: Colors.transparent, shadowColor: Colors.transparent, foregroundColor: missaoConcluida ? const Color(0xFF5B189A) : Colors.white54),
                                          icon: Icon(missaoConcluida ? Icons.card_giftcard : Icons.hourglass_empty),
                                          label: Text(missaoConcluida ? 'Resgatar Recompensa' : 'Em andamento...', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(width: double.infinity, height: 0),
                        ),
                        
                        // ==========================================
                        // CONTEÚDO SCROLLÁVEL INFERIOR (Favoritos e Histórico)
                        // ==========================================
                        Container(
                          width: double.infinity,
                          color: const Color(0xFFEAEAEA),
                          padding: const EdgeInsets.fromLTRB(6, 20, 6, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // --- BOTÃO: TÍTULO DOS FAVORITOS (Ver tudo) ---
                              GestureDetector(
                                onTap: _verFavoritos,
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Row(
                                    children: [
                                      Icon(Icons.favorite_border, color: Color(0xFF5B189A), size: 16),
                                      SizedBox(width: 8),
                                      Text('Atalhos Rápidos', style: TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold, fontSize: 18)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              (favoritesHome.isEmpty)
                                  // --- BOTÃO: CARD DE AVISO VAZIO (Leva para favoritos) ---
                                  ? GestureDetector(
                                      onTap: _verFavoritos,
                                      child: Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.symmetric(horizontal: 6),
                                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                                        decoration: BoxDecoration(color: const Color(0xFFD0D0D0), borderRadius: BorderRadius.circular(8)),
                                        child: const Center(child: Text('Adicione locais favoritos para acessá-los aqui.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF5B189A), fontSize: 15, fontWeight: FontWeight.bold))),
                                      ),
                                    )
                                  // RENDERIZAÇÃO DA LISTA DE FAVORITOS (Max 2 na Home)
                                  : Column(
                                      children: [
                                        for (var fav in favoritesHome) ...[
                                          Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
                                            child: ListTile(
                                              leading: const CircleAvatar(backgroundColor: Color(0xFF5B189A), child: Icon(Icons.star, color: Color(0xFFFFD200), size: 20)),
                                              title: Text(fav['titulo'] ?? 'Local salvo', style: const TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                              subtitle: Text(fav['categoria'] ?? 'Favorito', style: const TextStyle(fontSize: 12)),
                                              // --- BOTÃO: INICIAR ROTA DO FAVORITO ("IR") ---
                                              // Backend: Aqui envia o nome do local para a rota
                                              trailing: ElevatedButton(
                                                onPressed: () => _iniciarRotaRapida(fav['titulo'] ?? 'Destino'),
                                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B189A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                                                child: const Text('Ir', style: TextStyle(fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                              const SizedBox(height: 8),
                              // --- BOTÃO: VER TODOS OS FAVORITOS (LINK TEXTO) ---
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: TextButton.icon(
                                  onPressed: _verFavoritos,
                                  icon: const Icon(Icons.arrow_forward, color: Color(0xFF5B189A), size: 16),
                                  label: const Text('Ver todos os favoritos', style: TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ==========================================
                              // SESSÃO DO HISTÓRICO DA ÚLTIMA ROTA
                              // ==========================================
                              // --- BOTÃO: TÍTULO DO HISTÓRICO (Ver tudo) ---
                              GestureDetector(
                                onTap: _abrirHistorico,
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Row(
                                    children: [
                                      Icon(Icons.history, color: Color(0xFF5B189A), size: 16),
                                      SizedBox(width: 8),
                                      Text('Última Rota', style: TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold, fontSize: 18)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              (ultimaRota == null)
                                  ? Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(horizontal: 6),
                                      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 16),
                                      decoration: BoxDecoration(color: const Color(0xFFD0D0D0), borderRadius: BorderRadius.circular(8)),
                                      child: const Center(child: Text('Você ainda não fez nenhuma rota', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF5B189A), fontSize: 18, fontWeight: FontWeight.bold))),
                                    )
                                  // CARD DE RESUMO DA ÚLTIMA ROTA
                                  : Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 6),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))]),
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
                                                Text(ultimaRota!['data'] ?? "Recente", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                                                const Spacer(),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(color: const Color(0xFFFFD200), borderRadius: BorderRadius.circular(8)),
                                                  child: Text(ultimaRota!['xp_ganho'] ?? "+0 XP", style: const TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold, fontSize: 12)),
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
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(ultimaRota!['origem'] ?? "Origem", style: const TextStyle(color: Colors.grey, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                      const SizedBox(height: 18),
                                                      Text(ultimaRota!['destino'] ?? "Destino", style: const TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
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