import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:test_retail_off/app.dart';
import 'package:test_retail_off/data/repositories/google_auth_repository.dart';
import 'package:test_retail_off/data/repositories/shop_repository.dart';
import 'package:test_retail_off/domain/auth_failure.dart';
import 'package:test_retail_off/domain/models/shop.dart';
import 'package:test_retail_off/domain/models/signed_in_user.dart';

void main() {
  testWidgets('shows the client id error and keeps it after Retry', (
    tester,
  ) async {
    await tester.pumpWidget(
      RetailApp(
        authRepository: _FailingAuthRepository(const MissingClientIdFailure()),
        shopRepository: _EmptyShopRepository(),
        storePreferences: _MemoryPreferences(),
      ),
    );
    await _pumpUntil(tester, find.textContaining('OAuth Web Client ID'));

    expect(find.text('Sign in with Google'), findsOneWidget);

    await tester.tap(find.byKey(const Key('retry-button')));
    await _pumpUntil(tester, find.textContaining('OAuth Web Client ID'));
  });

  testWidgets('shows the saved store in the app bar and returns to login', (
    tester,
  ) async {
    final auth = _SessionAuthRepository(
      const AuthSessionSignedIn(
        user: SignedInUser(email: 'a@company.com', displayName: 'Ada'),
        scopesGranted: true,
      ),
    );
    final preferences = _MemoryPreferences()..savedId = '2';

    await tester.pumpWidget(
      RetailApp(
        authRepository: auth,
        shopRepository: _ShopRepository(const [
          Shop(id: '1', name: 'North'),
          Shop(id: '2', name: 'South'),
        ]),
        storePreferences: preferences,
      ),
    );
    await _pumpUntil(tester, find.text('South'));

    expect(find.byKey(const Key('account-email')), findsOneWidget);
    expect(find.text('a@company.com'), findsOneWidget);

    await tester.tap(find.byKey(const Key('sign-out-button')));
    await _pumpUntil(
      tester,
      find.text('Sign in with your corporate Google account'),
    );
    expect(preferences.savedId, isNull);
  });
}

Future<void> _pumpUntil(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Timed out waiting for $finder');
}

class _FailingAuthRepository implements AuthRepository {
  _FailingAuthRepository(this.failure);

  final AuthFailure failure;

  @override
  bool get supportsInteractiveSignIn => true;

  @override
  Stream<AuthSessionEvent> get events => const Stream.empty();

  @override
  Future<void> ensureInitialized() async {
    throw failure;
  }

  @override
  Future<void> restoreSession() async {}

  @override
  Future<void> signIn() async {}

  @override
  Future<void> requestAuthorization() async {}

  @override
  Future<AuthClient> authorizedClient() => throw UnimplementedError();

  @override
  Future<void> signOut() async {}
}

class _SessionAuthRepository implements AuthRepository {
  _SessionAuthRepository(this.session);

  final AuthSessionSignedIn session;
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
    _events.add(session);
  }

  @override
  Future<void> signIn() async {}

  @override
  Future<void> requestAuthorization() async {}

  @override
  Future<AuthClient> authorizedClient() => throw UnimplementedError();

  @override
  Future<void> signOut() async {
    _events.add(const AuthSessionSignedOut());
  }
}

class _EmptyShopRepository implements ShopRepository {
  @override
  Future<List<Shop>> loadShops() async => const [];
}

class _ShopRepository implements ShopRepository {
  _ShopRepository(this.shops);

  final List<Shop> shops;

  @override
  Future<List<Shop>> loadShops() async => shops;
}

class _MemoryPreferences implements StorePreferenceRepository {
  String? savedId;

  @override
  Future<void> clear() async {
    savedId = null;
  }

  @override
  Future<String?> readSelectedStoreId() async => savedId;

  @override
  Future<void> saveSelectedStoreId(String id) async {
    savedId = id;
  }
}
