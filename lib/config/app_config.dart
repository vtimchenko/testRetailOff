/// App settings that are safe to ship in a client.
///
/// Paste the OAuth **Web client ID** from Google Cloud Console into
/// [webClientId]. Use the same value in the `google-signin-client_id` meta tag
/// in `web/index.html`. Do not put a service-account JSON file or private key
/// in this project.
abstract final class AppConfig {
  /// OAuth 2.0 Web client ID (`….apps.googleusercontent.com`).
  ///
  /// Google Cloud Console → APIs & Services → Credentials → OAuth 2.0 Client
  /// IDs → Web application.
  static const webClientId = '624914796390-tsi4po1n6tp2qb8r8dibfvs0pt2eqo7f.apps.googleusercontent.com';

  /// Workspace domain without `@`, for example `company.com`.
  ///
  /// Leave this empty to allow any Google Workspace account. Consumer accounts
  /// such as `@gmail.com` are still rejected, because they have no Workspace
  /// hosted-domain claim.
  static const hostedDomain = '';

  /// Shared Drive folder that contains the `shops` spreadsheet.
  static const shopsFolderId = '1laH9VlO0R-i3WzhbrEuHfWkE1P0Gl6q_';

  /// Spreadsheet file name inside [shopsFolderId].
  static const shopsFileName = 'shops';

  static bool get hasWebClientId {
    return webClientId.isNotEmpty &&
        !webClientId.contains('YOUR_WEB_CLIENT_ID') &&
        webClientId.endsWith('.apps.googleusercontent.com');
  }

  static String? get hostedDomainOrNull {
    final domain = hostedDomain.trim().toLowerCase();
    if (domain.isEmpty) {
      return null;
    }
    return domain.startsWith('@') ? domain.substring(1) : domain;
  }
}
