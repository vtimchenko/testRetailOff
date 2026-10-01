import 'package:flutter/material.dart';

/// Green "Sign in with Google" button for platforms that allow a custom button.
class CorporateSignInButton extends StatelessWidget {
  const CorporateSignInButton({
    required this.onPressed,
    required this.busy,
    this.label = 'Sign in with Google',
    super.key,
  });

  final VoidCallback? onPressed;
  final bool busy;
  final String label;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      key: const Key('sign-in-button'),
      onPressed: busy ? null : onPressed,
      child: busy
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(label),
    );
  }
}
