import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';

/// Lays out input controls side-by-side on desktop/tablet, and stacks them vertically on mobile.
class AdaptiveFormRow extends StatelessWidget {
  const AdaptiveFormRow({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  /// The child form fields to lay out.
  final List<Widget> children;

  /// The spacing/gap size between elements.
  final double spacing;

  /// Vertical alignment of elements when in Row mode.
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final isNarrow = context.isMobileOrSmallTablet;

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) SizedBox(height: spacing),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          Expanded(child: children[i]),
          if (i < children.length - 1) SizedBox(width: spacing),
        ],
      ],
    );
  }
}
