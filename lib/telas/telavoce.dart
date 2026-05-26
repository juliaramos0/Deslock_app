import 'dart:convert'; 
import 'package:deslock/componentes/menulateral.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'telaadicionaramigos.dart'; 

class TelaVoce extends StatefulWidget {
  const TelaVoce({super.key});

  @override
  State<TelaVoce> createState() => _TelaVoceState();
}

class _TelaVoceState extends State<TelaVoce> {
  String nome = 'Usuário';
  String usuario = '@usuario';

  int nivel = 1;
  int xpAtual = 0;
  int xpMaximo = 200;

  bool carregando = true;
  
  // CORREÇÃO: Tipagem alterada para dynamic para aceitar int e String sem quebrar o app
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
    final amigosSalvosJson = prefs.getString('lista_amigos');

    if (!mounted) return;

    setState(() {
      nome = (nomeSalvo != null && nomeSalvo.trim().isNotEmpty) ? nomeSalvo.trim() : 'Usuário';
      usuario = _formatarUsuario(usuarioSalvo ?? '');
      nivel = prefs.getInt('nivel_usuario') ?? 1;
      xpAtual = prefs.getInt('xp_atual') ?? 0;
      xpMaximo = prefs.getInt('xp_maximo') ?? 200;
      
      // CORREÇÃO: Mapeamento seguro convertendo os mapas internos para dynamic
      if (amigosSalvosJson != null) {
        final List<dynamic> listaDecodificada = jsonDecode(amigosSalvosJson);
        listaDeAmigos = listaDecodificada.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        // Lista padrão inicial com tipos mistos (String e int)
        listaDeAmigos = [
          {'nome': 'Pietro', 'usuario': '@Pierre', 'nivel': 3},
          {'nome': 'Julia Vitória', 'usuario': '@Júju', 'nivel': 4},
          {'nome': 'Ana Beatriz', 'usuario': '@Aninha', 'nivel': 2},
        ];
        _salvarAmigos();
      }
      
      // Atualiza o contador de amigos total para a TelaInicio usar
      prefs.setInt('amigos_total', listaDeAmigos.length);

      carregando = false;
    });
  }

  Future<void> _salvarAmigos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lista_amigos', jsonEncode(listaDeAmigos));
    await prefs.setInt('amigos_total', listaDeAmigos.length);
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
                              const CircleAvatar(radius: 24, backgroundColor: Color(0xFFD9D9D9), child: Icon(Icons.person, color: Colors.white, size: 30)),
                              const SizedBox(height: 4),
                              Text('Nível $nivel', style: const TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.w500)),
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
                                  final novoAmigo = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const TelaAdicionarAmigos()),
                                  );

                                  if (novoAmigo != null) {
                                    setState(() {
                                      listaDeAmigos.add(novoAmigo);
                                    });
                                    await _salvarAmigos(); 
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
                            ...listaDeAmigos.map((amigo) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    const CircleAvatar(radius: 20, backgroundColor: Color(0xFFD9D9D9), child: Icon(Icons.person, color: Colors.white)),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(amigo['nome'].toString(), style: const TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold, fontSize: 15)),
                                        Text(amigo['usuario'].toString(), style: const TextStyle(color: Colors.black54, fontSize: 13)),
                                      ],
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: const Color(0xFF5B189A).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                      // CORREÇÃO: .toString() para garantir a renderização de int ou String com segurança
                                      child: Text('Nível ${amigo['nivel'] ?? '1'}', style: const TextStyle(color: Color(0xFF5B189A), fontSize: 12, fontWeight: FontWeight.bold)),
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