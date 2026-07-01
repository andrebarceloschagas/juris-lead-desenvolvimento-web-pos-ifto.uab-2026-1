import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/lead_viewmodel.dart';
import 'lead_detail_view.dart';

class LeadListView extends StatefulWidget {
  const LeadListView({super.key});

  @override
  State<LeadListView> createState() => _LeadListViewState();
}

class _LeadListViewState extends State<LeadListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LeadViewModel>(context, listen: false).fetchLeads();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeadViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading && vm.leads.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.errorMessage != null && vm.leads.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Erro: ${vm.errorMessage}'),
                ElevatedButton(
                  onPressed: () => vm.fetchLeads(),
                  child: const Text('Tentar Novamente'),
                )
              ],
            ),
          );
        }

        if (vm.leads.isEmpty) {
          return const Center(child: Text('Nenhum lead encontrado.'));
        }

        return RefreshIndicator(
          onRefresh: vm.fetchLeads,
          child: ListView.builder(
            itemCount: vm.leads.length,
            itemBuilder: (context, index) {
              final lead = vm.leads[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?'),
                ),
                title: Text(lead.name),
                subtitle: Text(lead.status.toUpperCase()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeadDetailView(lead: lead),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
