import 'package:flutter/material.dart';

import '../theme/rozetka_theme.dart';

/// Green mark used on the login card.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: RozetkaColors.green,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.storefront, color: Colors.white, size: 40),
    );
  }
}
