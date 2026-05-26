import 'package:flutter/material.dart';

class TelaNovoFavorito extends StatefulWidget {
  const TelaNovoFavorito({super.key});

  @override
  State<TelaNovoFavorito> createState() => _TelaNovoFavoritoState();
}

class _TelaNovoFavoritoState extends State<TelaNovoFavorito> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  String _categoriaSelecionada = 'Outros';

  final List<String> _categorias = ['Trabalho', 'Escola', 'Lazer', 'Casa', 'Outros'];

  // CONSTANTE DO GRADIENTE DOURADO
  final Gradient _gradienteDourado = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD200), Color(0xFFDDA300)],
  );

  @override
  void dispose() {
    _nomeController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  // LÓGICA DE EMPACOTAR OS DADOS E ENVIAR DE VOLTA
  void _salvar() {
    if (_nomeController.text.isEmpty || _enderecoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o nome e o endereço!')),
      );
      return;
    }

    final novoLocal = {
      'titulo': _nomeController.text.trim(),
      'categoria': _categoriaSelecionada,
      'tempo': '--', 
      'distancia': _enderecoController.text.trim(), 
      'avaliacao': '(Novo)',
      'segura': 'Pendente', 
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_nomeController.text} adicionado aos favoritos!')),
    );
    
    // Devolve o map novoLocal para quem chamou a tela
    Navigator.pop(context, novoLocal); 
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF5B189A),
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: _gradienteDourado),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF5B189A)),
          title: const Text(
            'Novo Favorito',
            style: TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dê um nome ao local',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              _campoTexto(
                controller: _nomeController,
                hint: 'Ex: Minha Casa, Trabalho...',
                icon: Icons.edit_location_alt_outlined,
              ),
              const SizedBox(height: 24),
              const Text(
                'Endereço ou Ponto de Referência',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              _campoTexto(
                controller: _enderecoController,
                hint: 'Rua, número, bairro...',
                icon: Icons.map_outlined,
              ),
              const SizedBox(height: 24),
              const Text(
                'Categoria',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              
              Wrap(
                spacing: 10,
                children: _categorias.map((cat) {
                  final selecionado = _categoriaSelecionada == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: selecionado,
                    onSelected: (bool selected) {
                      setState(() {
                        _categoriaSelecionada = cat;
                      });
                    },
                    selectedColor: const Color(0xFFFFD200), 
                    backgroundColor: const Color(0xFF3C096C),
                    labelStyle: TextStyle(
                      color: selecionado ? const Color(0xFF5B189A) : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 60),
              
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: _gradienteDourado,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
                  ]
                ),
                child: ElevatedButton(
                  onPressed: _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, 
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text(
                    'SALVAR LOCAL',
                    style: TextStyle(
                      color: Color(0xFF5B189A),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Widget _campoTexto({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFFFD200)),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF3C096C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFFFD200)),
        ),
      ),
    );
  }
}