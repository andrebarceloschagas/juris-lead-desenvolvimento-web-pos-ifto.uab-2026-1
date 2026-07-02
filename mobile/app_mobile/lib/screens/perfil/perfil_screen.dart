import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/custom_button.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Tem certeza que deseja sair de sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialog
              Navigator.of(context).pop(); // Close profile screen (goes back to dashboard)
              Provider.of<AuthViewModel>(context, listen: false).logout();
            },
            child: const Text('SAIR'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final user = authVM.currentUser;
    if (user == null) return;

    final nameController = TextEditingController(text: user.name);
    final bioController = TextEditingController(text: user.bio);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Insira seu nome.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: bioController,
                decoration: const InputDecoration(labelText: 'Biografia'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.of(ctx).pop();
                final success = await authVM.updatePerfil(
                  nameController.text.trim(),
                  bioController.text.trim().isEmpty ? null : bioController.text.trim(),
                );
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Perfil atualizado com sucesso!'), backgroundColor: AppTheme.success),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(authVM.errorMessage ?? 'Erro ao salvar alterações.'), backgroundColor: AppTheme.danger),
                  );
                }
              }
            },
            child: const Text('SALVAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final user = authVM.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Não autenticado.')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar & Basic Info Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: AppTheme.primaryLight,
                    foregroundColor: AppTheme.primary,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      user.role.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile Details Card
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(context, 'E-mail', user.email),
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    const Divider(height: 24),
                    Text(
                      'Biografia',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user.bio!,
                      style: const TextStyle(fontSize: 14, height: 1.4, color: AppTheme.textPrimary),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Actions
            CustomButton(
              label: 'EDITAR PERFIL',
              icon: Icons.edit_outlined,
              type: ButtonType.secondary,
              onPressed: _showEditProfileDialog,
            ),
            const SizedBox(height: 12),
            CustomButton(
              label: 'SAIR DA CONTA',
              icon: Icons.logout_rounded,
              type: ButtonType.danger,
              onPressed: _logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
