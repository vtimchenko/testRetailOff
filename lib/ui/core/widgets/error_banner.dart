import 'package:flutter/material.dart';

import '../theme/rozetka_theme.dart';

/// Inline error with a Retry action.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: RozetkaColors.errorBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF4C7C3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.error_outline, color: RozetkaColors.error),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: RozetkaColors.ink,
                height: 1.35,
              ),
            ),
          ),
          TextButton(
            key: const Key('retry-button'),
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
