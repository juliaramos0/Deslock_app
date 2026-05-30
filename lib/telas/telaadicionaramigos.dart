import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaAdicionarAmigos extends StatefulWidget {
  const TelaAdicionarAmigos({super.key});

  @override
  State<TelaAdicionarAmigos> createState() => _TelaAdicionarAmigosState();
}

class _TelaAdicionarAmigosState extends State<TelaAdicionarAmigos> {
  final TextEditingController _buscaController = TextEditingController();
  bool _buscando = false;
  bool _houveAlteracao = false; 

  final Gradient _gradienteDourado = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD200), Color(0xFFDDA300)],
  );

  List<Map<String, dynamic>> pedidosRecebidos = [
    {'nome': 'Victoria Vieria', 'usuario': '@Vivi', 'nivel': 4, 'estado': 'normal'},
  ];

  // Controle de 'estado' para cada sugestão
  List<Map<String, dynamic>> sugestoes = [
    {'nome': 'Laryssa Silva', 'usuario': '@Lary', 'nivel': 2, 'estado': 'normal'},
    {'nome': 'Maria Luiza', 'usuario': '@Malu', 'nivel': 5, 'estado': 'normal'},
    {'nome': 'Cristofer', 'usuario': '@Mochilão', 'nivel': 1, 'estado': 'normal'},
  ];

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  // Função interna mais segura para converter e salvar no banco local
  Future<void> _salvarAmigoNoBanco(Map<String, dynamic> novoAmigo) async {
    final prefs = await SharedPreferences.getInstance();
    final amigosSalvosJson = prefs.getString('lista_amigos');
    
    // CORREÇÃO DE TIPAGEM: Garante que o banco trabalhe com os tipos corretos
    List<Map<String, dynamic>> listaDeAmigos = [];

    if (amigosSalvosJson != null) {
      final List<dynamic> listaDecodificada = jsonDecode(amigosSalvosJson);
      listaDeAmigos = listaDecodificada.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    // Adiciona o novo amigo na lista existente
    listaDeAmigos.add({
      'nome': novoAmigo['nome'],
      'usuario': novoAmigo['usuario'],
      'nivel': novoAmigo['nivel'],
    });

    // Salva de volta no SharedPreferences
    await prefs.setString('lista_amigos', jsonEncode(listaDeAmigos));
    await prefs.setInt('amigos_total', listaDeAmigos.length);
    _houveAlteracao = true;
  }

  // LÓGICA DINÂMICA E PROTEGIDA: Aceita o pedido sem perder o índice
  void _aceitarPedido(int index) async {
    // 1. Salva a referência exata do amigo ANTES de começar o delay assíncrono!
    final amigo = pedidosRecebidos[index];

    setState(() {
      amigo['estado'] = 'carregando';
    });

    // Simula 1.2 segundos de resposta do servidor
    await Future.delayed(const Duration(milliseconds: 1200));

    await _salvarAmigoNoBanco(amigo);

    setState(() {
      // 2. Remove pelo OBJETO, e não pelo índice (isso evita crashes se o usuário clicar 2x rápido)
      pedidosRecebidos.remove(amigo); 
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Você e ${amigo['nome']} agora são amigos!')),
    );
  }

  void _recusarPedido(int index) {
    setState(() {
      pedidosRecebidos.removeAt(index);
    });
  }

  // LÓGICA DINÂMICA E PROTEGIDA: Envia o convite com segurança
  void _enviarConvite(int index) async {
    // Salva a referência ANTES do delay
    final amigo = sugestoes[index];

    setState(() {
      amigo['estado'] = 'carregando';
    });

    // Simula 1.2 segundos de resposta do servidor
    await Future.delayed(const Duration(milliseconds: 1200));

    await _salvarAmigoNoBanco(amigo);

    setState(() {
      amigo['estado'] = 'adicionado'; // Muda o estado visual do botão
    });
  }

  void _realizarBusca(String valor) async {
    if (valor.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _buscando = true;
    });
    await Future.delayed(const Duration(seconds: 1)); 
    if (mounted) {
      setState(() {
        _buscando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF5B189A),
        appBar: AppBar(
          flexibleSpace: Container(decoration: BoxDecoration(gradient: _gradienteDourado)),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF5B189A)),
            onPressed: () => Navigator.pop(context, _houveAlteracao),
          ),
          elevation: 0,
          centerTitle: true,
          title: const Text('Adicionar Amigos', style: TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold)),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Color(0xFF3C096C), borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                  child: TextField(
                    controller: _buscaController,
                    onSubmitted: _realizarBusca,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: "Buscar por @usuario ou nome",
                      hintStyle: const TextStyle(color: Colors.black38),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF5B189A)),
                      suffixIcon: _buscaController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: Colors.black38), onPressed: () { _buscaController.clear(); setState(() {}); }) : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (text) => setState(() {}),
                  ),
                ),
              ),
              Expanded(
                child: _buscando
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD200)))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (pedidosRecebidos.isNotEmpty) ...[
                              const _TituloSecao('Pedidos Recebidos'),
                              const SizedBox(height: 12),
                              ...pedidosRecebidos.asMap().entries.map((entry) {
                                int idx = entry.key;
                                var pedido = entry.value;
                                return _CardUsuario(
                                  nome: pedido['nome'],
                                  usuario: pedido['usuario'],
                                  nivel: pedido['nivel'],
                                  botoesAcao: pedido['estado'] == 'carregando'
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFFFFD200), strokeWidth: 2))
                                    : Row(
                                        children: [
                                          InkWell(onTap: () => _recusarPedido(idx), borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.red, size: 20))),
                                          const SizedBox(width: 12),
                                          InkWell(onTap: () => _aceitarPedido(idx), borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle), child: const Icon(Icons.check, color: Colors.green, size: 20))),
                                        ],
                                      ),
                                );
                              }),
                              const SizedBox(height: 24),
                            ],
                            _TituloSecao(_buscaController.text.isNotEmpty ? 'Resultados da busca' : 'Pessoas que talvez você conheça'),
                            const SizedBox(height: 12),
                            ...sugestoes.asMap().entries.map((entry) {
                              int idx = entry.key;
                              var sugerido = entry.value;
                              String estado = sugerido['estado'];

                              Widget widgetBotao;
                              if (estado == 'carregando') {
                                widgetBotao = const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFFFFD200), strokeWidth: 2));
                              } else if (estado == 'adicionado') {
                                widgetBotao = Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(16)),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.check, color: Colors.white, size: 14),
                                      SizedBox(width: 4),
                                      Text('Amigo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ],
                                  ),
                                );
                              } else {
                                widgetBotao = SizedBox(
                                  height: 32,
                                  child: ElevatedButton(
                                    onPressed: () => _enviarConvite(idx),
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B189A), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(horizontal: 16)),
                                    child: const Text('Adicionar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                );
                              }

                              return _CardUsuario(
                                nome: sugerido['nome'],
                                usuario: sugerido['usuario'],
                                nivel: sugerido['nivel'],
                                botoesAcao: widgetBotao,
                              );
                            }),
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

class _TituloSecao extends StatelessWidget {
  final String texto;
  const _TituloSecao(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        Text(texto, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)), 
        const SizedBox(height: 4), 
        Container(
          width: 40, 
          height: 3, 
          decoration: BoxDecoration(
            color: const Color(0xFFFFD200), 
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _CardUsuario extends StatelessWidget {
  final String nome;
  final String usuario;
  final int nivel;
  final Widget botoesAcao;
  const _CardUsuario({required this.nome, required this.usuario, required this.nivel, required this.botoesAcao});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const CircleAvatar(radius: 24, backgroundColor: Color(0xFFD9D9D9), child: Icon(Icons.person, color: Colors.white, size: 28)),
              Positioned(bottom: -4, right: -4, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Color(0xFFFFD200), shape: BoxShape.circle), child: Text('$nivel', style: const TextStyle(color: Color(0xFF5B189A), fontSize: 10, fontWeight: FontWeight.bold)))),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(nome, style: const TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis), Text(usuario, style: const TextStyle(color: Colors.black54, fontSize: 13))])),
          botoesAcao,
        ],
      ),
    );
  }
}