/// Decides whether a Google account belongs to the company Workspace.
class CorporateAccountPolicy {
  const CorporateAccountPolicy({this.requiredDomain});

  /// Workspace domain without `@`. Null accepts any Workspace account.
  final String? requiredDomain;

  /// Returns a banner message when the account must be rejected.
  String? rejectionMessage({
    required String? hostedDomain,
    required String email,
  }) {
    final domain = hostedDomain?.trim().toLowerCase();
    if (domain == null || domain.isEmpty) {
      return 'This Google account is not a corporate Workspace account. '
          'Sign in with your work account.';
    }

    final required = requiredDomain?.trim().toLowerCase();
    if (required == null || required.isEmpty || domain == required) {
      return null;
    }

    return 'Sign in with your @$required account. $email is outside the '
        'corporate domain.';
  }
}
