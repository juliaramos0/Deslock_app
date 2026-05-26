import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaConta extends StatefulWidget {
  const TelaConta({super.key});

  @override
  State<TelaConta> createState() => _TelaContaState();
}

class _TelaContaState extends State<TelaConta> {
  String email = 'carregando...';
  String telefone = 'Adicionar número';
  String contatoEmergencia = 'Adicionar contato'; 
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      email = prefs.getString('email_cadastrado') ?? 'Nenhum e-mail vinculado';
      telefone = prefs.getString('telefone_usuario') ?? 'Adicionar número';
      contatoEmergencia = prefs.getString('contato_emergencia') ?? 'Adicionar contato'; 
      carregando = false;
    });
  }

  // Função para Editar ou Remover o Telefone
  Future<void> _editarTelefone() async {
    TextEditingController telController = TextEditingController(
      text: telefone == 'Adicionar número' ? '' : telefone,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF3C096C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Editar Telefone', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: telController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: '(11) 99999-9999',
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFFD200)),
              ),
            ),
          ),
          actions: [
            if (telefone != 'Adicionar número')
              TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('telefone_usuario');
                  setState(() {
                    telefone = 'Adicionar número';
                  });
                  if (mounted) Navigator.pop(context);
                  _mostrarAviso('Telefone removido com sucesso.');
                },
                child: const Text('Remover', style: TextStyle(color: Colors.redAccent)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () async {
                final novoTel = telController.text.trim();
                final prefs = await SharedPreferences.getInstance();
                
                if (novoTel.isNotEmpty) {
                  await prefs.setString('telefone_usuario', novoTel);
                  setState(() {
                    telefone = novoTel;
                  });
                } else {
                  await prefs.remove('telefone_usuario');
                  setState(() {
                    telefone = 'Adicionar número';
                  });
                }
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Salvar', style: TextStyle(color: Color(0xFFFFD200), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // NOVO: Função para Editar ou Remover o Contato de Emergência
  Future<void> _editarContatoEmergencia() async {
    TextEditingController contatoController = TextEditingController(
      text: contatoEmergencia == 'Adicionar contato' ? '' : contatoEmergencia,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF3C096C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Contato de Emergência', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: contatoController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Ex: Mãe - (11) 99999-9999',
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFFD200)),
              ),
            ),
          ),
          actions: [
            if (contatoEmergencia != 'Adicionar contato')
              TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('contato_emergencia');
                  setState(() {
                    contatoEmergencia = 'Adicionar contato';
                  });
                  if (mounted) Navigator.pop(context);
                  _mostrarAviso('Contato de emergência removido com sucesso.');
                },
                child: const Text('Remover', style: TextStyle(color: Colors.redAccent)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () async {
                final novoContato = contatoController.text.trim();
                final prefs = await SharedPreferences.getInstance();
                
                if (novoContato.isNotEmpty) {
                  await prefs.setString('contato_emergencia', novoContato);
                  setState(() {
                    contatoEmergencia = novoContato;
                  });
                } else {
                  await prefs.remove('contato_emergencia');
                  setState(() {
                    contatoEmergencia = 'Adicionar contato';
                  });
                }
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Salvar', style: TextStyle(color: Color(0xFFFFD200), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _mostrarAviso(String mensagem) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5B189A),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD200),
        iconTheme: const IconThemeData(color: Color(0xFF5B189A)),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Minha Conta',
          style: TextStyle(color: Color(0xFF5B189A), fontWeight: FontWeight.bold),
        ),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD200)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _TituloSecao('Informações de Contato'),
                  const SizedBox(height: 16),
                  
                  // E-mail (Somente leitura)
                  _ItemInformacao(
                    icone: Icons.email_outlined, 
                    titulo: 'E-mail', 
                    valor: email
                  ),
                  const SizedBox(height: 12),
                  
                  // Telefone (Clicável e Editável)
                  _ItemInformacao(
                    icone: Icons.phone_android, 
                    titulo: 'Telefone', 
                    valor: telefone, 
                    aoClicar: _editarTelefone,
                  ),
                  const SizedBox(height: 12),

                  // NOVO: Contato de Emergência (Clicável e Editável)
                  _ItemInformacao(
                    icone: Icons.health_and_safety_outlined, 
                    titulo: 'Contato de Emergência', 
                    valor: contatoEmergencia, 
                    aoClicar: _editarContatoEmergencia,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  const _TituloSecao('Privacidade e Dados'),
                  const SizedBox(height: 16),
                  ListTile(
                    tileColor: const Color(0xFF3C096C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    leading: const Icon(Icons.download, color: Colors.white),
                    title: const Text('Baixar meus dados', style: TextStyle(color: Colors.white)),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                    onTap: () => _mostrarAviso('Solicitação de download enviada para o e-mail.'),
                  ),
                ],
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
    return Text(
      texto,
      style: const TextStyle(color: Color(0xFFFFD200), fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}

class _ItemInformacao extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String valor;
  final VoidCallback? aoClicar;

  const _ItemInformacao({
    required this.icone, 
    required this.titulo, 
    required this.valor, 
    this.aoClicar
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF3C096C),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: aoClicar,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icone, color: Colors.white70),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      valor, 
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis, 
                    ),
                  ],
                ),
              ),
              if (aoClicar != null) const Icon(Icons.edit, color: Color(0xFFFFD200), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}