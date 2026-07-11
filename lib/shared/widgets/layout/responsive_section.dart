import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/mobile_tokens.dart';

/// A responsive container that stacks children in a Column on mobile,
/// and aligns them in a Row on tablet/desktop.
class ResponsiveSection extends StatelessWidget {
  const ResponsiveSection({
    super.key,
    required this.children,
    this.spacing = AppMobileTokens.spacingMD,
    this.crossAxisAlignmentRow = CrossAxisAlignment.center,
    this.crossAxisAlignmentColumn = CrossAxisAlignment.stretch,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.equalWidthsOnDesktop = false,
  });

  final List<Widget> children;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignmentRow;
  final CrossAxisAlignment crossAxisAlignmentColumn;
  final MainAxisAlignment mainAxisAlignment;
  final bool equalWidthsOnDesktop;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    if (isMobile) {
      final List<Widget> columnChildren = [];
      for (int i = 0; i < children.length; i++) {
        columnChildren.add(children[i]);
        if (i < children.length - 1) {
          columnChildren.add(SizedBox(height: spacing));
        }
      }
      return Column(
        crossAxisAlignment: crossAxisAlignmentColumn,
        mainAxisAlignment: mainAxisAlignment,
        children: columnChildren,
      );
    } else {
      final List<Widget> rowChildren = [];
      for (int i = 0; i < children.length; i++) {
        final child = children[i];
        rowChildren.add(
          equalWidthsOnDesktop ? Expanded(child: child) : child,
        );
        if (i < children.length - 1) {
          rowChildren.add(SizedBox(width: spacing));
        }
      }
      return Row(
        crossAxisAlignment: crossAxisAlignmentRow,
        mainAxisAlignment: mainAxisAlignment,
        children: rowChildren,
      );
    }
  }
}
