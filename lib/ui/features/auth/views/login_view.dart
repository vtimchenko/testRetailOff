import 'package:flutter/material.dart';

import '../../../core/theme/rozetka_theme.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/error_banner.dart';
import '../view_models/auth_view_model.dart';
import 'corporate_sign_in_button.dart';
import 'platform_sign_in_button.dart';

/// First screen: corporate Google sign-in.
class LoginView extends StatelessWidget {
  const LoginView({required this.viewModel, super.key});

  final AuthViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ListenableBuilder(
                listenable: viewModel,
                builder: (context, _) {
                  return _LoginCard(viewModel: viewModel);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({required this.viewModel});

  final AuthViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final errorMessage = viewModel.errorMessage;
    final user = viewModel.user;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RozetkaColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: BrandMark()),
            const SizedBox(height: 20),
            const Text(
              'Retail',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: RozetkaColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in with your corporate Google account',
              textAlign: TextAlign.center,
              style: TextStyle(color: RozetkaColors.muted, height: 1.4),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 20),
              ErrorBanner(
                message: errorMessage,
                onRetry: viewModel.busy ? null : () => viewModel.retry(),
              ),
            ],
            const SizedBox(height: 24),
            if (viewModel.needsScopeGrant && user != null) ...[
              Text(
                'Signed in as ${user.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: RozetkaColors.ink),
              ),
              const SizedBox(height: 8),
              const Text(
                'Grant access to Google Drive and Sheets so the store list can load.',
                textAlign: TextAlign.center,
                style: TextStyle(color: RozetkaColors.muted, height: 1.4),
              ),
              const SizedBox(height: 16),
              CorporateSignInButton(
                busy: viewModel.busy,
                label: 'Grant access',
                onPressed: () => viewModel.grantAccess(),
              ),
              TextButton(
                onPressed: viewModel.busy ? null : () => viewModel.signOut(),
                child: const Text('Use another account'),
              ),
            ] else if (viewModel.supportsInteractiveSignIn)
              CorporateSignInButton(
                busy: viewModel.busy,
                onPressed: () => viewModel.signIn(),
              )
            else if (viewModel.googleReady)
              const Center(child: _WebSignInSlot()),
          ],
        ),
      ),
    );
  }
}

class _WebSignInSlot extends StatelessWidget {
  const _WebSignInSlot();

  @override
  Widget build(BuildContext context) {
    return buildPlatformSignInButton();
  }
}
