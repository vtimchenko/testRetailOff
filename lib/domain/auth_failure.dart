/// A sign-in or authorization failure with copy ready for the error banner.
sealed class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The OAuth web client ID is still the placeholder.
class MissingClientIdFailure extends AuthFailure {
  const MissingClientIdFailure()
    : super(
        'Paste the OAuth Web Client ID into lib/config/app_config.dart and '
        'the google-signin-client_id meta tag in web/index.html, then restart '
        'the app.',
      );
}

/// The Google account is a consumer account or outside the configured domain.
class NonCorporateAccountFailure extends AuthFailure {
  const NonCorporateAccountFailure(super.message);
}

/// The user closed the prompt or refused Drive / Sheets access.
class SignInCanceledFailure extends AuthFailure {
  const SignInCanceledFailure()
    : super(
        'Sign-in was canceled or permissions were denied. Use Retry to choose '
        'an account again.',
      );
}

/// Google Sign-In or the Cloud project is misconfigured.
class AuthConfigurationFailure extends AuthFailure {
  const AuthConfigurationFailure(super.message);
}
