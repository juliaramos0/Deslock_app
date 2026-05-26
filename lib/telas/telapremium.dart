import 'package:flutter/material.dart';

class TelaPremium extends StatelessWidget {
  const TelaPremium({super.key});

  void _assinar(BuildContext context, String nomePlano) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Redirecionando para pagamento seguro do $nomePlano...')),
    );
  }

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
          children: [
            const Icon(Icons.workspace_premium, color: Color(0xFFFFD200), size: 80),
            const SizedBox(height: 16),
            const Text(
              'Escolha seu Plano',
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Desbloqueie o máximo de segurança\ne recursos exclusivos no seu mapa.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 40),

            // 🟡 PLANO INTERMEDIÁRIO
            _buildCardPlano(
              context: context,
              titulo: 'Plano Intermediário',
              corDestaque: const Color(0xFFFFD200), // Amarelo
              preco: '9,99',
              beneficios: [
                _beneficioItem(Icons.block, 'Remoção de anúncios', 'Permite uso sem notificações promocionais.', const Color(0xFFFFD200)),
                _beneficioItem(Icons.alt_route, 'Rotas inteligentes aprimoradas', 'Gera trajetos mais eficientes considerando múltiplos fatores como trânsito e preferências.', const Color(0xFFFFD200)),
                _beneficioItem(Icons.tune, 'Filtros avançados de trajeto', 'Permite personalização das rotas.', const Color(0xFFFFD200)),
                _beneficioItem(Icons.history, 'Histórico de rotas e estatísticas', 'Permite acompanhar trajetos anteriores.', const Color(0xFFFFD200)),
              ],
            ),

            const SizedBox(height: 32),

            // 🔵 PLANO COMPLETO (PREMIUM)
            _buildCardPlano(
              context: context,
              titulo: 'Plano Completo (Premium)',
              corDestaque: const Color(0xFF42A5F5), // Azul Claro
              preco: '24,99',
              beneficios: [
                _beneficioItem(Icons.person_pin_circle, 'Rotas altamente personalizadas', 'Baseadas nos hábitos do usuário.', const Color(0xFF42A5F5)),
                _beneficioItem(Icons.notifications_active, 'Alertas inteligentes e preditivos', 'Identifica riscos antes do usuário chegar.', const Color(0xFF42A5F5)),
                _beneficioItem(Icons.wifi_off, 'Mapas offline completos', 'Uso total sem internet.', const Color(0xFF42A5F5)),
                _beneficioItem(Icons.auto_awesome, 'Sugestões inteligentes', 'Melhora as recomendações automaticamente baseada no comportamento.', const Color(0xFF42A5F5)),
                _beneficioItem(Icons.analytics, 'Estatísticas avançadas', 'Dados completos de deslocamento e mobilidade.', const Color(0xFF42A5F5)),
              ],
            ),

            const SizedBox(height: 30),
            
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Talvez mais tarde', style: TextStyle(color: Colors.white70, fontSize: 16)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Função criadora de Cartões de Plano
  Widget _buildCardPlano({
    required BuildContext context,
    required String titulo,
    required Color corDestaque,
    required String preco,
    required List<Widget> beneficios,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF3C096C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: corDestaque.withOpacity(0.5), width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do Plano
          Row(
            children: [
              Icon(Icons.circle, color: corDestaque, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(color: corDestaque, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Preço
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('R\$ ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text(preco, style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold, height: 1)),
              const Text('/mês', style: TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 24),

          // Lista de Benefícios
          ...beneficios,

          const SizedBox(height: 24),
          
          // Botão de Assinar
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _assinar(context, titulo),
              style: ElevatedButton.styleFrom(
                backgroundColor: corDestaque,
                foregroundColor: const Color(0xFF5B189A), // Texto do botão na cor roxa de fundo para dar contraste
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Assinar Agora', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // Função criadora dos itens de benefício (Agora suporta subtítulo)
  Widget _beneficioItem(IconData icone, String titulo, String descricao, Color corIcone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinha ao topo para textos mais longos
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2), // Fundo translúcido escuro
              borderRadius: BorderRadius.circular(10)
            ),
            child: Icon(icone, color: corIcone, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo, 
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 4),
                Text(
                  descricao, 
                  style: const TextStyle(color: Colors.white70, fontSize: 14)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}