import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/google_auth_repository.dart';
import '../../../../domain/auth_failure.dart';
import '../../../../domain/models/signed_in_user.dart';

/// Whether the login screen or the store screen should be visible.
enum AuthPhase { starting, signedOut, signedIn }

/// Tracks the Google session and turns plugin errors into banner copy.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required this.repository});

  final AuthRepository repository;
  StreamSubscription<AuthSessionEvent>? _subscription;

  AuthPhase phase = AuthPhase.starting;
  SignedInUser? user;
  String? errorMessage;
  var scopesGranted = false;
  var busy = false;
  var googleReady = false;

  bool get supportsInteractiveSignIn => repository.supportsInteractiveSignIn;

  bool get isReadyForStores =>
      phase == AuthPhase.signedIn && scopesGranted && user != null;

  bool get needsScopeGrant =>
      phase == AuthPhase.signedIn && !scopesGranted && user != null;

  Future<void> start() async {
    try {
      await repository.ensureInitialized();
      googleReady = true;
      _subscription ??= repository.events.listen(
        _onEvent,
        onError: _onError,
      );
      await repository.restoreSession();
      if (phase == AuthPhase.starting) {
        phase = AuthPhase.signedOut;
        notifyListeners();
      }
    } on AuthFailure catch (failure) {
      _applyFailure(failure);
    }
  }

  Future<void> signIn() async {
    await _run(() => repository.signIn());
  }

  Future<void> grantAccess() async {
    await _run(() => repository.requestAuthorization());
  }

  Future<void> retry() async {
    errorMessage = null;
    notifyListeners();
    if (needsScopeGrant) {
      await grantAccess();
      return;
    }
    if (user == null) {
      await start();
      if (errorMessage != null ||
          !supportsInteractiveSignIn ||
          isReadyForStores ||
          needsScopeGrant) {
        return;
      }
    }
    await signIn();
  }

  Future<void> signOut() async {
    errorMessage = null;
    busy = true;
    notifyListeners();
    try {
      await repository.signOut();
      user = null;
      scopesGranted = false;
      phase = AuthPhase.signedOut;
    } on AuthFailure catch (failure) {
      _applyFailure(failure);
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    errorMessage = null;
    busy = true;
    notifyListeners();
    try {
      await action();
    } on AuthFailure catch (failure) {
      _applyFailure(failure);
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void _onEvent(AuthSessionEvent event) {
    switch (event) {
      case AuthSessionSignedIn():
        user = event.user;
        scopesGranted = event.scopesGranted;
        phase = AuthPhase.signedIn;
        if (event.scopesGranted) {
          errorMessage = null;
        }
      case AuthSessionSignedOut():
        user = null;
        scopesGranted = false;
        phase = AuthPhase.signedOut;
    }
    notifyListeners();
  }

  void _onError(Object error) {
    if (error is AuthFailure) {
      _applyFailure(error);
      return;
    }
    _applyFailure(
      const AuthConfigurationFailure('Google sign-in failed. Try again.'),
    );
  }

  void _applyFailure(AuthFailure failure) {
    errorMessage = failure.message;
    if (failure is NonCorporateAccountFailure || user == null) {
      user = null;
      scopesGranted = false;
      phase = AuthPhase.signedOut;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel() ?? Future<void>.value());
    super.dispose();
  }
}
