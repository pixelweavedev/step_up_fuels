import 'dart:async';
import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/services/location/administrative_location_service.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/shared/widgets/inputs/app_text_field.dart';

/// A hybrid Dropdown + TextField widget for administrative location inputs.
///
/// Features:
/// - Direct typing with real-time autocompletion and filtering.
/// - Dropdown button icon to browse and select from all available choices.
/// - Allows free-form custom input (nothing is strictly restricted or mandatory).
/// - Clean clear button to easily reset.
class AdministrativeDropdownTextField extends StatefulWidget {
  const AdministrativeDropdownTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.items,
    this.prefixIcon,
    this.enabled = true,
    this.disabledHint,
    this.onSelected,
    this.onChanged,
    this.isMandatory = false,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final List<String> items;
  final IconData? prefixIcon;
  final bool enabled;
  final String? disabledHint;
  final ValueChanged<String>? onSelected;
  final ValueChanged<String>? onChanged;
  final bool isMandatory;

  @override
  State<AdministrativeDropdownTextField> createState() =>
      _AdministrativeDropdownTextFieldState();
}

class _AdministrativeDropdownTextFieldState
    extends State<AdministrativeDropdownTextField> {
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<String> _filteredItems = [];
  Timer? _hideTimer;
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant AdministrativeDropdownTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filterItems(widget.controller.text);
      if (_overlayEntry != null) {
        _overlayEntry?.markNeedsBuild();
      }
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _hideOverlay();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && widget.enabled) {
      _hideTimer?.cancel();
      _filterItems(widget.controller.text);
      _showOverlay();
    } else {
      // Delay closing to give time for any in-flight tap event on the overlay to complete!
      // On web/desktop, pointer-down causes the text field to blur before pointer-up triggers onTap.
      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(milliseconds: 250), () {
        if (mounted && !_focusNode.hasFocus) {
          _hideOverlay();
        }
      });
    }
  }

  void _onControllerChanged() {
    _filterItems(widget.controller.text);
    if (_focusNode.hasFocus && widget.enabled) {
      if (_overlayEntry == null) {
        _showOverlay();
      } else {
        _overlayEntry?.markNeedsBuild();
      }
    }
  }

  void _filterItems(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      _filteredItems = List.from(widget.items);
    } else {
      _filteredItems = widget.items
          .where((item) => item.toLowerCase().contains(q))
          .toList();
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null || !mounted || !widget.enabled) return;

    final overlay = Overlay.of(context);
    _overlayEntry = _createOverlayEntry();
    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _hideTimer?.cancel();
    _hideTimer = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectItem(String item) {
    if (_isSelecting) return;
    _isSelecting = true;
    _hideTimer?.cancel();

    widget.controller.text = item;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: item.length),
    );
    _hideOverlay();
    _focusNode.unfocus();
    widget.onSelected?.call(item);
    widget.onChanged?.call(item);

    Future.delayed(const Duration(milliseconds: 150), () {
      _isSelecting = false;
    });
  }

  void _openFullPickerModal() {
    if (!widget.enabled) return;
    _hideOverlay();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SearchablePickerSheet(
        title: widget.label,
        initialQuery: widget.controller.text,
        items: widget.items,
        onSelected: (item) {
          Navigator.of(ctx).pop();
          _selectItem(item);
        },
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? Size.zero;

    return OverlayEntry(
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0.0, size.height + 4.0),
            child: TapRegion(
              groupId: _layerLink,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(10),
                color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 240),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: _filteredItems.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Text(
                            widget.items.isEmpty
                                ? 'No options available'
                                : 'No matches found (you can type a custom name)',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextTertiary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          shrinkWrap: true,
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            final isSelected =
                                widget.controller.text.trim().toLowerCase() ==
                                item.toLowerCase();

                            return Material(
                              color: isSelected
                                  ? AppColors.brandAmber.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              child: InkWell(
                                onTap: () => _selectItem(item),
                                hoverColor: AppColors.brandAmber.withValues(
                                  alpha: 0.08,
                                ),
                                splashColor: AppColors.brandAmber.withValues(
                                  alpha: 0.2,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 11,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? AppColors.brandAmber
                                                : (isDark
                                                      ? AppColors
                                                            .darkTextPrimary
                                                      : AppColors
                                                            .lightTextPrimary),
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_rounded,
                                          size: 16,
                                          color: AppColors.brandAmber,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHint = !widget.enabled && widget.disabledHint != null
        ? widget.disabledHint!
        : widget.hint;

    final hasText = widget.controller.text.isNotEmpty;

    return CompositedTransformTarget(
      link: _layerLink,
      child: TapRegion(
        groupId: _layerLink,
        onTapOutside: (_) {
          _hideOverlay();
        },
        child: AppTextField(
          controller: widget.controller,
          focusNode: _focusNode,
          label: widget.label,
          hint: effectiveHint,
          enabled: widget.enabled,
          prefixIcon: widget.prefixIcon,
          onTap: () {
            if (widget.enabled) {
              _filterItems(widget.controller.text);
              if (_overlayEntry == null) {
                _showOverlay();
              } else {
                _overlayEntry?.markNeedsBuild();
              }
            }
          },
          onChanged: (val) {
            widget.onChanged?.call(val);
          },
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasText && widget.enabled)
                IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  tooltip: 'Clear',
                  onPressed: () {
                    widget.controller.clear();
                    widget.onSelected?.call('');
                    widget.onChanged?.call('');
                    setState(() {});
                  },
                ),
              IconButton(
                icon: Icon(
                  Icons.arrow_drop_down_circle_outlined,
                  size: 20,
                  color: widget.enabled
                      ? AppColors.brandAmber
                      : Theme.of(context).disabledColor,
                ),
                tooltip: 'Browse ${widget.label}',
                onPressed: widget.enabled ? _openFullPickerModal : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modal bottom sheet with search bar to browse long lists (e.g. 700+ districts or 6000+ talukas).
class _SearchablePickerSheet extends StatefulWidget {
  const _SearchablePickerSheet({
    required this.title,
    required this.items,
    required this.onSelected,
    this.initialQuery,
  });

  final String title;
  final List<String> items;
  final ValueChanged<String> onSelected;
  final String? initialQuery;

  @override
  State<_SearchablePickerSheet> createState() => _SearchablePickerSheetState();
}

class _SearchablePickerSheetState extends State<_SearchablePickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = widget.items;
      } else {
        _filtered = widget.items
            .where((i) => i.toLowerCase().contains(q))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7 + keyboardHeight,
      padding: EdgeInsets.only(bottom: keyboardHeight),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select ${widget.title}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  '${_filtered.length} available',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              onChanged: _onSearch,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search ${widget.title}...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark
                    ? AppColors.darkCard
                    : AppColors.lightBackground,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off_outlined,
                            size: 40,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No matching ${widget.title.toLowerCase()} found.',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          if (_searchCtrl.text.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            TextButton.icon(
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: Text('Use "${_searchCtrl.text}"'),
                              onPressed: () {
                                widget.onSelected(_searchCtrl.text.trim());
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, idx) {
                      final item = _filtered[idx];
                      return ListTile(
                        dense: true,
                        title: Text(
                          item,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                        ),
                        onTap: () => widget.onSelected(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// A coordinated group of inputs: State, District, and Taluka (Sub-district).
///
/// Automatically cascades selections:
/// - Selecting a State populates the District dropdown.
/// - Selecting a District populates the Taluka dropdown.
/// - Allows free text typing in any field without mandatory constraints.
class AdministrativeLocationGroup extends StatefulWidget {
  const AdministrativeLocationGroup({
    super.key,
    required this.stateController,
    required this.districtController,
    required this.talukaController,
    this.cityController,
    this.pincodeController,
    this.onStateChanged,
    this.onDistrictChanged,
    this.onTalukaChanged,
    this.isStacked = false,
  });

  final TextEditingController stateController;
  final TextEditingController districtController;
  final TextEditingController talukaController;
  final TextEditingController? cityController;
  final TextEditingController? pincodeController;
  final ValueChanged<String>? onStateChanged;
  final ValueChanged<String>? onDistrictChanged;
  final ValueChanged<String>? onTalukaChanged;
  final bool isStacked;

  @override
  State<AdministrativeLocationGroup> createState() =>
      _AdministrativeLocationGroupState();
}

class _AdministrativeLocationGroupState
    extends State<AdministrativeLocationGroup> {
  final _service = AdministrativeLocationService.instance;

  List<String> _states = [];
  List<String> _districts = [];
  List<String> _talukas = [];

  @override
  void initState() {
    super.initState();
    _loadLocationData();
    widget.stateController.addListener(_onStateControllerChanged);
    widget.districtController.addListener(_onDistrictControllerChanged);
  }

  @override
  void dispose() {
    widget.stateController.removeListener(_onStateControllerChanged);
    widget.districtController.removeListener(_onDistrictControllerChanged);
    super.dispose();
  }

  void _loadLocationData() {
    _states = _service.getStates();
    final currentState = widget.stateController.text.trim();
    if (currentState.isNotEmpty) {
      _districts = _service.getDistricts(currentState);
      final currentDistrict = widget.districtController.text.trim();
      if (currentDistrict.isNotEmpty) {
        _talukas = _service.getTalukas(currentState, currentDistrict);
      }
    }
    if (mounted) setState(() {});
  }

  void _onStateControllerChanged() {
    final stateText = widget.stateController.text.trim();
    final newDistricts = _service.getDistricts(stateText);

    if (newDistricts != _districts) {
      setState(() {
        _districts = newDistricts;
        // Check if current district belongs to new state
        final currentDistrict = widget.districtController.text.trim();
        if (currentDistrict.isNotEmpty &&
            !newDistricts.any(
              (d) => d.toLowerCase() == currentDistrict.toLowerCase(),
            )) {
          widget.districtController.clear();
          widget.talukaController.clear();
          _talukas = [];
        }
      });
    }
  }

  void _onDistrictControllerChanged() {
    final stateText = widget.stateController.text.trim();
    final districtText = widget.districtController.text.trim();
    final newTalukas = _service.getTalukas(stateText, districtText);

    if (newTalukas != _talukas) {
      setState(() {
        _talukas = newTalukas;
        final currentTaluka = widget.talukaController.text.trim();
        if (currentTaluka.isNotEmpty &&
            !newTalukas.any(
              (t) => t.toLowerCase() == currentTaluka.toLowerCase(),
            )) {
          widget.talukaController.clear();
        }
      });
    }
  }

  void _handleStateSelected(String state) {
    widget.stateController.text = state;
    setState(() {
      _districts = _service.getDistricts(state);
      widget.districtController.clear();
      widget.talukaController.clear();
      _talukas = [];
    });
    widget.onStateChanged?.call(state);
  }

  void _handleDistrictSelected(String district) {
    widget.districtController.text = district;
    final state = widget.stateController.text.trim();
    setState(() {
      _talukas = _service.getTalukas(state, district);
      widget.talukaController.clear();
    });
    widget.onDistrictChanged?.call(district);
  }

  void _handleTalukaSelected(String taluka) {
    widget.talukaController.text = taluka;
    widget.onTalukaChanged?.call(taluka);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = widget.isStacked || MediaQuery.sizeOf(context).width < 600;

    final stateField = AdministrativeDropdownTextField(
      controller: widget.stateController,
      label: 'State',
      hint: 'Select or type state',
      items: _states,
      prefixIcon: Icons.map_outlined,
      onSelected: _handleStateSelected,
      onChanged: (val) {
        _onStateControllerChanged();
        widget.onStateChanged?.call(val);
      },
    );

    final districtField = AdministrativeDropdownTextField(
      controller: widget.districtController,
      label: 'District',
      hint: widget.stateController.text.isEmpty
          ? 'Select state first'
          : 'Select or type district',
      disabledHint: 'Select state first',
      enabled: widget.stateController.text.isNotEmpty || _districts.isNotEmpty,
      items: _districts,
      prefixIcon: Icons.location_city_outlined,
      onSelected: _handleDistrictSelected,
      onChanged: (val) {
        _onDistrictControllerChanged();
        widget.onDistrictChanged?.call(val);
      },
    );

    final talukaField = AdministrativeDropdownTextField(
      controller: widget.talukaController,
      label: 'Taluka / Tehsil',
      hint: widget.districtController.text.isEmpty
          ? 'Select district first'
          : 'Select or type taluka',
      disabledHint: 'Select district first',
      enabled: widget.districtController.text.isNotEmpty || _talukas.isNotEmpty,
      items: _talukas,
      prefixIcon: Icons.holiday_village_outlined,
      onSelected: _handleTalukaSelected,
      onChanged: (val) {
        widget.onTalukaChanged?.call(val);
      },
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          stateField,
          const SizedBox(height: 16),
          districtField,
          const SizedBox(height: 16),
          talukaField,
          if (widget.cityController != null ||
              widget.pincodeController != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (widget.cityController != null)
                  Expanded(
                    child: AppTextField(
                      controller: widget.cityController,
                      label: 'City / Town / Village',
                      hint: 'e.g. Shirur / Khed',
                      prefixIcon: Icons.home_work_outlined,
                    ),
                  ),
                if (widget.cityController != null &&
                    widget.pincodeController != null)
                  const SizedBox(width: 16),
                if (widget.pincodeController != null)
                  Expanded(
                    child: AppTextField(
                      controller: widget.pincodeController,
                      label: 'PIN Code',
                      hint: '6-digit code',
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                    ),
                  ),
              ],
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: stateField),
            const SizedBox(width: 16),
            Expanded(child: districtField),
            const SizedBox(width: 16),
            Expanded(child: talukaField),
          ],
        ),
        if (widget.cityController != null ||
            widget.pincodeController != null) ...[
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.cityController != null)
                Expanded(
                  flex: 2,
                  child: AppTextField(
                    controller: widget.cityController,
                    label: 'City / Town / Village',
                    hint: 'e.g. Akurdi / Chakan',
                    prefixIcon: Icons.home_work_outlined,
                  ),
                ),
              if (widget.cityController != null &&
                  widget.pincodeController != null)
                const SizedBox(width: 16),
              if (widget.pincodeController != null)
                Expanded(
                  child: AppTextField(
                    controller: widget.pincodeController,
                    label: 'PIN Code',
                    hint: '6-digit PIN',
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
