import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'telalogin.dart';

class TelaConfiguracoes extends StatefulWidget {
  const TelaConfiguracoes({super.key});

  @override
  State<TelaConfiguracoes> createState() => _TelaConfiguracoesState();
}

class _TelaConfiguracoesState extends State<TelaConfiguracoes> {
  // Controladores para pegar o texto digitado pelo usuário
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _usuarioController = TextEditingController();

  bool _carregando = true;

  // CONSTANTE DO GRADIENTE DOURADO
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

  @override
  void dispose() {
    _nomeController.dispose();
    _usuarioController.dispose();
    super.dispose();
  }

  // Busca os dados do banco local para preencher os campos
  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _nomeController.text = prefs.getString('nome_usuario') ?? '';
      _usuarioController.text = prefs.getString('user_usuario') ?? '';
      _carregando = false;
    });
  }

  // Salva o novo nome e usuário
  Future<void> _salvarPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nome_usuario', _nomeController.text.trim());
    await prefs.setString('user_usuario', _usuarioController.text.trim());

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado com sucesso!')),
    );
  }

  // NOVA FUNÇÃO: Exibe a caixa de confirmação antes de apagar
  void _confirmarExclusao() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Conta?'),
          content: const Text(
            'Tem certeza de que deseja excluir sua conta? Esta ação é permanente e não poderá ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o alerta sem fazer nada
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o alerta
                _excluirConta(); // Executa a função que apaga os dados
              },
              child: const Text(
                'Sim, excluir',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Apaga tudo e joga para o Login
  Future<void> _excluirConta() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpa todos os dados salvos

    if (!mounted) return;

    // Joga para a tela de login e destrói o histórico de navegação
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const TelaLogin()),
      (route) => false,
    );
  }

  void _simularTrocaDeSenha() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Senha alterada com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // GestureDetector para fechar o teclado ao tocar fora dos campos
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF5B189A),
        appBar: AppBar(
          // GRADIENTE DOURADO APLICADO AQUI
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: _gradienteDourado),
          ),
          backgroundColor: Colors.transparent, // Fundo transparente para o gradiente aparecer
          iconTheme: const IconThemeData(color: Color(0xFF5B189A)),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Configurações',
            style: TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: _carregando
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFFD200),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _TituloSecao('Alterar senha'),
                      const SizedBox(height: 10),
                      _campoSenha('Senha atual'),
                      const SizedBox(height: 10),
                      _campoSenha('Nova senha'),
                      const SizedBox(height: 10),
                      _campoSenha('Confirmar nova senha'),
                      const SizedBox(height: 16),
                      _botaoAmarelo(
                        'Salvar Senha',
                        onPressed: _simularTrocaDeSenha,
                      ),

                      const SizedBox(height: 24),

                      const _TituloSecao('Nome'),
                      const SizedBox(height: 10),
                      _campoComController(_nomeController),

                      const SizedBox(height: 18),

                      const _TituloSecao('Alterar nome de Usuário'),
                      const SizedBox(height: 10),
                      _campoComController(_usuarioController),
                      const SizedBox(height: 16),
                      _botaoAmarelo(
                        'Salvar Alterações',
                        onPressed: _salvarPerfil,
                      ),

                      const SizedBox(height: 28),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3C096C),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Excluir conta?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'ATENÇÃO: ao confirmar essa opção seu perfil será apagado permanentemente e não poderá ser recuperado.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _botaoAmarelo(
                              'Confirmar Exclusão',
                              onPressed: _confirmarExclusao,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _campoSenha(String hint) {
    return TextField(
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF3C096C),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFFFD200)),
        ),
      ),
    );
  }

  Widget _campoComController(TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF3C096C),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFFFD200)),
        ),
      ),
    );
  }

  // BOTÃO MODIFICADO PARA USAR O GRADIENTE DOURADO
  Widget _botaoAmarelo(String texto, {required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        gradient: _gradienteDourado, // APLICADO AQUI
        borderRadius: BorderRadius.circular(6),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Transparente para ver o gradiente
          shadowColor: Colors.transparent,
          foregroundColor: const Color(0xFF5B189A),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(
          texto,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _TituloSecao extends StatelessWidget {
  final String texto;

  const _TituloSecao(this.texto);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(texto, style: const TextStyle(color: Colors.white, fontSize: 15)),
        const SizedBox(height: 3),
        // TRACINHO AGORA COM GRADIENTE DOURADO
        Container(
          width: 84, 
          height: 2, 
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFD200), Color(0xFFDDA300)],
            ),
          ),
        ),
      ],
    );
  }
}