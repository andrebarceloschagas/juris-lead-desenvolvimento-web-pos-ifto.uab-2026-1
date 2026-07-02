import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/lead_viewmodel.dart';
import 'viewmodels/dashboard_viewmodel.dart';
import 'viewmodels/consulta_viewmodel.dart';
import 'viewmodels/processo_viewmodel.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()..checkAuthStatus()),
        ChangeNotifierProvider(create: (_) => LeadViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => ConsultaViewModel()),
        ChangeNotifierProvider(create: (_) => ProcessoViewModel()),
      ],
      child: const JurisLeadApp(),
    ),
  );
}

class JurisLeadApp extends StatelessWidget {
  const JurisLeadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JurisLead Mobile',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Forçar Light Theme conforme preferência do usuário
      home: Consumer<AuthViewModel>(
        builder: (context, auth, child) {
          if (auth.currentUser != null) {
            return const DashboardScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
