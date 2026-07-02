import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../viewmodels/lead_viewmodel.dart';
import '../../widgets/lead_list_tile.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/empty_state.dart';
import 'lead_detail_screen.dart';
import 'lead_form_screen.dart';

class LeadsListScreen extends StatefulWidget {
  const LeadsListScreen({super.key});

  @override
  State<LeadsListScreen> createState() => _LeadsListScreenState();
}

class _LeadsListScreenState extends State<LeadsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LeadViewModel>(context, listen: false).fetchLeads();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Leads Cadastrados'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<LeadViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading && vm.leads.isEmpty) {
            return const LoadingState(label: 'Carregando lista de leads...');
          }
          if (vm.errorMessage != null && vm.leads.isEmpty) {
            return ErrorState(
              message: 'Não foi possível buscar a lista de leads.',
              onRetry: vm.fetchLeads,
            );
          }

          if (vm.leads.isEmpty) {
            return const EmptyState(
              message: 'Nenhum lead encontrado no sistema.',
              icon: Icons.people_outline,
            );
          }

          return RefreshIndicator(
            onRefresh: vm.fetchLeads,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: vm.leads.length,
              itemBuilder: (context, index) {
                final lead = vm.leads[index];
                return LeadListTile(
                  lead: lead,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LeadDetailScreen(lead: lead),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LeadFormScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}
