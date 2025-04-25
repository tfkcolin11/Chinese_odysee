import 'package:flutter/material.dart';
import 'package:chinese_odysee/ui/theme/app_theme.dart';

/// Error display widget
class ErrorDisplay extends StatelessWidget {
  /// Error message to display
  final String message;
  
  /// Callback for retry button
  final VoidCallback? onRetry;
  
  /// Icon to display
  final IconData icon;

  /// Creates a new [ErrorDisplay] widget
  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppTheme.errorColor,
              size: 64.0,
            ),
            const SizedBox(height: 16.0),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
