/// Reusable adaptive master-detail layout.
///
/// Desktop (≥ 1100px): Side-by-side split panel.
/// Tablet  (900–1100): Narrower split panel.
/// Mobile  (<  900px): Shows [master] only; tapping an item calls
///                     [onItemSelected] and the caller pushes [detail]
///                     as a full-screen page via [openDetail].
///
/// Usage (e.g., Customers screen):
/// ```dart
/// AdaptiveMasterDetail(
///   masterWidth: ResponsiveDimensions.masterListWidth(context),
///   master: CustomerMasterList(
///     onTap: (id) => AdaptiveMasterDetail.openDetail(
///       context,
///       detail: CustomerDetailPage(id: id),
///     ),
///   ),
///   detail: CustomerDetailView(),
///   hasSelection: selectedId != null,
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/responsive_layout.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';

class AdaptiveMasterDetail extends StatelessWidget {
  const AdaptiveMasterDetail({
    super.key,
    required this.master,
    required this.detail,
    required this.masterWidth,
    this.hasSelection = false,
    this.dividerColor,
  });

  /// The list / master panel widget.
  final Widget master;

  /// The detail panel widget.
  final Widget detail;

  /// Width for the master panel on desktop/tablet.
  /// Use [ResponsiveDimensions.masterListWidth(context)].
  final double masterWidth;

  /// Whether an item is currently selected (controls whether detail is shown
  /// on tablet — on desktop detail always occupies the remaining space).
  final bool hasSelection;

  final Color? dividerColor;

  @override
  Widget build(BuildContext context) {
    final device = ResponsiveLayout.device(context);

    // Mobile / small tablet: show master only; detail pushed as page via openDetail()
    if (device == DeviceType.mobile || device == DeviceType.smallTablet) {
      return master;
    }

    // Tablet / Desktop: side-by-side split
    return Row(
      children: [
        SizedBox(width: masterWidth, child: master),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: dividerColor ?? AppColors.darkBorder,
        ),
        Expanded(child: detail),
      ],
    );
  }

  /// Opens [detail] as a full-screen page over the master.
  ///
  /// Call this from [master]'s item tap callbacks on mobile so the detail
  /// always appears regardless of screen size, without every screen needing
  /// to know about routing or the current device type.
  static Future<void> openDetail(
    BuildContext context, {
    required Widget detail,
    String? title,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          backgroundColor: AppColors.darkBackground,
          appBar: AppBar(
            backgroundColor: AppColors.darkSurface,
            foregroundColor: AppColors.darkTextPrimary,
            title: title != null
                ? Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkTextPrimary,
                    ),
                  )
                : null,
            iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
          ),
          body: detail,
        ),
      ),
    );
  }
}
