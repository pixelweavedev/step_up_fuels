import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/mobile_tokens.dart';
import 'package:step_up_fuels/shared/widgets/layout/mobile_page_scaffold.dart';
import 'package:step_up_fuels/shared/widgets/layout/responsive_header.dart';

/// Standard Form template for mobile/desktop.
/// Houses headers, input fields in scrollable area, and sticky bottom action buttons.
class FormPageTemplate extends StatelessWidget {
  const FormPageTemplate({
    super.key,
    required this.title,
    required this.formBody,
    required this.actions,
    this.subtitle,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final Widget formBody;
  final List<Widget> actions;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    final header = ResponsiveHeader(
      title: title,
      subtitle: subtitle,
      onBack: onBack,
    );

    // Build the sticky bottom actions bar
    final actionsBar = Container(
      padding: const EdgeInsets.all(AppMobileTokens.pageMargin),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: actions
              .map((a) => Padding(
                    padding: const EdgeInsets.only(
                      left: AppMobileTokens.spacingSM,
                    ),
                    child: a,
                  ))
              .toList(),
        ),
      ),
    );

    if (!isMobile) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppMobileTokens.pageMargin,
                ),
                child: formBody,
              ),
            ),
            actionsBar,
          ],
        ),
      );
    }

    // Mobile layout
    return MobilePageScaffold(
      applyPageMargin: false, // Custom margin internally
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppMobileTokens.pageMargin,
            ),
            child: header,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppMobileTokens.pageMargin,
              ),
              child: formBody,
            ),
          ),
          actionsBar,
        ],
      ),
    );
  }
}
