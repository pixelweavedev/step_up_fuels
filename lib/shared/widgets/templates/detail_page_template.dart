import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/mobile_tokens.dart';
import 'package:step_up_fuels/shared/widgets/layout/mobile_page_scaffold.dart';
import 'package:step_up_fuels/shared/widgets/layout/responsive_header.dart';

/// Standard Detail page template for mobile/desktop.
/// Structures header info, top KPI stats, content sections, and actions.
class DetailPageTemplate extends StatelessWidget {
  const DetailPageTemplate({
    super.key,
    required this.title,
    required this.sections,
    this.subtitle,
    this.statusWidget,
    this.metaText,
    this.actions,
    this.stats,
    this.floatingActionButton,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final Widget? statusWidget;
  final String? metaText;
  final List<Widget>? actions;
  final List<Widget>? stats;
  final List<Widget> sections;
  final Widget? floatingActionButton;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    final header = ResponsiveHeader(
      title: title,
      subtitle: subtitle,
      statusWidget: statusWidget,
      metaText: metaText,
      actions: actions,
      onBack: onBack,
    );

    // Build stats section adaptively
    Widget? statsSection;
    if (stats != null && stats!.isNotEmpty) {
      if (isMobile) {
        statsSection = Padding(
          padding: const EdgeInsets.only(bottom: AppMobileTokens.sectionGap),
          child: Column(
            children: stats!
                .map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppMobileTokens.spacingSM,
                    ),
                    child: s,
                  ),
                )
                .toList(),
          ),
        );
      } else {
        // Desktop / Tablet Grid / Row
        statsSection = Padding(
          padding: const EdgeInsets.only(bottom: AppMobileTokens.sectionGap),
          child: GridView.count(
            crossAxisCount: context.responsiveValue(desktop: 4, tablet: 2),
            crossAxisSpacing: AppMobileTokens.spacingMD,
            mainAxisSpacing: AppMobileTokens.spacingMD,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            children: stats!,
          ),
        );
      }
    }

    if (!isMobile) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            if (statsSection != null) statsSection,
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: sections,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile layout using a single scrolling container
    return MobilePageScaffold(
      floatingActionButton: floatingActionButton,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [header, if (statsSection != null) statsSection],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: AppMobileTokens.sectionGap,
                ),
                child: sections[index],
              );
            }, childCount: sections.length),
          ),
          // Cushion bottom of the list for FAB
          if (floatingActionButton != null)
            SliverToBoxAdapter(
              child: SizedBox(height: MobilePageScaffold.bottomFabSpacing),
            ),
        ],
      ),
    );
  }
}
