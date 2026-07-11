import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';

/// An adaptive grid that dynamically lays out children using a fixed count or max extent.
class AdaptiveGrid extends StatelessWidget {
  /// Grid with a predefined column count mapping for each [ScreenType].
  const AdaptiveGrid.fixed({
    super.key,
    required Map<ScreenType, int> columns,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.childAspectRatio = 1.0,
    this.padding = EdgeInsets.zero,
  })  : _columns = columns,
        _maxExtent = null;

  /// Grid that scales columns automatically based on a maximum item width constraint.
  const AdaptiveGrid.maxExtent({
    super.key,
    required double maxExtent,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.childAspectRatio = 1.0,
    this.padding = EdgeInsets.zero,
  })  : _columns = null,
        _maxExtent = maxExtent;

  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry padding;

  final Map<ScreenType, int>? _columns;
  final double? _maxExtent;

  @override
  Widget build(BuildContext context) {
    final delegate = _buildDelegate(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      gridDelegate: delegate,
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  SliverGridDelegate _buildDelegate(BuildContext context) {
    if (_maxExtent != null) {
      return SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: _maxExtent,
        mainAxisSpacing: runSpacing,
        crossAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      );
    } else {
      final columns = _getColumns(context);
      return SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: runSpacing,
        crossAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      );
    }
  }

  int _getColumns(BuildContext context) {
    if (_columns == null) return 1;
    final type = context.screenType;
    return _columns[type] ??
        _columns[ScreenType.desktop] ??
        _columns[ScreenType.tablet] ??
        _columns[ScreenType.mobile] ??
        1;
  }
}

/// A sliver-based variant of [AdaptiveGrid] to be used inside [CustomScrollView].
class AdaptiveSliverGrid extends StatelessWidget {
  /// Sliver grid with a predefined column count mapping for each [ScreenType].
  const AdaptiveSliverGrid.fixed({
    super.key,
    required Map<ScreenType, int> columns,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.childAspectRatio = 1.0,
  })  : _columns = columns,
        _maxExtent = null;

  /// Sliver grid that scales columns automatically based on a maximum item width constraint.
  const AdaptiveSliverGrid.maxExtent({
    super.key,
    required double maxExtent,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.childAspectRatio = 1.0,
  })  : _columns = null,
        _maxExtent = maxExtent;

  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double childAspectRatio;

  final Map<ScreenType, int>? _columns;
  final double? _maxExtent;

  @override
  Widget build(BuildContext context) {
    final delegate = _buildDelegate(context);
    return SliverGrid(
      gridDelegate: delegate,
      delegate: SliverChildBuilderDelegate(
        (context, index) => children[index],
        childCount: children.length,
      ),
    );
  }

  SliverGridDelegate _buildDelegate(BuildContext context) {
    if (_maxExtent != null) {
      return SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: _maxExtent,
        mainAxisSpacing: runSpacing,
        crossAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      );
    } else {
      final columns = _getColumns(context);
      return SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: runSpacing,
        crossAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      );
    }
  }

  int _getColumns(BuildContext context) {
    if (_columns == null) return 1;
    final type = context.screenType;
    return _columns[type] ??
        _columns[ScreenType.desktop] ??
        _columns[ScreenType.tablet] ??
        _columns[ScreenType.mobile] ??
        1;
  }
}
