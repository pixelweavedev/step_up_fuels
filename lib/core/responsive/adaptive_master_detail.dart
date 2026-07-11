import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';

/// A presentation layout widget that displays side-by-side master/detail panels
/// on desktop/tablet, and only the master list on mobile/small-tablet.
class AdaptiveMasterDetail extends StatelessWidget {
  const AdaptiveMasterDetail({
    super.key,
    required this.master,
    required this.detail,
    required this.masterWidth,
    required this.hasSelection,
    this.dividerColor,
  });

  /// The master listing view.
  final Widget master;

  /// The detail view.
  final Widget detail;

  /// Fixed width of the master panel on larger screens.
  final double masterWidth;

  /// Whether an item is currently selected.
  final bool hasSelection;

  /// Divider color.
  final Color? dividerColor;

  @override
  Widget build(BuildContext context) {
    final isNarrow = context.isMobileOrSmallTablet;

    // Mobile / small tablet: show master list only.
    // Navigation is managed by parent features pushing details routes separately.
    if (isNarrow) {
      return master;
    }

    // Tablet / Desktop: side-by-side split.
    return Row(
      children: [
        SizedBox(width: masterWidth, child: master),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: dividerColor ?? AppColors.darkBorder,
        ),
        Expanded(
          child: hasSelection
              ? detail
              : const Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Center(
                    child: Text(
                      'Select an item to view details',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
