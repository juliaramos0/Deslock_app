import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'telabase.dart'; 
import 'telarecuperarsenha.dart'; // NOVO: Importe da tela de recuperar senha

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  bool _isLogin = true;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();

  bool _obscureSenha = true;
  bool _obscureConfirmarSenha = true;
  bool _carregando = false;

  String? _erroEmail;
  String? _erroSenha;
  String? _erroGeral;

  // CONSTANTE DO GRADIENTE DOURADO
  final Gradient _gradienteDourado = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD200), Color(0xFFDDA300)],
  );

  @override
  void dispose() {
    _nomeController.dispose();
    _usuarioController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  void _alternarModo() {
    setState(() {
      _isLogin = !_isLogin;
      _erroGeral = null;
      _erroEmail = null;
      _erroSenha = null;
    });
  }

  bool _emailValido(String email) {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(email);
  }

  bool _validarCampos() {
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    String? erroEmail;
    String? erroSenha;

    if (email.isEmpty) {
      erroEmail = 'Digite seu e-mail';
    } else if (!_emailValido(email)) {
      erroEmail = 'Digite um e-mail válido';
    }

    if (senha.isEmpty) {
      erroSenha = 'Digite sua senha';
    } else if (senha.length < 6) {
      erroSenha = 'A senha deve ter pelo menos 6 caracteres';
    }

    if (!_isLogin) {
      final nome = _nomeController.text.trim();
      final usuario = _usuarioController.text.trim();
      final confirma = _confirmarSenhaController.text.trim();

      if (nome.isEmpty || usuario.isEmpty || confirma.isEmpty) {
        setState(() {
          _erroGeral = 'Preencha todos os campos extras para cadastrar.';
          _erroEmail = erroEmail;
          _erroSenha = erroSenha;
        });
        return false;
      }

      if (senha != confirma) {
        setState(() {
          _erroGeral = 'As senhas não coincidem!';
          _erroEmail = erroEmail;
          _erroSenha = erroSenha;
        });
        return false;
      }
    }

    setState(() {
      _erroEmail = erroEmail;
      _erroSenha = erroSenha;
      _erroGeral = null;
    });

    return erroEmail == null && erroSenha == null;
  }

  Future<void> _processarAcao() async {
    FocusScope.of(context).unfocus();

    if (!_validarCampos()) return;

    setState(() {
      _carregando = true;
      _erroGeral = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      if (_isLogin) {
        final emailSalvo = prefs.getString('email_cadastrado');
        final senhaSalva = prefs.getString('senha_cadastrada');

        final emailDigitado = _emailController.text.trim();
        final senhaDigitada = _senhaController.text.trim();

        if (emailSalvo == null || senhaSalva == null) {
          setState(() => _erroGeral = 'Nenhuma conta encontrada. Faça seu cadastro!');
          return;
        }

        if (emailDigitado == emailSalvo && senhaDigitada == senhaSalva) {
          await prefs.setBool('usuario_logado', true);
          _irParaHome();
        } else {
          setState(() => _erroGeral = 'E-mail ou senha incorretos.');
        }

      } else {
        await prefs.setString('nome_usuario', _nomeController.text.trim());
        await prefs.setString('user_usuario', _usuarioController.text.trim());
        await prefs.setString('email_cadastrado', _emailController.text.trim());
        await prefs.setString('senha_cadastrada', _senhaController.text);
        
        await prefs.setInt('nivel_usuario', 1);
        await prefs.setInt('xp_atual', 0);
        await prefs.setInt('xp_maximo', 200);
        
        await prefs.setBool('usuario_logado', true);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta criada com sucesso! Bem-vindo(a)!')),
        );
        _irParaHome();
      }
    } catch (e) {
      setState(() => _erroGeral = 'Erro ao processar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _irParaHome() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const TelaBase()),
    );
  }

  // NOVO: Navegação real para a Tela de Recuperar Senha
  void _irParaRecuperarSenha() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TelaRecuperarSenha()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5B189A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40), 
              
              Image.asset(
                "assets/DESLOCK.png",
                height: 120, 
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 30),
              Text(
                _isLogin ? '' : 'Crie sua conta',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _isLogin 
                  ? 'Insira seu e-mail e senha para entrar'
                  : 'Preencha os dados abaixo para fazer\nparte da nossa comunidade',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 32),

              AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutQuart,
                child: Column(
                  children: [
                    if (!_isLogin) ...[
                      _tituloCampo('Nome Completo'),
                      const SizedBox(height: 8),
                      _campo(
                        controller: _nomeController,
                        hint: 'Seu nome',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 22),
                      
                      _tituloCampo('Nome de Usuário'),
                      const SizedBox(height: 8),
                      _campo(
                        controller: _usuarioController,
                        hint: '@usuario',
                        icon: Icons.alternate_email,
                      ),
                      const SizedBox(height: 22),
                    ],

                    _tituloCampo('E-mail'),
                    const SizedBox(height: 8),
                    _campo(
                      controller: _emailController,
                      hint: 'email@dominio.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      errorText: _erroEmail,
                      onChanged: (_) {
                        if (_erroEmail != null || _erroGeral != null) {
                          setState(() {
                            _erroEmail = null;
                            _erroGeral = null;
                          });
                        }
                      },
                    ),
                    
                    const SizedBox(height: 22),
                    
                    _tituloCampo('Senha'),
                    const SizedBox(height: 8),
                    _campo(
                      controller: _senhaController,
                      hint: 'Senha',
                      icon: Icons.lock_outline,
                      obscure: _obscureSenha,
                      errorText: _erroSenha,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureSenha = !_obscureSenha;
                          });
                        },
                        icon: Icon(
                          _obscureSenha ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70,
                        ),
                      ),
                      onChanged: (_) {
                        if (_erroSenha != null || _erroGeral != null) {
                          setState(() {
                            _erroSenha = null;
                            _erroGeral = null;
                          });
                        }
                      },
                    ),

                    if (!_isLogin) ...[
                      const SizedBox(height: 22),
                      _tituloCampo('Confirmar Senha'),
                      const SizedBox(height: 8),
                      _campo(
                        controller: _confirmarSenhaController,
                        hint: 'Repita a senha',
                        icon: Icons.lock_reset,
                        obscure: _obscureConfirmarSenha,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureConfirmarSenha = !_obscureConfirmarSenha;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmarSenha ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              if (_isLogin) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _irParaRecuperarSenha,
                    child: const Text(
                      'Esqueci minha senha',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
              
              if (_erroGeral != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3C096C),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFD200), width: 1),
                  ),
                  child: Text(
                    _erroGeral!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFFD200),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // BOTÃO PRINCIPAL COM GRADIENTE DOURADO
              Container(
                width: 150, 
                height: 45,
                decoration: BoxDecoration(
                  gradient: _gradienteDourado,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26, 
                      blurRadius: 6, 
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _carregando ? null : _processarAcao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent, 
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: _carregando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF5B189A),
                          ),
                        )
                      : Text(
                          _isLogin ? 'ENTRAR' : 'CADASTRAR',
                          style: const TextStyle(
                            color: Color(0xFF5B189A),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 28),
              
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1.3,
                      color: const Color(0xFFFFD200).withValues(alpha: 0.8),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'ou',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1.3,
                      color: const Color(0xFFFFD200).withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              _botaoSocialGoogle(
                texto: 'Continuar com Google',
                onPressed: () {}, 
              ),
              
              const SizedBox(height: 14),
              
              _botaoSocialApple(
                texto: 'Continuar com Apple',
                onPressed: () {},
              ),
              
              const SizedBox(height: 18),
              
              _botaoSecundario(
                texto: _isLogin ? 'Não tem conta? Cadastre-se' : 'Já tem conta? Entrar',
                onPressed: _alternarModo,
              ),

              const SizedBox(height: 24),
              
              const Text(
                'Ao continuar, você concorda com os nossos\nTermos de Serviço e com a Política de Privacidade',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
              
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGETS AUXILIARES ABAIXO
  static Widget _tituloCampo(String texto) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texto,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 3),
          // TRACINHO COM GRADIENTE DOURADO
          Container(
            width: 120, 
            height: 2, 
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFD200), Color(0xFFDDA300)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _campo({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    String? errorText,
    Widget? suffixIcon,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70, size: 20),
        suffixIcon: suffixIcon,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        errorText: errorText,
        errorStyle: const TextStyle(color: Color(0xFFFFD200)),
        filled: true,
        fillColor: const Color(0xFF2E0057),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFFFD200), width: 1),
        ),
      ),
    );
  }

  static Widget _botaoSecundario({required String texto, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFFFD200), width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
        child: Text(texto, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ),
    );
  }

 static Widget _botaoSocialGoogle({
    required String texto,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFFFD200), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/google.png',
              height: 20, 
              width: 20,
            ),
            const SizedBox(width: 10),
            Text(
              texto,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _botaoSocialApple({required String texto, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFFFD200), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.apple, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Text(texto, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}