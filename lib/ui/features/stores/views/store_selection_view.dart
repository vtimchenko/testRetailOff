import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/rozetka_theme.dart';
import '../../../core/widgets/account_actions.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../../domain/models/shop.dart';
import '../../../../domain/models/signed_in_user.dart';
import '../view_models/store_selection_view_model.dart';

/// Store dropdown backed by the shared shops spreadsheet.
class StoreSelectionView extends StatefulWidget {
  const StoreSelectionView({
    required this.viewModel,
    required this.user,
    required this.onSignOut,
    super.key,
  });

  final StoreSelectionViewModel viewModel;
  final SignedInUser user;
  final VoidCallback onSignOut;

  @override
  State<StoreSelectionView> createState() => _StoreSelectionViewState();
}

class _StoreSelectionViewState extends State<StoreSelectionView> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.viewModel.load());
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final viewModel = widget.viewModel;
        return Scaffold(
          appBar: AppBar(
            title: Text(viewModel.appBarTitle),
            actions: [
              AccountActions(
                user: widget.user,
                onSignOut: viewModel.loading ? null : widget.onSignOut,
              ),
            ],
          ),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _StoreCard(viewModel: viewModel),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.viewModel});

  final StoreSelectionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final errorMessage = viewModel.errorMessage;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RozetkaColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Store',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: RozetkaColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose the store you are working with.',
              style: TextStyle(color: RozetkaColors.muted),
            ),
            const SizedBox(height: 20),
            if (viewModel.loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (errorMessage != null)
              ErrorBanner(
                message: errorMessage,
                onRetry: () => viewModel.load(),
              )
            else
              DropdownMenu<Shop>(
                key: ValueKey(viewModel.selected?.id ?? 'none'),
                initialSelection: viewModel.selected,
                expandedInsets: EdgeInsets.zero,
                label: const Text('Store'),
                hintText: 'Select a store',
                enableSearch: false,
                requestFocusOnTap: false,
                dropdownMenuEntries: [
                  for (final shop in viewModel.shops)
                    DropdownMenuEntry<Shop>(value: shop, label: shop.name),
                ],
                onSelected: (shop) {
                  unawaited(viewModel.selectStore(shop));
                },
              ),
          ],
        ),
      ),
    );
  }
}
