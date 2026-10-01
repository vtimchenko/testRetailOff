import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:test_retail_off/data/repositories/google_auth_repository.dart';
import 'package:test_retail_off/domain/auth_failure.dart';
import 'package:test_retail_off/domain/models/signed_in_user.dart';
import 'package:test_retail_off/ui/features/auth/view_models/auth_view_model.dart';

void main() {
  group('AuthViewModel', () {
    test('restores a corporate session that already granted scopes', () async {
      final repository = FakeAuthRepository(
        restored: const AuthSessionSignedIn(
          user: SignedInUser(email: 'a@company.com'),
          scopesGranted: true,
        ),
      );
      final viewModel = AuthViewModel(repository: repository);

      await viewModel.start();

      expect(viewModel.isReadyForStores, isTrue);
      expect(viewModel.user?.email, 'a@company.com');
      expect(viewModel.errorMessage, isNull);
    });

    test('stays on the grant step when scopes are missing', () async {
      final repository = FakeAuthRepository(
        restored: const AuthSessionSignedIn(
          user: SignedInUser(email: 'a@company.com'),
          scopesGranted: false,
        ),
      );
      final viewModel = AuthViewModel(repository: repository);

      await viewModel.start();

      expect(viewModel.needsScopeGrant, isTrue);
      expect(viewModel.isReadyForStores, isFalse);
    });

    test('shows a banner when sign-in is canceled', () async {
      final repository = FakeAuthRepository(
        signInError: const SignInCanceledFailure(),
      );
      final viewModel = AuthViewModel(repository: repository);
      await viewModel.start();

      await viewModel.signIn();

      expect(viewModel.errorMessage, contains('canceled'));
      expect(viewModel.phase, AuthPhase.signedOut);
    });

    test('shows a banner for a non-corporate account', () async {
      final repository = FakeAuthRepository(
        signInError: const NonCorporateAccountFailure(
          'This Google account is not a corporate Workspace account.',
        ),
      );
      final viewModel = AuthViewModel(repository: repository);
      await viewModel.start();

      await viewModel.signIn();

      expect(viewModel.errorMessage, contains('corporate'));
      expect(viewModel.user, isNull);
    });
  });
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.restored, this.signInError});

  final AuthSessionSignedIn? restored;
  final AuthFailure? signInError;
  final StreamController<AuthSessionEvent> _events =
      StreamController<AuthSessionEvent>.broadcast();

  @override
  bool get supportsInteractiveSignIn => true;

  @override
  Stream<AuthSessionEvent> get events => _events.stream;

  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<void> restoreSession() async {
    final restored = this.restored;
    if (restored != null) {
      _events.add(restored);
    }
  }

  @override
  Future<void> signIn() async {
    final signInError = this.signInError;
    if (signInError != null) {
      throw signInError;
    }
  }

  @override
  Future<void> requestAuthorization() async {}

  @override
  Future<AuthClient> authorizedClient() {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    _events.add(const AuthSessionSignedOut());
  }
}
