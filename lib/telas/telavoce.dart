import 'dart:convert';
import 'dart:io'; 
import 'package:deslock/componentes/menulateral.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; 

import 'telaadicionaramigos.dart'; 

class TelaVoce extends StatefulWidget {
  const TelaVoce({super.key});

  @override
  State<TelaVoce> createState() => _TelaVoceState();
}

class _TelaVoceState extends State<TelaVoce> {
  String nome = 'Usuário';
  String usuario = '@usuario';
  String? _caminhoFoto; 

  int nivel = 1;
  int xpAtual = 0;
  int xpMaximo = 200;

  bool carregando = true;
  List<Map<String, dynamic>> listaDeAmigos = [];

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

  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();

    final nomeSalvo = prefs.getString('nome_usuario');
    final usuarioSalvo = prefs.getString('user_usuario');
    final fotoSalva = prefs.getString('foto_perfil'); 
    final amigosSalvosJson = prefs.getString('lista_amigos');

    if (!mounted) return;

    setState(() {
      nome = (nomeSalvo != null && nomeSalvo.trim().isNotEmpty) ? nomeSalvo.trim() : 'Usuário';
      usuario = _formatarUsuario(usuarioSalvo ?? '');
      _caminhoFoto = fotoSalva; 
      nivel = prefs.getInt('nivel_usuario') ?? 1;
      xpAtual = prefs.getInt('xp_atual') ?? 0;
      xpMaximo = prefs.getInt('xp_maximo') ?? 200;
      
      if (amigosSalvosJson != null) {
        final List<dynamic> listaDecodificada = jsonDecode(amigosSalvosJson);
        listaDeAmigos = listaDecodificada.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        listaDeAmigos = [
          {'nome': 'Luiz Fernando', 'usuario': '@Prizrak', 'nivel': 100},
          {'nome': 'Matheus', 'usuario': '@Bombado', 'nivel': 24},
          {'nome': 'Pietro', 'usuario': '@Pierre', 'nivel': 50},
          {'nome': 'Julia Vitória', 'usuario': '@Juju', 'nivel': 4},
          {'nome': 'Ana Beatriz', 'usuario': '@Aninha', 'nivel': 2},
          {'nome': 'Lucas', 'usuario': '@Mascote', 'nivel': 0},
        ];
        _salvarAmigos();
      }
      
      prefs.setInt('amigos_total', listaDeAmigos.length);
      carregando = false;
    });
  }

  
  void _mostrarOpcoesFoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF3C096C), // Roxo escuro do tema
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10))),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFFFFD200)),
                title: const Text('Escolher da Galeria', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context); // Fecha o menu
                  _escolherFoto(); // Abre a galeria
                },
              ),
              // Só mostra a opção de remover se ele tiver uma foto!
              if (_caminhoFoto != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  title: const Text('Remover Foto', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    _removerFoto();
                  },
                ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // Função para abrir a galeria
  Future<void> _escolherFoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _caminhoFoto = image.path;
      });
      await prefs.setString('foto_perfil', image.path);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sua foto de perfil foi atualizada com sucesso!'), backgroundColor: Color(0xFF188C0C))
      );
    }
  }

  // NOVO: Função que remove a foto do SharedPreferences
  Future<void> _removerFoto() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _caminhoFoto = null; // Tira a imagem da tela
    });
    
    await prefs.remove('foto_perfil'); // Apaga do banco local
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Foto de perfil removida.'), backgroundColor: Color(0xFF5B189A))
    );
  }

  Future<void> _salvarAmigos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lista_amigos', jsonEncode(listaDeAmigos));
    await prefs.setInt('amigos_total', listaDeAmigos.length);
  }

  void _mostrarDialogoConfirmacao(int index) {
    final nomeAmigo = listaDeAmigos[index]['nome'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF3C096C), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFFFD200)),
              SizedBox(width: 8),
              Text('Remover Amigo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Tem certeza que deseja remover $nomeAmigo da sua lista de amigos?',
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); 
                _removerAmigo(index);   
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('Remover', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _removerAmigo(int index) async {
    final nomeAmigo = listaDeAmigos[index]['nome'];
    
    setState(() {
      listaDeAmigos.removeAt(index);
    });
    
    await _salvarAmigos();
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$nomeAmigo foi removido da sua lista de amigos.'),
        backgroundColor: const Color(0xFF3C096C),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double progressoNivel = xpMaximo > 0 ? (xpAtual / xpMaximo).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      drawer: const MenuLateral(),
      backgroundColor: const Color(0xFF5B189A),
      body: Builder(
        builder: (context) {
          if (carregando) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD200)));
          }

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: _carregarDados,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CABEÇALHO DOURADO
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                      decoration: BoxDecoration(gradient: _gradienteDourado),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () => Scaffold.of(context).openDrawer(),
                            icon: const Icon(Icons.menu, color: Color(0xFF5B189A), size: 24),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Column(
                                children: [
                                  Text(nome, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5B189A))),
                                  const SizedBox(height: 2),
                                  Text(usuario, style: const TextStyle(color: Color(0xFF5B189A), fontSize: 14)),
                                ],
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              // MODIFICADO: Agora chama o _mostrarOpcoesFoto() em vez de _escolherFoto() direto
                              GestureDetector(
                                onTap: _mostrarOpcoesFoto,
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 26,
                                      backgroundColor: const Color(0xFFD9D9D9),
                                      backgroundImage: _caminhoFoto != null ? FileImage(File(_caminhoFoto!)) : null,
                                      child: _caminhoFoto == null ? const Icon(Icons.person, color: Colors.white, size: 30) : null,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(color: Color(0xFF5B189A), shape: BoxShape.circle),
                                        child: const Icon(Icons.edit, color: Colors.white, size: 12), // Mudei para lápis (edit)
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Nível $nivel', style: const TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CARD DE PROGRESSO
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(gradient: _gradienteDourado, borderRadius: const BorderRadius.vertical(top: Radius.circular(8))),
                            child: const Row(
                              children: [
                                Icon(Icons.arrow_upward, color: Color(0xFF5B189A), size: 18),
                                SizedBox(width: 8),
                                Text('Nível', style: TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold, fontSize: 18)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Color(0xFF5B189A), size: 28),
                                    const SizedBox(width: 8),
                                    Text('XP: $xpAtual/$xpMaximo', style: const TextStyle(color: Color(0xFF5B189A), fontSize: 18, fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    Text('Nível $nivel', style: const TextStyle(color: Color(0xFF5B189A), fontSize: 18, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: LinearProgressIndicator(
                                          value: progressoNivel,
                                          minHeight: 20,
                                          backgroundColor: const Color(0xFF3C096C),
                                          valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD200)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text('Nível ${nivel + 1}', style: const TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CARD DE AMIGOS
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.people_outline, color: Color(0xFF5B189A)),
                              const SizedBox(width: 8),
                              Text(
                                'Amigos (${listaDeAmigos.length})',
                                style: const TextStyle(color: Color(0xFF5B189A), fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              
                              InkWell(
                                onTap: () async {
                                  final atualizouBanco = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const TelaAdicionarAmigos()),
                                  );

                                  if (atualizouBanco == true) {
                                    _carregarDados();
                                  }
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(gradient: _gradienteDourado, shape: BoxShape.circle),
                                  child: const Icon(Icons.person_add, color: Color(0xFF5B189A), size: 18),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (listaDeAmigos.isEmpty)
                            const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Sua lista de amigos está vazia.', style: TextStyle(color: Colors.grey))))
                          else
                            ...listaDeAmigos.asMap().entries.map((entry) {
                              int index = entry.key;
                              var amigo = entry.value;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    const CircleAvatar(radius: 20, backgroundColor: Color(0xFFD9D9D9), child: Icon(Icons.person, color: Colors.white)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(amigo['nome'].toString(), style: const TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          Text(amigo['usuario'].toString(), style: const TextStyle(color: Colors.black54, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: const Color(0xFF5B189A).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                      child: Text('Nível ${amigo['nivel'] ?? '1'}', style: const TextStyle(color: Color(0xFF5B189A), fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      onPressed: () => _mostrarDialogoConfirmacao(index),
                                      tooltip: 'Remover amigo',
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}