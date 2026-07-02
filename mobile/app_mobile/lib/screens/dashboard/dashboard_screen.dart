import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../widgets/hero_card.dart';
import '../../widgets/metric_card.dart';
import '../../widgets/section_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/error_state.dart';
import '../leads/leads_list_screen.dart';
import '../leads/lead_form_screen.dart';
import '../processos/processos_list_screen.dart';
import '../perfil/perfil_screen.dart';
import '../agenda/agenda_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardContentScreen(),
    const LeadsListScreen(),
    const AgendaScreen(),
    const ProcessosListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.border, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined),
              activeIcon: Icon(Icons.people_alt_rounded),
              label: 'Leads',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today_rounded),
              label: 'Agenda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_open_outlined),
              activeIcon: Icon(Icons.folder_rounded),
              label: 'Processos',
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardContentScreen extends StatefulWidget {
  const DashboardContentScreen({super.key});

  @override
  State<DashboardContentScreen> createState() => _DashboardContentScreenState();
}

class _DashboardContentScreenState extends State<DashboardContentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardViewModel>(context, listen: false).fetchMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('JurisLead CRM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, color: AppTheme.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PerfilScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const LoadingState(label: 'Carregando métricas...');
          }
          if (vm.errorMessage != null) {
            return ErrorState(
              message: 'Não foi possível carregar as métricas do painel.',
              onRetry: vm.fetchMetrics,
            );
          }

          return RefreshIndicator(
            onRefresh: vm.fetchMetrics,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 1. Hero Card
                const HeroCard(
                  title: 'Área do Atendimento',
                  subtitle: 'Acompanhe as métricas operacionais e gerencie seus casos jurídicos de forma centralizada.',
                ),
                const SizedBox(height: 24),

                // 2. Metrics Grid
                Text(
                  'Desempenho Geral',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    MetricCard(
                      label: 'Total de Leads',
                      value: vm.totalLeads.toString(),
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                    MetricCard(
                      label: 'Consultas Agendadas',
                      value: vm.pendingConsultas.toString(),
                      icon: Icons.calendar_today,
                      color: Colors.orange,
                    ),
                    MetricCard(
                      label: 'Processos Ativos',
                      value: vm.openProcessos.toString(),
                      icon: Icons.folder,
                      color: Colors.green,
                    ),
                    // Let's add Leads Novos as a 4th metric if we can
                    const MetricCard(
                      label: 'Leads Novos',
                      value: 'Ativo',
                      icon: Icons.star_border_rounded,
                      color: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // 3. Shortcuts Section
                Text(
                  'Atalhos Rápidos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: 'Novo Lead',
                        icon: Icons.add,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LeadFormScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        label: 'Meu Perfil',
                        icon: Icons.person_outline,
                        type: ButtonType.secondary,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PerfilScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // 4. Horizontal Prioridades Card list
                Text(
                  'Prioridades do Atendimento',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 130,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      SectionCard(
                        title: 'Triagem Pendente',
                        description: 'Há novos leads aguardando avaliação e classificação por Inteligência Artificial.',
                      ),
                      SectionCard(
                        title: 'Consultas Hoje',
                        description: 'Verifique a agenda de consultas marcadas para o dia de hoje com os leads convertidos.',
                      ),
                      SectionCard(
                        title: 'Prazos de Processo',
                        description: 'Acompanhe as últimas movimentações judiciais para evitar perda de prazos.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // 5. Fluxo do dia
                Text(
                  'Fluxo de Trabalho do Dia',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 130,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      SectionCard(
                        title: '1. Captação',
                        description: 'Cadastro de leads captados organicamente ou via campanhas de tráfego pago.',
                      ),
                      SectionCard(
                        title: '2. Qualificação',
                        description: 'Triagem assistida para identificar urgência e viabilidade jurídica do caso.',
                      ),
                      SectionCard(
                        title: '3. Fechamento',
                        description: 'Agendamento de consulta e conversão do lead qualificado em cliente.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
