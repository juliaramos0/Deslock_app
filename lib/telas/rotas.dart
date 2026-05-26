import 'package:flutter/material.dart';
import 'telafavoritos.dart';
import 'telavoce.dart';
import 'telanavegacaoativa.dart'; 
import 'telahistorico.dart'; // NOVO: Importe da Tela de Histórico

class TelaRotas extends StatefulWidget {
  const TelaRotas({super.key});

  @override
  State<TelaRotas> createState() => _TelaRotasState();
}

class _TelaRotasState extends State<TelaRotas> {
  final TextEditingController _searchController = TextEditingController();

  // CONSTANTE DO GRADIENTE DOURADO
  final Gradient _gradienteDourado = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD200), Color(0xFFDDA300)],
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _mostrarAviso(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            // Fundo do Mapa
            Container(width: double.infinity, height: double.infinity, color: Colors.grey[300]),
            
            // Pino do Mapa Centralizado
            Center(
              child: GestureDetector(
                onTap: () => _mostrarAviso("Pino de localização selecionado!"),
                child: const Icon(Icons.location_pin, size: 50, color: Color(0xFF5B189A)),
              ),
            ),
            
            // Header (Busca, Foto e Filtros)
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: _gradienteDourado,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildSearchBar()),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaVoce())),
                              child: const CircleAvatar(radius: 22, backgroundColor: Colors.white, child: Icon(Icons.person, color: Color(0xFF5B189A))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _filtro(
                                icon: Icons.favorite_border, 
                                texto: "Favoritos", 
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaFavoritos()))
                              ),
                              const SizedBox(width: 10),
                              
                              // MODIFICADO: Agora o botão aponta para a TelaHistorico de verdade!
                              _filtro(
                                icon: Icons.history, 
                                texto: "Histórico", 
                                onTap: () {
                                  Navigator.push(
                                    context, 
                                    MaterialPageRoute(builder: (_) => const TelaHistorico()),
                                  );
                                }
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

            // Card do Local (Base)
            Positioned(
              left: 16,
              right: 16,
              bottom: 90,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaNavegacaoAtiva()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B189A),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Escola.jpg/640px-Escola.jpg",
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 120,
                              width: double.infinity,
                              color: Colors.white24,
                              child: const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              width: double.infinity,
                              color: Colors.white24,
                              child: const Center(
                                child: Icon(Icons.broken_image, color: Colors.white, size: 40),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        "Escola Profissional Santo Agostinho",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        children: [
                          Icon(Icons.star, color: Colors.yellow, size: 18),
                          Icon(Icons.star, color: Colors.yellow, size: 18),
                          Icon(Icons.star, color: Colors.yellow, size: 18),
                          Icon(Icons.star, color: Colors.yellow, size: 18),
                          Icon(Icons.star, color: Colors.yellow, size: 18),
                          SizedBox(width: 8),
                          Text(
                            "(1000)",
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Instituição educacional",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: TextField(
        controller: _searchController,
        onSubmitted: (valor) {
          if (valor.trim().isNotEmpty) _mostrarAviso("Buscando rotas para: $valor");
        },
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: "Para onde vamos?",
          hintStyle: const TextStyle(color: Colors.black38),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF5B189A)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear, color: Colors.black38), onPressed: () { _searchController.clear(); setState(() {}); })
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (text) => setState(() {}),
      ),
    );
  }

  Widget _filtro({required IconData icon, required String texto, required VoidCallback onTap}) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: const Color(0xFF5B189A)),
      label: Text(texto, style: const TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.9),
        side: const BorderSide(color: Color(0xFF5B189A), width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }
}