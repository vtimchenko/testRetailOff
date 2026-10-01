import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/repositories/drive_shop_repository.dart';
import 'data/repositories/google_auth_repository.dart';
import 'data/repositories/shared_preferences_store_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final authRepository = GoogleAuthRepository();
  runApp(
    RetailApp(
      authRepository: authRepository,
      shopRepository: DriveShopRepository(
        obtainClient: authRepository.authorizedClient,
      ),
      storePreferences: SharedPreferencesStoreRepository(preferences),
    ),
  );
}
