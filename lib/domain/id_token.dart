import 'dart:convert';

/// Reads the `hd` (hosted domain) claim from a Google ID token.
///
/// The token is not signature-checked here. Drive folder permissions still
/// decide whether the account can read the shops file. This check only stops
/// consumer accounts before that call.
String? hostedDomainFromIdToken(String? idToken) {
  if (idToken == null || idToken.isEmpty) {
    return null;
  }

  final parts = idToken.split('.');
  if (parts.length < 2) {
    return null;
  }

  try {
    final normalized = base64Url.normalize(parts[1]);
    final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));
    if (payload is! Map) {
      return null;
    }
    final hostedDomain = payload['hd'];
    if (hostedDomain is! String || hostedDomain.trim().isEmpty) {
      return null;
    }
    return hostedDomain.trim().toLowerCase();
  } on FormatException {
    return null;
  }
}
