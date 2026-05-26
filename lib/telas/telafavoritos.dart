import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'telanovofavorito.dart';
import 'telanavegacaoativa.dart'; 

class TelaFavoritos extends StatefulWidget {
  const TelaFavoritos({super.key});

  @override
  State<TelaFavoritos> createState() => _TelaFavoritosState();
}

class _TelaFavoritosState extends State<TelaFavoritos> {
  // CONSTANTE DO GRADIENTE DOURADO
  final Gradient _gradienteDourado = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD200), Color(0xFFDDA300)],
  );

  List<Map<String, dynamic>> favoritos = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarFavoritos();
  }

  Future<void> _carregarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final stringFavoritos = prefs.getString('lista_favoritos');

    if (stringFavoritos != null) {
      final List<dynamic> listaDecodificada = jsonDecode(stringFavoritos);
      setState(() {
        favoritos = listaDecodificada.map((e) => Map<String, dynamic>.from(e)).toList();
        carregando = false;
      });
    } else {
      setState(() {
        favoritos = [
          {
            'titulo': 'Escola Profissional Santo Agostinho',
            'categoria': 'Instituição educacional',
            'tempo': '23min',
            'distancia': '5,6km · 12:50',
            'avaliacao': '(1000)',
            'segura': 'Segura',
          },
          {
            'titulo': 'Parque Ecológico Central',
            'categoria': 'Parque e Lazer',
            'tempo': '15min',
            'distancia': '3,2km · 10:20',
            'avaliacao': '(850)',
            'segura': 'Segura',
          },
          {
            'titulo': 'Biblioteca Municipal',
            'categoria': 'Cultura e Educação',
            'tempo': '8min',
            'distancia': '1,5km · 08:00',
            'avaliacao': '(420)',
            'segura': 'Segura',
          },
        ];
        carregando = false;
      });
      await _salvarFavoritos();
    }
  }

  Future<void> _salvarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final stringFavoritos = jsonEncode(favoritos);
    await prefs.setString('lista_favoritos', stringFavoritos);
  }

  void _mostrarAviso(String mensagem) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  void _removerFavorito(int index) async {
    setState(() {
      favoritos.removeAt(index);
    });
    await _salvarFavoritos();
    _mostrarAviso('Favorito removido da lista');
  }

  // MODIFICADO: Agora recebe o destino E o modo de transporte escolhido!
  void _iniciarRotaDireta(String destino, String modo) {
    _mostrarAviso('Iniciando rota segura para $destino...');
    
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TelaNavegacaoAtiva(
            destino: destino,
            modo: modo, // Repassa a escolha para a tela do GPS
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFEAEAEA),
        body: SafeArea(
          child: carregando 
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF5B189A)))
            : Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 14),
                decoration: BoxDecoration(gradient: _gradienteDourado),
                child: Column(
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 6,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_back,
                                  color: Color(0xFF5B189A),
                                  size: 20,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Voltar',
                                  style: TextStyle(
                                    color: Color(0xFF5B189A),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Favoritos',
                              style: TextStyle(
                                color: Color(0xFF5B189A),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 52),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAEAEA),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: TextField(
                        textInputAction: TextInputAction.search,
                        onSubmitted: (valor) {
                          if (valor.trim().isNotEmpty) {
                            _mostrarAviso('Buscando por: $valor');
                            FocusScope.of(context).unfocus();
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: 'Buscar destino favorito',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.favorite_border,
                            color: Color(0xFF5B189A),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Seus favoritos',
                            style: TextStyle(
                              color: Color(0xFF5B189A),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 80,
                            height: 1.3,
                            color: const Color(0xFF5B189A),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () async {
                              final novoFavorito = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TelaNovoFavorito(),
                                ),
                              );

                              if (novoFavorito != null) {
                                setState(() {
                                  favoritos.insert(0, novoFavorito); 
                                });
                                await _salvarFavoritos();
                              }
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFF5B189A),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      
                      if (favoritos.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Text(
                            "Nenhum favorito encontrado.",
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      else
                        for (int i = 0; i < favoritos.length; i++) ...[
                          _CardFavorito(
                            titulo: favoritos[i]['titulo']!,
                            categoria: favoritos[i]['categoria']!,
                            tempo: favoritos[i]['tempo']!,
                            distancia: favoritos[i]['distancia']!,
                            avaliacao: favoritos[i]['avaliacao']!,
                            segura: favoritos[i]['segura']!,
                            onDetalhes: () => _mostrarAviso('Abrindo detalhes de ${favoritos[i]['titulo']}...'),
                            onExcluir: () => _removerFavorito(i),
                            // Agora passa a string do modo escolhido na chamada
                            onIniciar: (String modo) => _iniciarRotaDireta(favoritos[i]['titulo']!, modo), 
                          ),
                          const SizedBox(height: 14),
                        ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// MODIFICADO: Agora é um StatefulWidget para guardar qual modo foi clicado neste card específico
class _CardFavorito extends StatefulWidget {
  final String titulo;
  final String categoria;
  final String tempo;
  final String distancia;
  final String avaliacao;
  final String segura;
  final VoidCallback onExcluir;
  final Function(String modo) onIniciar; // Função atualizada para exigir a string do transporte
  final VoidCallback onDetalhes;

  const _CardFavorito({
    required this.titulo,
    required this.categoria,
    required this.tempo,
    required this.distancia,
    required this.avaliacao,
    required this.segura,
    required this.onExcluir,
    required this.onIniciar,
    required this.onDetalhes,
  });

  @override
  State<_CardFavorito> createState() => _CardFavoritoState();
}

class _CardFavoritoState extends State<_CardFavorito> {
  // Guarda a seleção local deste card. Padrão: carro
  String _modoSelecionado = 'carro';

  // Componente interno para desenhar as bolinhas de transporte
  Widget _botaoModo(IconData icone, String modo) {
    bool selecionado = _modoSelecionado == modo;
    return GestureDetector(
      onTap: () => setState(() => _modoSelecionado = modo),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selecionado ? const Color(0xFFFFD200) : Colors.white24,
          shape: BoxShape.circle,
          boxShadow: selecionado ? [const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))] : [],
        ),
        child: Icon(
          icone,
          color: selecionado ? const Color(0xFF5B189A) : Colors.white,
          size: 22,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF5B189A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFD200), Color(0xFFDDA300)],
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFF5B189A),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.segura,
                  style: const TextStyle(
                    color: Color(0xFF5B189A),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: widget.onExcluir,
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.delete_outline,
                      color: Color(0xFF5B189A),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          InkWell(
            onTap: widget.onDetalhes,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 108,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/escola_epsa.jpg'),
                        fit: BoxFit.cover,
                        onError: null,
                      ),
                      color: const Color(0xFFD9D9D9),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.titulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFFD200), size: 16),
                      const Icon(Icons.star, color: Color(0xFFFFD200), size: 16),
                      const Icon(Icons.star, color: Color(0xFFFFD200), size: 16),
                      const Icon(Icons.star, color: Color(0xFFFFD200), size: 16),
                      const Icon(Icons.star, color: Color(0xFFFFD200), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        widget.avaliacao,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.tempo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        widget.categoria,
                        style: const TextStyle(
                          color: Color(0xFFD7D7D7),
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.distancia,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  
                  // NOVO: Seletores de Transporte
                  const SizedBox(height: 14),
                  const Text(
                    "Como pretende deslocar-se?",
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _botaoModo(Icons.directions_car, 'carro'),
                      _botaoModo(Icons.directions_bus, 'onibus'),
                      _botaoModo(Icons.directions_walk, 'pe'),
                      _botaoModo(Icons.pedal_bike, 'bicicleta'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton.icon(
                      // Passa a escolha atual do usuário de volta para a função principal
                      onPressed: () => widget.onIniciar(_modoSelecionado),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF5B189A),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      icon: const Icon(
                        Icons.play_arrow,
                        size: 16,
                      ),
                      label: const Text(
                        'Iniciar Rota',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
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