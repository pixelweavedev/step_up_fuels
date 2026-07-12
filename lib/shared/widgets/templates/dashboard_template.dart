import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/mobile_tokens.dart';
import 'package:step_up_fuels/shared/widgets/layout/mobile_page_scaffold.dart';

/// Standard Dashboard template for mobile/desktop.
/// Houses greetings, warning alerts, KPI grid, chart layouts, and recent activities.
class DashboardTemplate extends StatelessWidget {
  const DashboardTemplate({
    super.key,
    required this.greeting,
    required this.kpis,
    required this.charts,
    this.alerts,
    this.recentActivity,
    this.floatingActionButton,
    this.onRefresh,
  });

  final Widget greeting;
  final List<Widget>? alerts;
  final List<Widget> kpis;
  final List<Widget> charts;
  final Widget? recentActivity;
  final Widget? floatingActionButton;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    // KPI layout: 2x2 grid on mobile/tablet, 4 columns on desktop
    Widget kpiSection;
    if (isMobile) {
      kpiSection = GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: AppMobileTokens.spacingSM,
        mainAxisSpacing: AppMobileTokens.spacingSM,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.8, // Compact height on mobile
        children: kpis,
      );
    } else {
      kpiSection = GridView.count(
        crossAxisCount: context.responsiveValue(desktop: 4, tablet: 2),
        crossAxisSpacing: AppMobileTokens.spacingMD,
        mainAxisSpacing: AppMobileTokens.spacingMD,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.5,
        children: kpis,
      );
    }

    // Charts layout: Stacked vertically on mobile, side-by-side or grid on desktop
    Widget chartsSection;
    if (isMobile) {
      chartsSection = Column(
        children: charts
            .map(
              (c) => Padding(
                padding: const EdgeInsets.only(
                  bottom: AppMobileTokens.sectionGap,
                ),
                child: c,
              ),
            )
            .toList(),
      );
    } else {
      chartsSection = GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: AppMobileTokens.spacingMD,
        mainAxisSpacing: AppMobileTokens.spacingMD,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.4,
        children: charts,
      );
    }

    if (!isMobile) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppMobileTokens.pageMargin,
            vertical: AppMobileTokens.pageMargin,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              greeting,
              const SizedBox(height: AppMobileTokens.sectionGap),
              if (alerts != null && alerts!.isNotEmpty) ...[
                Column(children: alerts!),
                const SizedBox(height: AppMobileTokens.sectionGap),
              ],
              kpiSection,
              const SizedBox(height: AppMobileTokens.sectionGap),
              chartsSection,
              if (recentActivity != null) ...[
                const SizedBox(height: AppMobileTokens.sectionGap),
                recentActivity!,
              ],
            ],
          ),
        ),
      );
    }

    // Mobile layout: Single scrolling container
    final List<Widget> slivers = [
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            greeting,
            const SizedBox(height: AppMobileTokens.sectionGap),
            if (alerts != null && alerts!.isNotEmpty) ...[
              Column(children: alerts!),
              const SizedBox(height: AppMobileTokens.sectionGap),
            ],
            kpiSection,
            const SizedBox(height: AppMobileTokens.sectionGap),
            chartsSection,
            if (recentActivity != null) ...[
              recentActivity!,
              const SizedBox(height: AppMobileTokens.sectionGap),
            ],
          ],
        ),
      ),
      if (floatingActionButton != null)
        SliverToBoxAdapter(
          child: SizedBox(height: MobilePageScaffold.bottomFabSpacing),
        ),
    ];

    Widget mainContent = CustomScrollView(slivers: slivers);

    if (onRefresh != null) {
      mainContent = RefreshIndicator(onRefresh: onRefresh!, child: mainContent);
    }

    return MobilePageScaffold(
      floatingActionButton: floatingActionButton,
      body: mainContent,
    );
  }
}
