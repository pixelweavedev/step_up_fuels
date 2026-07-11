import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/mobile_tokens.dart';
import 'package:step_up_fuels/shared/widgets/layout/mobile_page_scaffold.dart';
import 'package:step_up_fuels/shared/widgets/layout/responsive_header.dart';
import 'package:step_up_fuels/shared/widgets/layout/responsive_section.dart';

/// Standard List template for mobile ERP pages.
/// Houses search, filter rows (auto-stacking), lists (sliver-based), and FAB padding.
class ListPageTemplate extends StatelessWidget {
  const ListPageTemplate({
    super.key,
    required this.title,
    required this.body,
    this.searchWidget,
    this.filterWidget,
    this.actions,
    this.floatingActionButton,
    this.onRefresh,
    this.isSliver = false,
  });

  final String title;
  final Widget body;
  final Widget? searchWidget;
  final Widget? filterWidget;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Future<void> Function()? onRefresh;
  final bool isSliver;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    if (!isMobile) {
      // Return a desktop-compatible layout that displays sections cleanly.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResponsiveHeader(
            title: title,
            actions: actions,
          ),
          if (searchWidget != null || filterWidget != null) ...[
            ResponsiveSection(
              children: [
                if (searchWidget != null) searchWidget!,
                if (filterWidget != null) filterWidget!,
              ],
            ),
            const SizedBox(height: AppMobileTokens.spacingMD),
          ],
          Expanded(
            child: body,
          ),
        ],
      );
    }

    // Mobile layout
    final List<Widget> slivers = [
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ResponsiveHeader(
              title: title,
              actions: actions,
            ),
            if (searchWidget != null) ...[
              searchWidget!,
              const SizedBox(height: AppMobileTokens.spacingMD),
            ],
            if (filterWidget != null) ...[
              filterWidget!,
              const SizedBox(height: AppMobileTokens.spacingMD),
            ],
          ],
        ),
      ),
      if (isSliver)
        body
      else
        SliverFillRemaining(
          child: body,
        ),
      // Add bottom spacing for FAB when present
      if (floatingActionButton != null)
        SliverToBoxAdapter(
          child: SizedBox(
            height: MobilePageScaffold.bottomFabSpacing,
          ),
        ),
    ];

    Widget mainContent = CustomScrollView(
      slivers: slivers,
    );

    if (onRefresh != null) {
      mainContent = RefreshIndicator(
        onRefresh: onRefresh!,
        child: mainContent,
      );
    }

    return MobilePageScaffold(
      floatingActionButton: floatingActionButton,
      body: mainContent,
    );
  }
}
