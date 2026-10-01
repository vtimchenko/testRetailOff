import 'package:flutter/material.dart';

import '../../../core/theme/rozetka_theme.dart';

/// Fallback used where Google does not provide a rendered sign-in button.
Widget buildPlatformSignInButton() {
  return const Text(
    'Google sign-in is not available on this platform.',
    textAlign: TextAlign.center,
    style: TextStyle(color: RozetkaColors.muted),
  );
}
