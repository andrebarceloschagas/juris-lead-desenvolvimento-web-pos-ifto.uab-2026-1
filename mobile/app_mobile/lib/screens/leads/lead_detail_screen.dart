import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_theme.dart';
import '../../models/lead.dart';
import '../../viewmodels/lead_viewmodel.dart';
import '../../viewmodels/consulta_viewmodel.dart';
import '../../viewmodels/processo_viewmodel.dart';
import '../../widgets/custom_button.dart';

class LeadDetailScreen extends StatelessWidget {
  final Lead lead;

  const LeadDetailScreen({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('#${lead.id} - ${lead.name}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<LeadViewModel>(
        builder: (context, vm, child) {
          final currentLead = vm.leads.firstWhere((l) => l.id == lead.id, orElse: () => lead);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Card
                _buildInfoCard(context, currentLead),
                const SizedBox(height: 24),
                
                // Triage Section
                if (currentLead.triageSummary != null && currentLead.triageSummary!.isNotEmpty) ...[
                  Text(
                    'Resumo da Triagem (IA)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                    ),
                    child: Text(
                      currentLead.triageSummary!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Actions
                Text(
                  'Ações Disponíveis',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _buildActionButtons(context, vm, currentLead),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, Lead l) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildRow(context, 'Nome', l.name),
            const Divider(),
            _buildRow(context, 'E-mail', l.email ?? 'Não informado'),
            const Divider(),
            _buildRow(context, 'Telefone', l.phone ?? 'Não informado'),
            const Divider(),
            _buildRow(context, 'Origem', l.origin ?? 'Não informado'),
            const Divider(),
            _buildRow(context, 'Status', l.status.toUpperCase(), isStatus: true),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value, {bool isStatus = false}) {
    final statusColor = isStatus ? _getStatusColor(value) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          isStatus
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor!.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Flexible(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    textAlign: TextAlign.right,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, LeadViewModel vm, Lead l) {
    return Column(
      children: [
        // Triagem
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            label: 'Iniciar Triagem IA',
            icon: Icons.psychology_rounded,
            isLoading: vm.isLoading,
            onPressed: () => _showTriageConfirmation(context, vm, l),
          ),
        ),
        const SizedBox(height: 12),
        
        // Converter
        if (l.status != 'converted') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _convertLead(context, vm, l),
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Converter Lead'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Agenda
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _scheduleConsulta(context, l),
            icon: const Icon(Icons.calendar_today_rounded),
            label: const Text('Agendar Consulta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Abrir Processo
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            label: 'Abrir Processo',
            icon: Icons.folder_open_rounded,
            type: ButtonType.secondary,
            onPressed: () => _openProcess(context, l),
          ),
        ),
        
        if (l.phone != null && l.phone!.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openWhatsApp(l.phone!),
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: const Text('Chamar no WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ]
      ],
    );
  }

  void _showTriageConfirmation(BuildContext context, LeadViewModel vm, Lead l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Iniciar Triagem'),
        content: const Text('Deseja iniciar a triagem deste lead usando Inteligência Artificial?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              vm.triageLead(l.id).then((_) {
                if (vm.errorMessage != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(vm.errorMessage!), backgroundColor: AppTheme.danger),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Triagem concluída com sucesso!'), backgroundColor: AppTheme.success),
                  );
                }
              });
            },
            child: const Text('CONFIRMAR'),
          ),
        ],
      ),
    );
  }

  void _convertLead(BuildContext context, LeadViewModel vm, Lead l) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Converter Lead'),
        content: const Text('Tem certeza que deseja converter este lead em Cliente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await vm.convertLead(l.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lead convertido com sucesso!'), backgroundColor: AppTheme.success),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(vm.errorMessage ?? 'Erro ao converter'), backgroundColor: AppTheme.danger),
                );
              }
            },
            child: const Text('CONVERTER'),
          ),
        ],
      ),
    );
  }

  void _scheduleConsulta(BuildContext context, Lead l) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null && context.mounted) {
        final scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        final vm = Provider.of<ConsultaViewModel>(context, listen: false);
        final res = await vm.createConsulta(l.id, scheduledAt);
        if (res != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Consulta agendada com sucesso!'), backgroundColor: AppTheme.success),
          );
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(vm.errorMessage ?? 'Erro ao agendar'), backgroundColor: AppTheme.danger),
          );
        }
      }
    }
  }

  void _openProcess(BuildContext context, Lead l) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Abrir Processo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Título do Processo'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) return;
              Navigator.of(ctx).pop();
              final vm = Provider.of<ProcessoViewModel>(context, listen: false);
              final res = await vm.createProcesso(l.id, titleController.text.trim(), descController.text.trim());
              if (res != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processo aberto com sucesso!'), backgroundColor: AppTheme.success),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(vm.errorMessage ?? 'Erro ao abrir processo'), backgroundColor: AppTheme.danger),
                );
              }
            },
            child: const Text('SALVAR'),
          ),
        ],
      ),
    );
  }

  void _openWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final url = Uri.parse('https://wa.me/55$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return AppTheme.primary;
      case 'triaged':
        return AppTheme.warning;
      case 'converted':
        return AppTheme.success;
      default:
        return AppTheme.textSecondary;
    }
  }
}
