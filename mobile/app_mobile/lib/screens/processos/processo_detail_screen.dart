import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../viewmodels/processo_viewmodel.dart';
import '../../models/processo.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/error_state.dart';

class ProcessoDetailScreen extends StatefulWidget {
  final int processoId;

  const ProcessoDetailScreen({super.key, required this.processoId});

  @override
  State<ProcessoDetailScreen> createState() => _ProcessoDetailScreenState();
}

class _ProcessoDetailScreenState extends State<ProcessoDetailScreen> {
  Processo? _processo;
  bool _isLoading = true;
  String? _errorMessage;
  final _scrollController = ScrollController();
  final _movController = TextEditingController();
  bool _isAddingMov = false;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _movController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final vm = Provider.of<ProcessoViewModel>(context, listen: false);
    final proc = await vm.getProcesso(widget.processoId);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (proc != null) {
          _processo = proc;
        } else {
          _errorMessage = vm.errorMessage ?? 'Erro ao buscar detalhes do processo.';
        }
      });
    }
  }

  void _addMovimentacao() async {
    final text = _movController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isAddingMov = true;
    });

    final vm = Provider.of<ProcessoViewModel>(context, listen: false);
    final success = await vm.addMovimentacao(widget.processoId, text);

    if (mounted) {
      setState(() {
        _isAddingMov = false;
      });

      if (success) {
        _movController.clear();
        FocusScope.of(context).unfocus();
        
        // Refetch and then scroll down
        await _fetchDetails();
        
        // Scroll to the end of the list
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.errorMessage ?? 'Erro ao adicionar movimentação.'), backgroundColor: AppTheme.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Processo #${widget.processoId}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const LoadingState(label: 'Carregando detalhes do processo...')
          : _errorMessage != null
              ? ErrorState(message: _errorMessage!, onRetry: _fetchDetails)
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchDetails,
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              children: [
                // Info Card
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
                      Text(
                        _processo!.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      _buildRow('Cliente', _processo!.leadName ?? 'Lead #${_processo!.leadId}'),
                      const SizedBox(height: 8),
                      _buildRow('Status', _processo!.status.toUpperCase(), isStatus: true),
                      
                      if (_processo!.description != null && _processo!.description!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Descrição:',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _processo!.description!,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Movimentações Header
                Text(
                  'Histórico de Movimentações',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                // Movimentações List
                if (_processo!.movimentacoes.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Center(
                      child: Text(
                        'Nenhuma movimentação registrada.',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _processo!.movimentacoes.length,
                    itemBuilder: (context, idx) {
                      final mov = _processo!.movimentacoes[idx];
                      final dateStr = mov.createdAt != null
                          ? DateFormat('dd/MM/yyyy HH:mm').format(mov.createdAt!.toLocal())
                          : '';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mov.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dateStr,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),

        // Campo de entrada fixo no final
        Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 12,
          ),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            border: Border(
              top: BorderSide(color: AppTheme.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _movController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Adicionar movimentação...',
                    fillColor: AppTheme.background,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppTheme.primary, width: 1),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _isAddingMov
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary)),
                    )
                  : CircleAvatar(
                      backgroundColor: AppTheme.primary,
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                        onPressed: _addMovimentacao,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value, {bool isStatus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        isStatus
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ],
    );
  }
}
