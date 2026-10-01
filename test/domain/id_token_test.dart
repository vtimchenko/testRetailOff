import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:test_retail_off/domain/id_token.dart';

void main() {
  group('hostedDomainFromIdToken', () {
    test('reads the hosted domain claim', () {
      final token = _jwt(<String, Object?>{'hd': 'Company.com', 'email': 'a@company.com'});

      expect(hostedDomainFromIdToken(token), 'company.com');
    });

    test('returns null for a consumer account', () {
      final token = _jwt(<String, Object?>{'email': 'person@gmail.com'});

      expect(hostedDomainFromIdToken(token), isNull);
    });

    test('returns null when the token is malformed', () {
      expect(hostedDomainFromIdToken('not-a-jwt'), isNull);
      expect(hostedDomainFromIdToken(null), isNull);
    });
  });
}

String _jwt(Map<String, Object?> payload) {
  final header = base64Url.encode(utf8.encode('{"alg":"none"}'));
  final body = base64Url.encode(utf8.encode(jsonEncode(payload)));
  return '$header.$body.signature';
}
