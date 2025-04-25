import 'package:flutter/material.dart';
import 'package:chinese_odysee/ui/theme/app_theme.dart';

/// Loading indicator widget
class LoadingIndicator extends StatelessWidget {
  /// Size of the loading indicator
  final double size;
  
  /// Color of the loading indicator
  final Color? color;
  
  /// Whether to show a text message
  final bool showText;
  
  /// Text to display
  final String text;

  /// Creates a new [LoadingIndicator] widget
  const LoadingIndicator({
    super.key,
    this.size = 40.0,
    this.color,
    this.showText = false,
    this.text = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              color: color ?? AppTheme.primaryColor,
              strokeWidth: 4.0,
            ),
          ),
          if (showText) ...[
            const SizedBox(height: 16.0),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ],
      ),
    );
  }
}
