import 'package:flutter_test/flutter_test.dart';
import 'package:test_retail_off/domain/models/shop.dart';
import 'package:test_retail_off/domain/shops_sheet.dart';

void main() {
  group('shopsDriveQuery', () {
    test('scopes the lookup to the shared folder and spreadsheet type', () {
      final query = shopsDriveQuery(
        folderId: "folder'id",
        fileName: 'shops',
      );

      expect(query, contains(r"folder\'id"));
      expect(query, contains("name contains 'shops'"));
      expect(query, contains('trashed = false'));
      expect(query, contains(shopsSpreadsheetMimeType));
    });
  });

  group('pickShopsFile', () {
    test('prefers the exact shops spreadsheet over a lookalike name', () {
      const lookalike = DriveFileRef(
        id: '1',
        name: 'workshops',
        mimeType: shopsSpreadsheetMimeType,
      );
      const shops = DriveFileRef(
        id: '2',
        name: 'Shops',
        mimeType: shopsSpreadsheetMimeType,
      );

      expect(pickShopsFile([lookalike, shops], 'shops')?.id, '2');
    });

    test('returns null when the file is missing', () {
      expect(pickShopsFile(const [], 'shops'), isNull);
    });
  });

  group('parseShopsSheet', () {
    test('reads id and name columns and skips blank rows', () {
      final shops = parseShopsSheet(<List<Object?>>[
        ['Name', 'id', 'city'],
        ['North', 12, 'Kyiv'],
        ['', '13', 'Lviv'],
        ['South', '14', 'Odesa'],
      ]);

      expect(shops, [
        const Shop(id: '12', name: 'North'),
        const Shop(id: '14', name: 'South'),
      ]);
    });

    test('throws when the header is missing', () {
      expect(
        () => parseShopsSheet(<List<Object?>>[
          ['title'],
          ['North'],
        ]),
        throwsA(
          isA<ShopLoadException>().having(
            (error) => error.message,
            'message',
            contains('id and name'),
          ),
        ),
      );
    });
  });
}
