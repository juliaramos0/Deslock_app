import 'dart:convert'; // NOVO: Para decodificar a foto
import 'dart:typed_data'; // NOVO: Para manipular a imagem na memória (Base64)
import 'package:deslock/telas/telaconta.dart';
import 'package:deslock/telas/teladeconfiguracoes.dart';
import 'package:deslock/telas/telapremium.dart';
import 'package:deslock/telas/telasobrenos.dart';
import 'package:deslock/telas/telatutorial.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuLateral extends StatefulWidget {
  const MenuLateral({super.key});

  @override
  State<MenuLateral> createState() => _MenuLateralState();
}

class _MenuLateralState extends State<MenuLateral> {
  String nome = 'Usuário';
  String usuario = '@usuario';
  
  // NOVO: Lê a imagem em formato de bytes (Base64) em vez de caminho local
  Uint8List? _bytesFoto; 
  
  bool carregando = true;

  // CONSTANTE DO GRADIENTE DOURADO
  final Gradient _gradienteDourado = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD200), Color(0xFFDDA300)],
  );

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  String _formatarUsuario(String valor) {
    final texto = valor.trim();
    if (texto.isEmpty) return '@usuario';
    return texto.startsWith('@') ? texto : '@$texto';
  }

  // Backend: Função inicial para buscar os dados de Perfil do utilizador (Nome, @, e Foto)
  Future<void> _carregarDadosUsuario() async {
    final prefs = await SharedPreferences.getInstance();

    final nomeSalvo = prefs.getString('nome_usuario');
    final usuarioSalvo = prefs.getString('user_usuario');
    
    // Lê o código Base64 da imagem
    final fotoSalvaBase64 = prefs.getString('foto_perfil_base64');

    if (!mounted) return;

    setState(() {
      nome = (nomeSalvo != null && nomeSalvo.trim().isNotEmpty)
          ? nomeSalvo.trim()
          : 'Usuário';

      usuario = _formatarUsuario(usuarioSalvo ?? '');
      
      // Decodifica o Base64 para exibir a imagem na interface
      if (fotoSalvaBase64 != null && fotoSalvaBase64.isNotEmpty) {
        _bytesFoto = base64Decode(fotoSalvaBase64);
      } else {
        _bytesFoto = null;
      }
      
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 250,
      child: Container(
        color: const Color(0xFF5B189A),
        child: SafeArea(
          child: carregando
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFFD200)),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // HEADER COM GRADIENTE DOURADO E FOTO
                    // ==========================================
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: _gradienteDourado, 
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // MODIFICADO: CircleAvatar agora mostra a foto em Base64 via MemoryImage
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFFD9D9D9),
                            backgroundImage: _bytesFoto != null ? MemoryImage(_bytesFoto!) : null,
                            child: _bytesFoto == null 
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 26,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            nome,
                            style: const TextStyle(
                              color: Color(0xFF5B189A),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            usuario,
                            style: const TextStyle(
                              color: Color(0xFF5B189A),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ==========================================
                    // LISTA DE ITENS DO MENU
                    // ==========================================
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // --- BOTÃO MENU: CONFIGURAÇÕES ---
                            // Backend: Apenas navegação para a tela de Configurações
                            _itemMenu(
                              icon: Icons.settings,
                              titulo: 'Configurações',
                              onTap: () {
                                Navigator.pop(context); // Fecha o drawer
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TelaConfiguracoes(),
                                  ),
                                );
                              },
                            ),
                            
                            // --- BOTÃO MENU: CONTA ---
                            // Backend: Navegação para a gestão da Conta do utilizador
                            _itemMenu(
                              icon: Icons.person_outline,
                              titulo: 'Conta',
                              onTap: () {
                                Navigator.pop(context); // Fecha o drawer
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TelaConta(),
                                  ),
                                );
                              },
                            ),
                            
                            // --- BOTÃO MENU: PREMIUM ---
                            // Backend: Navegação para a tela de subscrição Premium/Pagamentos
                            _itemMenu(
                              icon: Icons.attach_money,
                              titulo: 'Premium',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TelaPremium(),
                                  ),
                                );
                              },
                            ),
                            
                            // --- BOTÃO MENU: TUTORIAL ---
                            // Backend: Navegação para rever os tutoriais de Onboarding
                            _itemMenu(
                              icon: Icons.menu_book,
                              titulo: 'Tutorial',
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TelaTutorial(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ==========================================
                    // BOTÃO FIXO NA BASE
                    // ==========================================
                    // --- BOTÃO: SOBRE NÓS ---
                    // Backend: Navegação para ecrã de informações institucionais/termos
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Fecha o menu lateral
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TelaSobreNos(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Sobre Nós',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // CONSTRUTOR GENÉRICO DOS ITENS DO MENU
  static Widget _itemMenu({
    required IconData icon,
    required String titulo,
    required VoidCallback onTap,
    Color corDestaque = Colors.white,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: corDestaque),
          title: Text(
            titulo,
            style: TextStyle(color: corDestaque, fontSize: 15),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white54,
            size: 14,
          ),
          onTap: onTap,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 1,
          color: Colors.white10,
        ),
      ],
    );
  }
}