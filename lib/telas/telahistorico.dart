import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaHistorico extends StatefulWidget {
  const TelaHistorico({super.key});

  @override
  State<TelaHistorico> createState() => _TelaHistoricoState();
}

class _TelaHistoricoState extends State<TelaHistorico> {
  // CONSTANTE DO GRADIENTE DOURADO
  final Gradient _gradienteDourado = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD200), Color(0xFFDDA300)],
  );

  List<Map<String, dynamic>> rotasHistorico = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  // Lê os dados do SharedPreferences reais gravados pelas outras telas
  Future<void> _carregarHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historicoJson = prefs.getString('lista_historico');

    if (historicoJson != null) {
      final List<dynamic> dadosDecodificados = jsonDecode(historicoJson);
      setState(() {
        rotasHistorico = dadosDecodificados.map((e) => Map<String, dynamic>.from(e)).toList();
        carregando = false;
      });
    } else {
      // Caso o utilizador NUNCA tenha feito nenhuma rota, o histórico começa vazio
      setState(() {
        rotasHistorico = [];
        carregando = false;
      });
    }
  }

  // Função para limpar todo o histórico (Útil para testes da conta)
  Future<void> _limparHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lista_historico');
    setState(() {
      rotasHistorico = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Histórico limpo com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAEAEA), // Cinza padrão de fundo do app
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: _gradienteDourado),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF5B189A)),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Histórico de Rotas',
          style: TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold),
        ),
        actions: [
          if (rotasHistorico.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Color(0xFF5B189A)),
              onPressed: _limparHistorico,
              tooltip: 'Limpar tudo',
            ),
        ],
      ),
      body: SafeArea(
        child: carregando
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF5B189A)))
            : rotasHistorico.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 70, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma rota recente',
                          style: TextStyle(color: Colors.grey[600], fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'As viagens que finalizar no modo GPS\naparecerão guardadas aqui.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[500], fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: rotasHistorico.length,
                    itemBuilder: (context, index) {
                      final rota = rotasHistorico[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            // Faixa Superior Roxa com Data e XP
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              color: const Color(0xFF5B189A),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: Color(0xFFFFD200), size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    rota['data'] ?? 'Data indisponível',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFD200),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      rota['xp_ganho'] ?? '+25 XP',
                                      style: const TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Linhas de Origem e Destino
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Column(
                                    children: [
                                      const Icon(Icons.my_location, color: Color(0xFF5B189A), size: 16),
                                      Container(height: 20, width: 1.5, color: Colors.grey[300]),
                                      const Icon(Icons.location_on, color: Color(0xFF188C0C), size: 16),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          rota['origem'] ?? 'Origem',
                                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 14),
                                        Text(
                                          rota['destino'] ?? 'Destino',
                                          style: const TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold, fontSize: 15),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Selo Lateral de Segurança
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF188C0C).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      rota['status_seguranca'] ?? 'Segura',
                                      style: const TextStyle(color: Color(0xFF188C0C), fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}