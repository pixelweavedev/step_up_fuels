import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/mobile_tokens.dart';

/// Item model for [AppBottomSheetPicker].
class AppPickerItem<T> {
  const AppPickerItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.badge,
  });

  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final Widget? badge;
}

/// A mobile-first replacement for desktop dropdowns.
/// Displays an interactive form-field tile that opens a sleek Material 3 bottom sheet.
class AppBottomSheetPicker<T> extends StatelessWidget {
  const AppBottomSheetPicker({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.label,
    this.hint = 'Select an option',
    this.prefixIcon,
    this.title,
    this.isSearchable = false,
    this.searchHint = 'Search...',
    this.enabled = true,
    this.errorText,
    this.helperText,
  });

  final List<AppPickerItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final T? value;
  final String? label;
  final String hint;
  final IconData? prefixIcon;
  final String? title;
  final bool isSearchable;
  final String searchHint;
  final bool enabled;
  final String? errorText;
  final String? helperText;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<AppPickerItem<T>> items,
    T? selectedValue,
    bool isSearchable = false,
    String searchHint = 'Search...',
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BottomSheetContent<T>(
        title: title,
        items: items,
        selectedValue: selectedValue,
        isSearchable: isSearchable,
        searchHint: searchHint,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selectedItem = items.cast<AppPickerItem<T>?>().firstWhere(
      (item) => item?.value == value,
      orElse: () => null,
    );

    final borderColor = errorText != null
        ? AppColors.error
        : (isDark ? AppColors.darkBorder : AppColors.lightBorder);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: GoogleFonts.inter(
              fontSize: AppMobileTokens.fontCaption,
              fontWeight: FontWeight.w600,
              color: errorText != null
                  ? AppColors.error
                  : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
            ),
          ),
          const SizedBox(height: AppMobileTokens.spacingXS),
        ],
        InkWell(
          onTap: enabled
              ? () async {
                  FocusScope.of(context).unfocus();
                  final picked = await show<T>(
                    context: context,
                    title: title ?? label ?? hint,
                    items: items,
                    selectedValue: value,
                    isSearchable: isSearchable,
                    searchHint: searchHint,
                  );
                  if (picked != null || value != null) {
                    onChanged?.call(picked);
                  }
                }
              : null,
          borderRadius: BorderRadius.circular(AppMobileTokens.radiusMD),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppMobileTokens.inputMinHeight,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppMobileTokens.spacingMD,
              vertical: AppMobileTokens.spacingMD,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(AppMobileTokens.radiusMD),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(
                    prefixIcon,
                    size: AppMobileTokens.iconSM,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                  const SizedBox(width: AppMobileTokens.spacingMD),
                ] else if (selectedItem?.icon != null) ...[
                  Icon(
                    selectedItem!.icon,
                    size: AppMobileTokens.iconSM,
                    color: AppColors.brandAmber,
                  ),
                  const SizedBox(width: AppMobileTokens.spacingMD),
                ],
                Expanded(
                  child: Text(
                    selectedItem?.label ?? hint,
                    style: GoogleFonts.inter(
                      fontSize: AppMobileTokens.fontBody,
                      fontWeight: selectedItem != null
                          ? FontWeight.w500
                          : FontWeight.w400,
                      color: selectedItem != null
                          ? (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary)
                          : (isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (selectedItem?.badge != null) ...[
                  selectedItem!.badge!,
                  const SizedBox(width: AppMobileTokens.spacingSM),
                ],
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: AppMobileTokens.iconMD,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppMobileTokens.spacingXS),
          Text(
            errorText!,
            style: GoogleFonts.inter(
              fontSize: AppMobileTokens.fontMetadata,
              color: AppColors.error,
            ),
          ),
        ] else if (helperText != null) ...[
          const SizedBox(height: AppMobileTokens.spacingXS),
          Text(
            helperText!,
            style: GoogleFonts.inter(
              fontSize: AppMobileTokens.fontMetadata,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
          ),
        ],
      ],
    );
  }
}

class _BottomSheetContent<T> extends StatefulWidget {
  const _BottomSheetContent({
    required this.title,
    required this.items,
    this.selectedValue,
    this.isSearchable = false,
    this.searchHint = 'Search...',
  });

  final String title;
  final List<AppPickerItem<T>> items;
  final T? selectedValue;
  final bool isSearchable;
  final String searchHint;

  @override
  State<_BottomSheetContent<T>> createState() => _BottomSheetContentState<T>();
}

class _BottomSheetContentState<T> extends State<_BottomSheetContent<T>> {
  late List<AppPickerItem<T>> _filteredItems;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final lower = query.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) {
        return item.label.toLowerCase().contains(lower) ||
            (item.subtitle?.toLowerCase().contains(lower) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height *
            AppMobileTokens.sheetMaxHeightRatio,
      ),
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppMobileTokens.radiusSheet),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(
                  top: AppMobileTokens.spacingMD,
                  bottom: AppMobileTokens.spacingSM,
                ),
                width: AppMobileTokens.dragHandleWidth,
                height: AppMobileTokens.dragHandleHeight,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(AppMobileTokens.radiusPill),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppMobileTokens.pageMargin,
                AppMobileTokens.spacingXS,
                AppMobileTokens.spacingXS,
                AppMobileTokens.spacingSM,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.inter(
                        fontSize: AppMobileTokens.fontTitle,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Search field if searchable
            if (widget.isSearchable)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppMobileTokens.pageMargin,
                  vertical: AppMobileTokens.spacingXS,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  style: GoogleFonts.inter(
                    fontSize: AppMobileTokens.fontBody,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightBackground,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppMobileTokens.radiusMD),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppMobileTokens.radiusMD),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                  ),
                ),
              ),
            const Divider(height: 1),
            // List of items
            Flexible(
              child: _filteredItems.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(AppMobileTokens.spacingXL),
                      child: Center(
                        child: Text(
                          'No matching options found',
                          style: GoogleFonts.inter(
                            fontSize: AppMobileTokens.fontBody,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: _filteredItems.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        indent: AppMobileTokens.pageMargin,
                        endIndent: AppMobileTokens.pageMargin,
                        color: isDark
                            ? AppColors.darkBorder.withValues(alpha: 0.5)
                            : AppColors.lightBorder.withValues(alpha: 0.5),
                      ),
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isSelected = item.value == widget.selectedValue;

                        return InkWell(
                          onTap: () => Navigator.of(context).pop(item.value),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppMobileTokens.pageMargin,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                if (item.icon != null) ...[
                                  Icon(
                                    item.icon,
                                    size: AppMobileTokens.iconMD,
                                    color: isSelected
                                        ? AppColors.brandAmber
                                        : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary),
                                  ),
                                  const SizedBox(
                                    width: AppMobileTokens.spacingMD,
                                  ),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        item.label,
                                        style: GoogleFonts.inter(
                                          fontSize: AppMobileTokens.fontBody,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? AppColors.brandAmber
                                              : (isDark
                                                  ? AppColors.darkTextPrimary
                                                  : AppColors.lightTextPrimary),
                                        ),
                                      ),
                                      if (item.subtitle != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          item.subtitle!,
                                          style: GoogleFonts.inter(
                                            fontSize:
                                                AppMobileTokens.fontCaption,
                                            color: isDark
                                                ? AppColors.darkTextTertiary
                                                : AppColors.lightTextTertiary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (item.badge != null) ...[
                                  item.badge!,
                                  const SizedBox(
                                    width: AppMobileTokens.spacingSM,
                                  ),
                                ],
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    size: AppMobileTokens.iconMD,
                                    color: AppColors.brandAmber,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
