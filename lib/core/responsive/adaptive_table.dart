import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';

/// A generic responsive table layout that swaps to a card list on mobile screens,
/// and displays a horizontal scrollable DataTable on tablets and desktops.
class AdaptiveTable<T> extends StatelessWidget {
  const AdaptiveTable({
    super.key,
    required this.items,
    required this.columns,
    required this.rowsBuilder,
    required this.mobileCardBuilder,
    this.spacing = 12.0,
    this.padding = const EdgeInsets.all(16.0),
    this.noItemsPlaceholder,
  });

  /// Data items to render.
  final List<T> items;

  /// DataTable columns definition.
  final List<DataColumn> columns;

  /// Builder for DataTable rows.
  final List<DataRow> Function(BuildContext context, List<T> items) rowsBuilder;

  /// Card item builder for mobile screens.
  final Widget Function(BuildContext context, T item) mobileCardBuilder;

  /// Spacing between cards in mobile view.
  final double spacing;

  /// Outer padding around the table or cards.
  final EdgeInsets padding;

  /// Optional widget to display when items list is empty.
  final Widget? noItemsPlaceholder;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return noItemsPlaceholder ?? const SizedBox.shrink();
    }

    final isPhone = context.isMobile;

    if (isPhone) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(height: spacing),
        itemBuilder: (context, index) => mobileCardBuilder(context, items[index]),
      );
    }

    // Tablet & Desktop: Horizontal Scrollable DataTable
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: AppColors.darkBorder,
                ),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(AppColors.brandNavy),
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 56,
                  columns: columns,
                  rows: rowsBuilder(context, items),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
