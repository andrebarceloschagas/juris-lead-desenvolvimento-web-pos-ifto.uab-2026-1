import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class LoadingState extends StatelessWidget {
  final String label;

  const LoadingState({
    super.key,
    this.label = 'Carregando...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
