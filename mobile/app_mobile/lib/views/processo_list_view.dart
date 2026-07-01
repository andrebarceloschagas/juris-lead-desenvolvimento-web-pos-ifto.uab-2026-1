import 'package:flutter/material.dart';

class ProcessoListView extends StatelessWidget {
  const ProcessoListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Para fins deste MVP, a tela de processos mostrará apenas uma mensagem de espaço reservado, 
    // ou poderia buscar de um viewmodel semelhante ao LeadViewModel.
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.folder_open, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Módulo de Processos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Em breve, você poderá consultar processos aqui.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
