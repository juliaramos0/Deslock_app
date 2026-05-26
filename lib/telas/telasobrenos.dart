import 'package:flutter/material.dart';

class TelaSobreNos extends StatelessWidget {
  const TelaSobreNos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5B189A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo / Título
            const Text(
              'DESLOCK',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Versão 1.0.0',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 40),

            // Cartão: Nossa História (NOVO)
            const _SecaoInfo(
              icone: Icons.history_edu,
              titulo: 'Nossa História',
              texto: 'Tudo começou quando percebemos a falta de informações centralizadas sobre segurança nas ruas. Decidimos criar uma ferramenta para empoderar os cidadãos, permitindo que a própria comunidade sinalize os melhores caminhos e evite áreas de risco.',
            ),
            const SizedBox(height: 20),

            // Cartão: Nossa Missão
            const _SecaoInfo(
              icone: Icons.map_outlined,
              titulo: 'Nossa Missão',
              texto: 'O Deslock nasceu para transformar a mobilidade urbana. Acreditamos que todos têm o direito de ir e vir com segurança. Nossa plataforma une a inteligência da comunidade para mapear e compartilhar as rotas mais seguras da sua cidade.',
            ),
            const SizedBox(height: 20),

            // Cartão: Nossos Valores (NOVO)
            const _SecaoInfo(
              icone: Icons.verified_user_outlined,
              titulo: 'Nossos Valores',
              texto: '• Segurança em primeiro lugar\n• Transparência e ética nos dados\n• Colaboração comunitária\n• Acessibilidade para todos',
            ),
            const SizedBox(height: 20),

            // Cartão: Feito pela Comunidade
            const _SecaoInfo(
              icone: Icons.people_alt_outlined,
              titulo: 'Feito pela Comunidade',
              texto: 'Cada rota concluída, cada avaliação e cada missão feita por você ajuda a construir um mapa mais seguro para milhares de outras pessoas. Juntos, somos a nossa maior proteção.',
            ),
            const SizedBox(height: 40),

            // Contato / Suporte (NOVO)
            const Text(
              'Precisa de ajuda? Fale conosco:',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'suporte@deslock.com.br',
              style: TextStyle(color: Color(0xFFFFD200), fontSize: 16),
            ),
            const SizedBox(height: 40),

            // Redes Sociais
            const Text(
              'Siga-nos nas redes',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Ícones Sociais Simbólicos
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _IconeSocial(Icons.camera_alt, aoClicar: () {}), // Simula Instagram
                const SizedBox(width: 20),
                _IconeSocial(Icons.alternate_email, aoClicar: () {}), // Simula Twitter/X
                const SizedBox(width: 20),
                _IconeSocial(Icons.language, aoClicar: () {}), // Simula Site
              ],
            ),
            const SizedBox(height: 40),

            // Links Legais (NOVO)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text('Termos de Uso', style: TextStyle(color: Colors.white70)),
                ),
                const Text('|', style: TextStyle(color: Colors.white54)),
                TextButton(
                  onPressed: () {},
                  child: const Text('Privacidade', style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            const Text(
              '© 2026 Deslock Inc. Todos os direitos reservados.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Widget auxiliar para os cartões de texto
class _SecaoInfo extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String texto;

  const _SecaoInfo({required this.icone, required this.titulo, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Garante que todos os cartões usem o espaço disponível
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF3C096C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD200).withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icone, color: const Color(0xFFFFD200), size: 40),
          const SizedBox(height: 16),
          Text(
            titulo,
            style: const TextStyle(
              color: Color(0xFFFFD200),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para os botões sociais
class _IconeSocial extends StatelessWidget {
  final IconData icon;
  final VoidCallback aoClicar;
  
  const _IconeSocial(this.icon, {required this.aoClicar});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: aoClicar,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}