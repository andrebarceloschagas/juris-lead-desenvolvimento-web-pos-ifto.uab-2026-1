import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lead.dart';
import '../viewmodels/lead_viewmodel.dart';

class LeadDetailView extends StatelessWidget {
  final Lead lead;

  const LeadDetailView({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Lead'),
      ),
      body: Consumer<LeadViewModel>(
        builder: (context, vm, child) {
          // Busca o lead atualizado na lista caso tenha ocorrido alguma mudança (como triagem)
          final currentLead = vm.leads.firstWhere((l) => l.id == lead.id, orElse: () => lead);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(currentLead),
                const SizedBox(height: 16),
                if (currentLead.triageSummary != null) ...[
                  const Text('Resumo da Triagem (IA)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Text(currentLead.triageSummary!),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: vm.isLoading ? null : () => _showTriageConfirmation(context, vm, currentLead),
                    icon: vm.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.psychology),
                    label: Text(vm.isLoading ? 'Processando...' : 'Iniciar Triagem IA'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(Lead l) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildRow('Nome', l.name),
            const Divider(),
            _buildRow('Email', l.email ?? 'Não informado'),
            const Divider(),
            _buildRow('Telefone', l.phone ?? 'Não informado'),
            const Divider(),
            _buildRow('Status', l.status.toUpperCase()),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
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
                if (vm.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Triagem concluída com sucesso!')));
                }
              });
            },
            child: const Text('CONFIRMAR'),
          ),
        ],
      ),
    );
  }
}
