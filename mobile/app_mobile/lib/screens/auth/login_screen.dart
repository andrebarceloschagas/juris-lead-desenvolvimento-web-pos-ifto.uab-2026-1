import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/custom_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      authVM.login(_emailController.text, _passwordController.text).then((success) {
        if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authVM.errorMessage ?? 'Falha ao autenticar. Verifique suas credenciais.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900 escuro para o login
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.gavel_rounded,
                  size: 80,
                  color: Color(0xFF2563EB), // Azul primário
                ),
                const SizedBox(height: 16),
                const Text(
                  'JurisLead CRM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Gerenciamento de Leads e Processos',
                  style: TextStyle(
                    color: Color(0xFF94A3B8), // Slate 400
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // Campo Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF64748B)),
                    hintText: 'E-mail',
                    hintStyle: TextStyle(color: Color(0xFF64748B)),
                    filled: true,
                    fillColor: Color(0xFF1E293B),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF334155)),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2563EB), width: 1.5),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1.5),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira o seu e-mail.';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Por favor, insira um e-mail válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                
                // Campo Senha
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: const Color(0xFF64748B),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    hintText: 'Senha',
                    hintStyle: const TextStyle(color: Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF334155)),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2563EB), width: 1.5),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1.5),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a sua senha.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Botão de Entrada
                CustomButton(
                  label: 'ENTRAR',
                  onPressed: _submit,
                  isLoading: authVM.isLoading,
                ),
                const SizedBox(height: 24),
                
                // Link para Registro
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    'Não tem conta? Cadastre-se',
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
