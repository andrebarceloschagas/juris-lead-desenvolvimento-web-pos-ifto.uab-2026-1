import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../viewmodels/processo_viewmodel.dart';
import '../../viewmodels/lead_viewmodel.dart';
import '../../widgets/processo_list_tile.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/empty_state.dart';
import 'processo_detail_screen.dart';

class ProcessosListScreen extends StatefulWidget {
  const ProcessosListScreen({super.key});

  @override
  State<ProcessosListScreen> createState() => _ProcessosListScreenState();
}

class _ProcessosListScreenState extends State<ProcessosListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  int? _selectedLeadId;
  bool _isFormExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProcessoViewModel>(context, listen: false).fetchProcessos();
      Provider.of<LeadViewModel>(context, listen: false).fetchLeads();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _selectedLeadId != null) {
      final vm = Provider.of<ProcessoViewModel>(context, listen: false);
      final success = await vm.createProcesso(
        _selectedLeadId!,
        _titleController.text.trim(),
        _descController.text.trim(),
      );
      if (success != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Processo criado com sucesso!'), backgroundColor: AppTheme.success),
        );
        _titleController.clear();
        _descController.clear();
        setState(() {
          _selectedLeadId = null;
          _isFormExpanded = false;
        });
        vm.fetchProcessos();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.errorMessage ?? 'Erro ao criar processo.'), backgroundColor: AppTheme.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final processoVM = Provider.of<ProcessoViewModel>(context);
    final leadVM = Provider.of<LeadViewModel>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Processos'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Formulário colapsável de novo processo
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: ExpansionTile(
              initiallyExpanded: _isFormExpanded,
              onExpansionChanged: (val) {
                setState(() {
                  _isFormExpanded = val;
                });
              },
              title: Text(
                'Novo Processo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
              ),
              leading: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primary),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Dropdown de Leads
                        DropdownButtonFormField<int>(
                          value: _selectedLeadId,
                          decoration: const InputDecoration(
                            labelText: 'Selecione o Lead *',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          items: leadVM.leads.map((l) {
                            return DropdownMenuItem<int>(
                              value: l.id,
                              child: Text(l.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedLeadId = val;
                            });
                          },
                          validator: (val) => val == null ? 'Por favor, selecione um lead.' : null,
                        ),
                        const SizedBox(height: 12),
                        
                        // Título do Processo
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Título do Processo *',
                            prefixIcon: Icon(Icons.title_rounded),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Insira o título.' : null,
                        ),
                        const SizedBox(height: 12),
                        
                        // Descrição do Processo
                        TextFormField(
                          controller: _descController,
                          decoration: const InputDecoration(
                            labelText: 'Descrição',
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        
                        CustomButton(
                          label: 'ABRIR PROCESSO',
                          onPressed: _submit,
                          isLoading: processoVM.isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de processos
          Expanded(
            child: Consumer<ProcessoViewModel>(
              builder: (context, vm, child) {
                if (vm.isLoading && vm.processos.isEmpty) {
                  return const LoadingState(label: 'Carregando processos...');
                }
                if (vm.errorMessage != null && vm.processos.isEmpty) {
                  return ErrorState(
                    message: 'Falha ao carregar processos.',
                    onRetry: vm.fetchProcessos,
                  );
                }
                if (vm.processos.isEmpty) {
                  return const EmptyState(
                    message: 'Nenhum processo em andamento.',
                    icon: Icons.folder_open_rounded,
                  );
                }

                return RefreshIndicator(
                  onRefresh: vm.fetchProcessos,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: vm.processos.length,
                    itemBuilder: (context, index) {
                      final proc = vm.processos[index];
                      return ProcessoListTile(
                        processo: proc,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProcessoDetailScreen(processoId: proc.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
