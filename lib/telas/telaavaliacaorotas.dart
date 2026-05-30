import 'package:flutter/material.dart';

class TelaAvaliacaoRota extends StatefulWidget {
  const TelaAvaliacaoRota({super.key});

  @override
  State<TelaAvaliacaoRota> createState() => _TelaAvaliacaoRotaState();
}

class _TelaAvaliacaoRotaState extends State<TelaAvaliacaoRota> {
  int _estrelas = 0;
  final TextEditingController _comentarioController = TextEditingController();
  final Set<String> _tagsSelecionadas = {};

  // Lista de tags rápidas para facilitar o feedback do usuário
  // Backend: No futuro, essa lista pode vir diretamente da API do servidor (GET)
  final List<String> _tagsDisponiveis = [
    'Bem iluminada',
    'Movimentada',
    'Policiada',
    'Trajeto rápido',
    'Muito escura',
    'Rua deserta',
    'Mal sinalizada',
  ];

  // CONSTANTE DO GRADIENTE DOURADO
  final Gradient _gradienteDourado = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD200), Color(0xFFDDA300)],
  );

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  // --- AÇÃO DO BOTÃO PRINCIPAL: ENVIAR AVALIAÇÃO ---
  // Backend: Esta é a função principal de integração desta tela.
  void _enviarAvaliacao() {
    if (_estrelas == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, dê uma nota de 1 a 5 estrelas!')),
      );
      return;
    }

    // Backend: Aqui deve ser feita a requisição POST para a API salvando a avaliação da rota.
    // Variáveis a serem enviadas no corpo (body) da requisição:
    // 1. _estrelas (Inteiro de 1 a 5)
    // 2. _tagsSelecionadas.toList() (Lista de Strings com as características marcadas)
    // 3. _comentarioController.text (String com o feedback opcional do usuário)
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avaliação enviada! Obrigado por ajudar a comunidade.')),
    );
    
    // Fecha a tela de avaliação e volta para o Início
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // GestureDetector para fechar o teclado ao clicar fora da caixa de texto
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF5B189A), 
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            // --- BOTÃO: FECHAR (X) ---
            // Backend: Apenas fecha a tela ignorando o envio da avaliação (Skip)
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context), 
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ícone de Sucesso
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _gradienteDourado,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.flag_circle,
                    color: Color(0xFF5B189A),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                
                const Text(
                  'Você chegou ao seu destino!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Como você avalia a segurança desta rota?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),

                // ==========================================
                // SISTEMA DE ESTRELAS
                // ==========================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      // --- BOTÃO: SELEÇÃO DE ESTRELA ---
                      // Backend: Atualiza o estado da nota da rota (1 a 5)
                      iconSize: 48,
                      icon: Icon(
                        index < _estrelas ? Icons.star : Icons.star_border,
                        color: const Color(0xFFFFD200), // Cor dourada pras estrelas
                      ),
                      onPressed: () {
                        setState(() {
                          _estrelas = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 32),

                // ==========================================
                // TAGS RÁPIDAS
                // ==========================================
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'O que se destacou?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _tagsDisponiveis.map((tag) {
                    final selecionada = _tagsSelecionadas.contains(tag);
                    return GestureDetector(
                      // --- BOTÃO: SELEÇÃO DE TAG ---
                      // Backend: Insere ou remove a tag atual no Set _tagsSelecionadas
                      onTap: () {
                        setState(() {
                          if (selecionada) {
                            _tagsSelecionadas.remove(tag);
                          } else {
                            _tagsSelecionadas.add(tag);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          // Se estiver selecionada, ganha o fundo dourado; senão, fica roxa com borda
                          gradient: selecionada ? _gradienteDourado : null,
                          color: selecionada ? null : const Color(0xFF3C096C),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selecionada ? Colors.transparent : Colors.white24,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: selecionada ? const Color(0xFF5B189A) : Colors.white70,
                            fontWeight: selecionada ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // ==========================================
                // COMENTÁRIO OPCIONAL
                // ==========================================
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Detalhes adicionais (opcional)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // --- CAMPO DE TEXTO: FEEDBACK ---
                // Backend: Captura o input em texto livre para o banco de dados
                TextField(
                  controller: _comentarioController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Conte um pouco mais sobre a sua experiência...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF3C096C),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // ==========================================
                // BOTÃO DE ENVIAR AVALIAÇÃO
                // ==========================================
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: _gradienteDourado,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  // --- BOTÃO PRINCIPAL: ENVIAR ---
                  // Backend: Aciona a função _enviarAvaliacao() descrita no topo do arquivo
                  child: ElevatedButton(
                    onPressed: _enviarAvaliacao,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Enviar Avaliação',
                      style: TextStyle(
                        color: Color(0xFF5B189A),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}