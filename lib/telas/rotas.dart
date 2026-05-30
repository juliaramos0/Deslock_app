import 'dart:convert';
import 'dart:typed_data'; // NOVO: Para lidar com a foto em memória (Base64)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'telafavoritos.dart';
import 'telabase.dart'; 
import 'telanavegacaoativa.dart'; 
import 'telahistorico.dart'; 

class TelaRotas extends StatefulWidget {
  const TelaRotas({super.key});

  @override
  State<TelaRotas> createState() => _TelaRotasState();
}

class _TelaRotasState extends State<TelaRotas> {
  // Backend: Estes controllers guardam os inputs atuais do utilizador.
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _origemController = TextEditingController(text: "Sua localização atual");

  bool _mostrarCardDestino = false;
  String _nomeDestinoPesquisado = "Escola Profissional Santo Agostinho";
  String _modoSelecionado = 'carro'; // Backend: Modo padrão de transporte
  
  // LÓGICA DE FOTO BASE64
  Uint8List? _bytesFoto; 

  final Gradient _gradienteDourado = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD200), Color(0xFFDDA300)],
  );

  @override
  void initState() {
    super.initState();
    _carregarFoto();
  }

  // Função atualizada para ler Base64
  Future<void> _carregarFoto() async {
    final prefs = await SharedPreferences.getInstance();
    final fotoSalvaBase64 = prefs.getString('foto_perfil_base64');
    
    if (fotoSalvaBase64 != null && fotoSalvaBase64.isNotEmpty) {
      setState(() {
        _bytesFoto = base64Decode(fotoSalvaBase64);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _origemController.dispose(); 
    super.dispose();
  }

  void _mostrarAviso(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // AÇÃO DO EVENTO: "Pesquisar"
  // Backend: Esta função é acionada ao dar enter num campo. Idealmente chamará a API de geocodificação aqui.
  void _pesquisarLocal(String valor) {
    if (valor.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _searchController.text = valor; 
      _nomeDestinoPesquisado = valor;
      _mostrarCardDestino = true;
    });
  }

  // AÇÃO DO BOTÃO: "Limpar/Seta Voltar"
  // Backend: Cancela a pesquisa atual e recolhe a interface de rota.
  void _limparPesquisa() {
    setState(() {
      _searchController.clear();
      _origemController.text = "Sua localização atual"; 
      _mostrarCardDestino = false;
    });
    FocusScope.of(context).unfocus();
  }

  // COMPONENTE: "Botão de Modo de Transporte"
  // Backend: Atualiza a variável '_modoSelecionado' que será passada para a rota.
  Widget _botaoModo(IconData icone, String modo) {
    bool selecionado = _modoSelecionado == modo;
    return GestureDetector(
      onTap: () => setState(() => _modoSelecionado = modo),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selecionado ? const Color(0xFFFFD200) : Colors.white24,
          shape: BoxShape.circle,
          boxShadow: selecionado ? [const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))] : [],
        ),
        child: Icon(icone, color: selecionado ? const Color(0xFF5B189A) : Colors.white, size: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            // MAPA DE FUNDO (MOCK)
            Container(width: double.infinity, height: double.infinity, color: const Color(0xFFEAEAEA)),
            Positioned.fill(child: CustomPaint(painter: _MapaRotasPainter())),

            // PINO CENTRAL DO MAPA
            // Backend: Tocar num local no mapa (quando real) deve disparar a função abaixo.
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _pesquisarLocal("Parque Central");
                  });
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, size: 50, color: Color(0xFF5B189A)),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            
            // ==========================================
            // CABEÇALHO SUPERIOR INTELIGENTE (ESTILO GOOGLE MAPS)
            // ==========================================
            Positioned(
              top: 0, left: 0, right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: _gradienteDourado, 
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)), 
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // SE NÃO ESTIVER EM MODO ROTA: Mostra barra simples + Foto de Perfil
                        if (!_mostrarCardDestino) ...[
                          Row(
                            children: [
                              Expanded(child: _buildSearchBar()),
                              const SizedBox(width: 16),
                              
                              // --- BOTÃO: ABRIR PERFIL (AVATAR) ---
                              // Backend: Navegação simples para a tab Perfil
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const TelaBase(initialIndex: 2)), (route) => false);
                                },
                                child: CircleAvatar(
                                  radius: 22, 
                                  backgroundColor: Colors.white, 
                                  // Renderiza a foto em Base64
                                  backgroundImage: _bytesFoto != null ? MemoryImage(_bytesFoto!) : null,
                                  child: _bytesFoto == null ? const Icon(Icons.person, color: Color(0xFF5B189A)) : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                // --- BOTÃO FILTRO: FAVORITOS ---
                                _filtro(icon: Icons.favorite_border, texto: "Favoritos", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaFavoritos()))),
                                const SizedBox(width: 10),
                                // --- BOTÃO FILTRO: HISTÓRICO ---
                                _filtro(icon: Icons.history, texto: "Histórico", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaHistorico()))),
                              ],
                            ),
                          ),
                        ] 
                        // SE ESTIVER EM MODO ROTA: Expande o cabeçalho em duas caixas 
                        else ...[
                          Row(
                            children: [
                              // --- BOTÃO: VOLTAR ---
                              IconButton(
                                icon: const Icon(Icons.arrow_back, color: Color(0xFF5B189A)),
                                onPressed: _limparPesquisa,
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                  ),
                                  child: Row(
                                    children: [
                                      Column(
                                        children: [
                                          const Icon(Icons.radio_button_checked, color: Color(0xFF5B189A), size: 16),
                                          Container(height: 24, width: 2, color: Colors.black12),
                                          const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                                        ],
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            // --- CAMPO: PONTO DE PARTIDA (MANUAL) ---
                                            // Backend: Ler valor deste TextField para 'origem' da rota via API
                                            SizedBox(
                                              height: 30,
                                              child: TextField(
                                                controller: _origemController,
                                                style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
                                                decoration: const InputDecoration(
                                                  hintText: "Escolher ponto de partida",
                                                  hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                                                  border: InputBorder.none,
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.zero,
                                                ),
                                              ),
                                            ),
                                            const Divider(height: 10, color: Colors.black12),
                                            // --- CAMPO: DESTINO (MANUAL) ---
                                            // Backend: Ler valor deste TextField para 'destino' da rota via API
                                            SizedBox(
                                              height: 30,
                                              child: TextField(
                                                controller: _searchController,
                                                onSubmitted: _pesquisarLocal,
                                                style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
                                                decoration: const InputDecoration(
                                                  hintText: "Escolher destino",
                                                  hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                                                  border: InputBorder.none,
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.zero,
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
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ==========================================
            // MIRA DO GPS (FAB)
            // ==========================================
            // --- BOTÃO FLUTUANTE: MINHA LOCALIZAÇÃO ---
            // Backend: Ao pressionar deve recentrar o mapa atualizando as coords GPS reais
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutQuart,
              right: 16,
              bottom: _mostrarCardDestino ? 350 : 100, 
              child: FloatingActionButton(
                heroTag: 'btn_gps',
                onPressed: () => _mostrarAviso('Centralizando mapa na sua localização...'),
                backgroundColor: Colors.white,
                mini: true,
                child: const Icon(Icons.my_location, color: Color(0xFF5B189A)),
              ),
            ),

            // ==========================================
            // CARD DO DESTINO (INICIAR ROTA)
            // ==========================================
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutQuart,
              left: 16, right: 16,
              bottom: _mostrarCardDestino ? 80 : -600, 
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF5B189A), borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FOTO DO DESTINO (API Image)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Escola.jpg/640px-Escola.jpg",
                        height: 100, width: double.infinity, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(height: 100, color: Colors.white24, child: const Center(child: Icon(Icons.location_city, color: Colors.white, size: 40))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Text(
                      _nomeDestinoPesquisado, 
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    
                    const Text("Como pretende deslocar-se?", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    
                    // SELETOR DE MODOS (Bicicleta, Pé, etc)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _botaoModo(Icons.directions_car, 'carro'),
                        _botaoModo(Icons.directions_bus, 'onibus'),
                        _botaoModo(Icons.directions_walk, 'pe'),
                        _botaoModo(Icons.pedal_bike, 'bicicleta'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // --- BOTÃO PRINCIPAL: INICIAR ROTA ---
                    // Backend: Recolhe a Origem, Destino e Modo Selecionado, passa para o ecrã Navegacao Ativa, que deverá traçar/chamar rota final.
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (_) => TelaNavegacaoAtiva(
                                origem: _origemController.text, // ENVIANDO A ORIGEM EDITADA
                                destino: _searchController.text, // ENVIANDO O DESTINO EDITADO
                                modo: _modoSelecionado,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD200), foregroundColor: const Color(0xFF5B189A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                        icon: const Icon(Icons.directions, size: 18),
                        label: const Text('Iniciar Rota', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CONSTRUTOR: BARRA DE PESQUISA (Estado Não-Expandido)
  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: TextField(
        controller: _searchController,
        onSubmitted: _pesquisarLocal, 
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: "Para onde vamos?",
          hintStyle: const TextStyle(color: Colors.black38),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF5B189A)),
          // --- BOTÃO (NO CAMPO): LIMPAR (X) ---
          suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: Colors.black38), onPressed: _limparPesquisa) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (text) => setState(() {}),
      ),
    );
  }

  // CONSTRUTOR: BOTOES TIPO FILTRO/ATALHO (Favoritos / Historico)
  Widget _filtro({required IconData icon, required String texto, required VoidCallback onTap}) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: const Color(0xFF5B189A)),
      label: Text(texto, style: const TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.9), side: const BorderSide(color: Color(0xFF5B189A), width: 1.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
    );
  }
}

// MOCK: Pintura manual para representar um mapa estático na interface enquanto não há API GoogleMaps.
class _MapaRotasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rua = Paint()..color = Colors.white..strokeWidth = 8..style = PaintingStyle.stroke;
    for (double y = 100; y < size.height; y += 150) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 50), rua);
    }
    for (double x = 50; x < size.width; x += 120) {
      canvas.drawLine(Offset(x, 0), Offset(x - 30, size.height), rua);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}