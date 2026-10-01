import 'package:flutter/material.dart';

import '../../../domain/models/signed_in_user.dart';
import '../theme/rozetka_theme.dart';

/// Email, avatar, and sign-out control for the app bar.
class AccountActions extends StatelessWidget {
  const AccountActions({
    required this.user,
    required this.onSignOut,
    super.key,
  });

  final SignedInUser user;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Text(
            user.email,
            key: const Key('account-email'),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: RozetkaColors.muted,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        UserAvatar(user: user),
        IconButton(
          key: const Key('sign-out-button'),
          tooltip: 'Sign out',
          onPressed: onSignOut,
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({required this.user, super.key});

  final SignedInUser user;

  @override
  Widget build(BuildContext context) {
    final initial = _initial(user);
    final fallback = CircleAvatar(
      radius: 16,
      backgroundColor: RozetkaColors.green,
      child: Text(
        initial,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
    final photoUrl = user.photoUrl;
    if (photoUrl == null || photoUrl.isEmpty) {
      return fallback;
    }

    return ClipOval(
      child: Image.network(
        photoUrl,
        width: 32,
        height: 32,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }

  String _initial(SignedInUser user) {
    final source = (user.displayName ?? user.email).trim();
    if (source.isEmpty) {
      return '?';
    }
    return source[0].toUpperCase();
  }
}
