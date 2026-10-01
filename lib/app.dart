import 'dart:async';

import 'package:flutter/material.dart';

import 'data/repositories/google_auth_repository.dart';
import 'data/repositories/shop_repository.dart';
import 'ui/core/theme/rozetka_theme.dart';
import 'ui/features/auth/view_models/auth_view_model.dart';
import 'ui/features/auth/views/login_view.dart';
import 'ui/features/stores/view_models/store_selection_view_model.dart';
import 'ui/features/stores/views/store_selection_view.dart';

/// Switches between sign-in and store selection.
class RetailApp extends StatefulWidget {
  const RetailApp({
    required this.authRepository,
    required this.shopRepository,
    required this.storePreferences,
    super.key,
  });

  final AuthRepository authRepository;
  final ShopRepository shopRepository;
  final StorePreferenceRepository storePreferences;

  @override
  State<RetailApp> createState() => _RetailAppState();
}

class _RetailAppState extends State<RetailApp> {
  late final AuthViewModel _authViewModel;
  late final StoreSelectionViewModel _storeViewModel;

  @override
  void initState() {
    super.initState();
    _authViewModel = AuthViewModel(repository: widget.authRepository);
    _storeViewModel = StoreSelectionViewModel(
      shopRepository: widget.shopRepository,
      preferences: widget.storePreferences,
    );
    unawaited(_authViewModel.start());
  }

  @override
  void dispose() {
    _authViewModel.dispose();
    _storeViewModel.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    await _storeViewModel.clear();
    await _authViewModel.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retail',
      theme: buildRozetkaTheme(),
      home: ListenableBuilder(
        listenable: _authViewModel,
        builder: (context, _) {
          if (_authViewModel.phase == AuthPhase.starting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final user = _authViewModel.user;
          if (_authViewModel.isReadyForStores && user != null) {
            return StoreSelectionView(
              viewModel: _storeViewModel,
              user: user,
              onSignOut: _signOut,
            );
          }

          return LoginView(viewModel: _authViewModel);
        },
      ),
    );
  }
}
