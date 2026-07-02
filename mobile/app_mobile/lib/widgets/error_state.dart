import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import 'custom_button.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppTheme.danger,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Ocorreu um erro',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: CenterAligning().alignment == null ? TextAlign.center : null,
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Tentar Novamente',
              onPressed: onRetry,
              type: ButtonType.secondary,
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }
}

class CenterAligning {
  final dynamic alignment = null;
}
