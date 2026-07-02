import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../viewmodels/consulta_viewmodel.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/empty_state.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ConsultaViewModel>(context, listen: false).fetchConsultas();
    });
  }

  void _cancelConsulta(int consultaId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Consulta'),
        content: const Text('Tem certeza que deseja cancelar esta consulta agendada?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('NÃO'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final vm = Provider.of<ConsultaViewModel>(context, listen: false);
              final success = await vm.cancelConsulta(consultaId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Consulta cancelada com sucesso!'), backgroundColor: AppTheme.success),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(vm.errorMessage ?? 'Erro ao cancelar'), backgroundColor: AppTheme.danger),
                );
              }
            },
            child: const Text('SIM, CANCELAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Agenda de Consultas'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<ConsultaViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading && vm.consultas.isEmpty) {
            return const LoadingState(label: 'Carregando agenda...');
          }
          if (vm.errorMessage != null && vm.consultas.isEmpty) {
            return ErrorState(
              message: 'Não foi possível carregar as consultas.',
              onRetry: vm.fetchConsultas,
            );
          }

          if (vm.consultas.isEmpty) {
            return const EmptyState(
              message: 'Nenhuma consulta agendada na sua agenda.',
              icon: Icons.calendar_today_rounded,
            );
          }

          return RefreshIndicator(
            onRefresh: vm.fetchConsultas,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: vm.consultas.length,
              itemBuilder: (context, index) {
                final consulta = vm.consultas[index];
                
                final dateStr = consulta.scheduledAt != null
                    ? DateFormat('dd/MM/yyyy HH:mm').format(consulta.scheduledAt!.toLocal())
                    : 'Sem data';

                final isScheduled = consulta.status.toLowerCase() == 'scheduled';

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: isScheduled ? AppTheme.primaryLight : Colors.grey.shade100,
                        foregroundColor: isScheduled ? AppTheme.primary : Colors.grey,
                        child: Icon(isScheduled ? Icons.calendar_today_rounded : Icons.calendar_today_outlined),
                      ),
                      title: Text(
                        consulta.leadName ?? 'Lead #${consulta.leadId}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'Horário: $dateStr',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (isScheduled ? AppTheme.success : AppTheme.danger).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              consulta.status.toUpperCase(),
                              style: TextStyle(
                                color: isScheduled ? AppTheme.success : AppTheme.danger,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: isScheduled
                          ? IconButton(
                              icon: const Icon(Icons.cancel_outlined, color: AppTheme.danger),
                              onPressed: () => _cancelConsulta(consulta.id),
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
