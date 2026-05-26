import 'package:flutter/material.dart';

class TelaAdicionarAmigos extends StatefulWidget {
  const TelaAdicionarAmigos({super.key});

  @override
  State<TelaAdicionarAmigos> createState() => _TelaAdicionarAmigosState();
}

class _TelaAdicionarAmigosState extends State<TelaAdicionarAmigos> {
  final TextEditingController _buscaController = TextEditingController();
  bool _buscando = false;

  final Gradient _gradienteDourado = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD200), Color(0xFFDDA300)],
  );

  List<Map<String, dynamic>> pedidosRecebidos = [
    {'nome': 'Carlos Eduardo', 'usuario': '@cadu_99', 'nivel': 4},
  ];

  List<Map<String, dynamic>> sugestoes = [
    {'nome': 'Mariana Silva', 'usuario': '@mari_silva', 'nivel': 2, 'conviteEnviado': false},
    {'nome': 'Roberto Gomes', 'usuario': '@beto_g', 'nivel': 5, 'conviteEnviado': false},
    {'nome': 'Camila Costa', 'usuario': '@camila.c', 'nivel': 1, 'conviteEnviado': false},
  ];

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _mostrarAviso(String mensagem) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  // CORREÇÃO: Retorna o Map sem tipagem engessada de String para evitar conflito com dynamic
  void _aceitarPedido(int index) {
    final amigo = pedidosRecebidos[index];
    _mostrarAviso('Você e ${amigo['nome']} agora são amigos!');
    
    Navigator.pop(context, {
      'nome': amigo['nome'],
      'usuario': amigo['usuario'],
      'nivel': amigo['nivel'],
    });
  }

  void _recusarPedido(int index) {
    setState(() {
      pedidosRecebidos.removeAt(index);
    });
  }

  // CORREÇÃO: Retorna o Map estruturado corretamente
  void _enviarConvite(int index) {
    final amigo = sugestoes[index];
    _mostrarAviso('Adicionado com sucesso!');
    
    Navigator.pop(context, {
      'nome': amigo['nome'],
      'usuario': amigo['usuario'],
      'nivel': amigo['nivel'],
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
        _mostrarAviso('Buscando por: $valor');
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
          iconTheme: const IconThemeData(color: Color(0xFF5B189A)),
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
                                  botoesAcao: Row(
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
                              bool jaEnviado = sugerido['conviteEnviado'];
                              return _CardUsuario(
                                  nome: sugerido['nome'],
                                  usuario: sugerido['usuario'],
                                  nivel: sugerido['nivel'],
                                  botoesAcao: SizedBox(
                                    height: 32,
                                    child: ElevatedButton(
                                      onPressed: jaEnviado ? null : () => _enviarConvite(idx),
                                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B189A), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(horizontal: 16)),
                                      child: const Text('Adicionar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    ),
                                  ),
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
        Text(
          texto,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
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