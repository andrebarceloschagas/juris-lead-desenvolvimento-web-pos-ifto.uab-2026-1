import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../viewmodels/lead_viewmodel.dart';
import '../../widgets/custom_button.dart';

class LeadFormScreen extends StatefulWidget {
  const LeadFormScreen({super.key});

  @override
  State<LeadFormScreen> createState() => _LeadFormScreenState();
}

class _LeadFormScreenState extends State<LeadFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _documentoController = TextEditingController();
  String _origin = 'mobile_api';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _documentoController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final vm = Provider.of<LeadViewModel>(context, listen: false);
      vm.createLead(
        _nameController.text.trim(),
        _emailController.text.trim().toLowerCase(),
        _phoneController.text.trim(),
        _documentoController.text.trim(),
      ).then((success) {
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lead criado com sucesso!'),
              backgroundColor: AppTheme.success,
            ),
          );
          Navigator.pop(context);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(vm.errorMessage ?? 'Ocorreu um erro ao criar o lead.'),
              backgroundColor: AppTheme.danger,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<LeadViewModel>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Novo Lead'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Cadastro de Lead',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Campo Nome
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome *',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira o nome.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail *',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira o e-mail.';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Por favor, insira um e-mail válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Telefone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telefone *',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira o telefone.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Documento
                TextFormField(
                  controller: _documentoController,
                  decoration: const InputDecoration(
                    labelText: 'CPF/CNPJ',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Origem
                DropdownButtonFormField<String>(
                  value: _origin,
                  decoration: const InputDecoration(
                    labelText: 'Origem',
                    prefixIcon: Icon(Icons.info_outline_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'mobile_api', child: Text('Aplicativo Mobile')),
                    DropdownMenuItem(value: 'web', child: Text('Plataforma Web')),
                    DropdownMenuItem(value: 'indicacao', child: Text('Indicação')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _origin = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 32),

                // Botão Cadastrar
                CustomButton(
                  label: 'CADASTRAR',
                  onPressed: _submit,
                  isLoading: vm.isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
