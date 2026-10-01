import 'dart:async';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/googleapis_auth.dart';

import '../../config/app_config.dart';
import '../../domain/auth_failure.dart';
import '../../domain/corporate_account.dart';
import '../../domain/id_token.dart';
import '../../domain/models/signed_in_user.dart';

/// Sign-in, sign-out, or a change in granted scopes.
sealed class AuthSessionEvent {
  const AuthSessionEvent();
}

/// The current Google user, and whether Drive and Sheets scopes are granted.
class AuthSessionSignedIn extends AuthSessionEvent {
  const AuthSessionSignedIn({
    required this.user,
    required this.scopesGranted,
  });

  final SignedInUser user;
  final bool scopesGranted;
}

/// No Google user is signed in.
class AuthSessionSignedOut extends AuthSessionEvent {
  const AuthSessionSignedOut();
}

/// Corporate Google sign-in and the OAuth scopes used to read shops.
abstract class AuthRepository {
  bool get supportsInteractiveSignIn;

  Stream<AuthSessionEvent> get events;

  Future<void> ensureInitialized();

  /// Restores a previous Google session when the platform can do so quietly.
  Future<void> restoreSession();

  Future<void> signIn();

  Future<void> requestAuthorization();

  Future<AuthClient> authorizedClient();

  Future<void> signOut();
}

/// Google Sign-In backed [AuthRepository].
class GoogleAuthRepository implements AuthRepository {
  GoogleAuthRepository({
    CorporateAccountPolicy? corporateAccountPolicy,
    GoogleSignIn? googleSignIn,
  }) : _policy =
           corporateAccountPolicy ??
           CorporateAccountPolicy(requiredDomain: AppConfig.hostedDomainOrNull),
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  static const scopes = <String>[
    sheets.SheetsApi.spreadsheetsScope,
    drive.DriveApi.driveReadonlyScope,
  ];

  final CorporateAccountPolicy _policy;
  final GoogleSignIn _googleSignIn;

  final StreamController<AuthSessionEvent> _events =
      StreamController<AuthSessionEvent>.broadcast();
  StreamSubscription<GoogleSignInAuthenticationEvent>? _subscription;
  GoogleSignInAccount? _account;
  var _initialized = false;
  var _suppressPlatformSignIn = false;

  @override
  bool get supportsInteractiveSignIn => _googleSignIn.supportsAuthenticate();

  @override
  Stream<AuthSessionEvent> get events => _events.stream;

  @override
  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }
    if (!AppConfig.hasWebClientId) {
      throw const MissingClientIdFailure();
    }

    try {
      await _googleSignIn.initialize(
        clientId: kIsWeb ? AppConfig.webClientId : null,
        serverClientId: kIsWeb ? null : AppConfig.webClientId,
        hostedDomain: AppConfig.hostedDomainOrNull,
      );
    } on GoogleSignInException catch (error) {
      throw mapGoogleSignInException(error);
    }

    _subscription ??= _googleSignIn.authenticationEvents.listen(
      _onAuthenticationEvent,
      onError: _onAuthenticationError,
    );
    _initialized = true;
  }

  @override
  Future<void> restoreSession() async {
    final Future<GoogleSignInAccount?>? pending = _googleSignIn
        .attemptLightweightAuthentication();
    if (pending == null) {
      return;
    }

    try {
      final account = await pending;
      if (account != null && _account?.id != account.id) {
        await _publish(account, interactive: false);
      }
    } on GoogleSignInException catch (error) {
      throw mapGoogleSignInException(error);
    }
  }

  @override
  Future<void> signIn() async {
    if (!_googleSignIn.supportsAuthenticate()) {
      throw const AuthConfigurationFailure(
        'Use the Google sign-in button on this platform.',
      );
    }

    _suppressPlatformSignIn = true;
    try {
      final account = await _googleSignIn.authenticate(scopeHint: scopes);
      await _publish(account, interactive: true);
    } on GoogleSignInException catch (error) {
      throw mapGoogleSignInException(error);
    } finally {
      _suppressPlatformSignIn = false;
    }
  }

  @override
  Future<void> requestAuthorization() async {
    final account = _account;
    if (account == null) {
      throw const AuthConfigurationFailure(
        'Sign in before granting access.',
      );
    }
    await _publish(account, interactive: true);
  }

  @override
  Future<AuthClient> authorizedClient() async {
    final account = _account;
    if (account == null) {
      throw const AuthConfigurationFailure('Sign in to load stores.');
    }

    final authorization = await account.authorizationClient
        .authorizationForScopes(scopes);
    if (authorization == null) {
      throw const AuthConfigurationFailure(
        'Grant access to Google Drive and Sheets, then retry.',
      );
    }
    return authorization.authClient(scopes: scopes);
  }

  @override
  Future<void> signOut() async {
    _account = null;
    await _googleSignIn.signOut();
  }

  void _onAuthenticationEvent(GoogleSignInAuthenticationEvent event) {
    switch (event) {
      case GoogleSignInAuthenticationEventSignIn():
        if (_suppressPlatformSignIn) {
          return;
        }
        unawaited(
          _publish(event.user, interactive: false).then<void>(
            (_) {},
            onError: (Object error, StackTrace _) {
              _events.addError(_asAuthFailure(error));
            },
          ),
        );
      case GoogleSignInAuthenticationEventSignOut():
        _account = null;
        _events.add(const AuthSessionSignedOut());
    }
  }

  void _onAuthenticationError(Object error) {
    _events.addError(_asAuthFailure(error));
  }

  Future<void> _publish(
    GoogleSignInAccount account, {
    required bool interactive,
  }) async {
    _account = account;
    final hostedDomain = hostedDomainFromIdToken(
      account.authentication.idToken,
    );
    final rejection = _policy.rejectionMessage(
      hostedDomain: hostedDomain,
      email: account.email,
    );
    if (rejection != null) {
      await _googleSignIn.signOut();
      throw NonCorporateAccountFailure(rejection);
    }

    GoogleSignInClientAuthorization? authorization = await account
        .authorizationClient
        .authorizationForScopes(scopes);
    if (authorization == null && interactive) {
      try {
        authorization = await account.authorizationClient.authorizeScopes(
          scopes,
        );
      } on GoogleSignInException catch (error) {
        throw mapGoogleSignInException(error);
      }
    }

    _events.add(
      AuthSessionSignedIn(
        user: SignedInUser(
          email: account.email,
          displayName: account.displayName,
          photoUrl: account.photoUrl,
        ),
        scopesGranted: authorization != null,
      ),
    );
  }
}

AuthFailure mapGoogleSignInException(GoogleSignInException exception) {
  return switch (exception.code) {
    GoogleSignInExceptionCode.canceled => const SignInCanceledFailure(),
    GoogleSignInExceptionCode.clientConfigurationError ||
    GoogleSignInExceptionCode.providerConfigurationError =>
      AuthConfigurationFailure(
        exception.description ??
            'Google sign-in is not configured for this platform.',
      ),
    _ => AuthConfigurationFailure(
      exception.description ?? 'Google sign-in failed. Try again.',
    ),
  };
}

AuthFailure _asAuthFailure(Object error) {
  if (error is AuthFailure) {
    return error;
  }
  if (error is GoogleSignInException) {
    return mapGoogleSignInException(error);
  }
  return AuthConfigurationFailure('Google sign-in failed. Try again.');
}
