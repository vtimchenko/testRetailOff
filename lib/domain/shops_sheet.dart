import 'models/shop.dart';

/// A Drive file the shops lookup can consider.
class DriveFileRef {
  const DriveFileRef({
    required this.id,
    required this.name,
    this.mimeType,
  });

  final String id;
  final String name;
  final String? mimeType;
}

const shopsSpreadsheetMimeType = 'application/vnd.google-apps.spreadsheet';

/// Failure while locating or reading the shops spreadsheet.
class ShopLoadException implements Exception {
  const ShopLoadException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Drive query for a spreadsheet whose name contains [fileName] in [folderId].
String shopsDriveQuery({
  required String folderId,
  required String fileName,
}) {
  return "name contains '${_escapeDriveQuery(fileName)}' "
      "and '${_escapeDriveQuery(folderId)}' in parents "
      'and trashed = false '
      "and mimeType = '$shopsSpreadsheetMimeType'";
}

/// Picks the spreadsheet named [expectedName], ignoring lookalike names.
DriveFileRef? pickShopsFile(List<DriveFileRef> files, String expectedName) {
  final expected = expectedName.trim().toLowerCase();
  final matches = files.where((file) {
    if (file.id.isEmpty) {
      return false;
    }
    final mimeType = file.mimeType;
    final isSpreadsheet =
        mimeType == null || mimeType == shopsSpreadsheetMimeType;
    if (!isSpreadsheet) {
      return false;
    }
    final name = file.name.trim().toLowerCase();
    return name == expected || name == '$expected.gsheet';
  }).toList();

  if (matches.isEmpty) {
    return null;
  }

  matches.sort((a, b) {
    final aExact = a.name.trim().toLowerCase() == expected;
    final bExact = b.name.trim().toLowerCase() == expected;
    if (aExact == bExact) {
      return 0;
    }
    return aExact ? -1 : 1;
  });
  return matches.first;
}

/// Reads `id` and `name` columns from a Sheets values range.
List<Shop> parseShopsSheet(List<List<Object?>>? rows) {
  if (rows == null || rows.isEmpty) {
    throw const ShopLoadException('The shops spreadsheet is empty.');
  }

  final header = rows.first
      .map((cell) => cell?.toString().trim().toLowerCase() ?? '')
      .toList();
  final idIndex = header.indexOf('id');
  final nameIndex = header.indexOf('name');
  if (idIndex < 0 || nameIndex < 0) {
    throw const ShopLoadException(
      'The shops spreadsheet must have id and name columns.',
    );
  }

  final shops = <Shop>[];
  for (final row in rows.skip(1)) {
    final id = _cell(row, idIndex);
    final name = _cell(row, nameIndex);
    if (id.isEmpty || name.isEmpty) {
      continue;
    }
    shops.add(Shop(id: id, name: name));
  }

  if (shops.isEmpty) {
    throw const ShopLoadException('The shops spreadsheet has no stores.');
  }
  return shops;
}

String _cell(List<Object?> row, int index) {
  if (index >= row.length) {
    return '';
  }
  final value = row[index];
  if (value == null) {
    return '';
  }
  if (value is num && value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toString().trim();
}

String _escapeDriveQuery(String value) => value.replaceAll("'", r"\'");
