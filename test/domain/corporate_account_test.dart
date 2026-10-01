import 'package:flutter_test/flutter_test.dart';
import 'package:test_retail_off/domain/corporate_account.dart';

void main() {
  group('CorporateAccountPolicy', () {
    const anyWorkspace = CorporateAccountPolicy();
    const companyOnly = CorporateAccountPolicy(requiredDomain: 'company.com');

    test('rejects consumer accounts', () {
      expect(
        anyWorkspace.rejectionMessage(
          hostedDomain: null,
          email: 'person@gmail.com',
        ),
        contains('not a corporate Workspace account'),
      );
    });

    test('accepts any Workspace domain when none is required', () {
      expect(
        anyWorkspace.rejectionMessage(
          hostedDomain: 'other.com',
          email: 'a@other.com',
        ),
        isNull,
      );
    });

    test('rejects a Workspace account from another domain', () {
      expect(
        companyOnly.rejectionMessage(
          hostedDomain: 'Other.com',
          email: 'a@other.com',
        ),
        contains('@company.com'),
      );
    });

    test('accepts the required domain ignoring case', () {
      expect(
        companyOnly.rejectionMessage(
          hostedDomain: 'Company.com',
          email: 'a@company.com',
        ),
        isNull,
      );
    });
  });
}
