import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/googleapis_auth.dart';

import '../../config/app_config.dart';
import '../../domain/auth_failure.dart';
import '../../domain/models/shop.dart';
import '../../domain/shops_sheet.dart';
import 'shop_repository.dart';

/// Reads the shops spreadsheet with the signed-in user's OAuth token.
class DriveShopRepository implements ShopRepository {
  DriveShopRepository({
    required this.obtainClient,
    this.folderId = AppConfig.shopsFolderId,
    this.fileName = AppConfig.shopsFileName,
  });

  final Future<AuthClient> Function() obtainClient;
  final String folderId;
  final String fileName;

  @override
  Future<List<Shop>> loadShops() async {
    final AuthClient client;
    try {
      client = await obtainClient();
    } on AuthFailure catch (failure) {
      throw ShopLoadException(failure.message);
    }

    try {
      final driveApi = drive.DriveApi(client);
      final listed = await driveApi.files.list(
        q: shopsDriveQuery(folderId: folderId, fileName: fileName),
        spaces: 'drive',
        pageSize: 100,
        supportsAllDrives: true,
        includeItemsFromAllDrives: true,
        $fields: 'files(id,name,mimeType)',
      );
      final refs = [
        for (final file in listed.files ?? const <drive.File>[])
          if (file.id != null && file.name != null)
            DriveFileRef(
              id: file.id!,
              name: file.name!,
              mimeType: file.mimeType,
            ),
      ];
      final match = pickShopsFile(refs, fileName);
      if (match == null) {
        throw ShopLoadException(
          'The $fileName spreadsheet was not found in the shared folder.',
        );
      }

      final sheetsApi = sheets.SheetsApi(client);
      final range = await sheetsApi.spreadsheets.values.get(
        match.id,
        'A1:Z1000',
        valueRenderOption: 'UNFORMATTED_VALUE',
      );
      return parseShopsSheet(range.values);
    } on ShopLoadException {
      rethrow;
    } on drive.DetailedApiRequestError catch (error) {
      throw ShopLoadException(_messageForStatus(error.status));
    } finally {
      client.close();
    }
  }

  String _messageForStatus(int? status) {
    return switch (status) {
      401 =>
        'Your Google session expired. Sign in again and grant access to '
            'Drive and Sheets.',
      403 =>
        'This account cannot read the shared shops folder. Sign in with a '
            'corporate account that has access.',
      _ =>
        'Google Drive returned an error${status == null ? '' : ' ($status)'}. '
        'Try again.',
    };
  }
}
