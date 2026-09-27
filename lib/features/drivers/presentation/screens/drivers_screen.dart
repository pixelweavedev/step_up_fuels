import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/utils/date_utils.dart';
import 'package:step_up_fuels/features/drivers/domain/entities/driver.dart';
import 'package:step_up_fuels/features/drivers/domain/entities/driver_assignment.dart';
import 'package:step_up_fuels/features/drivers/presentation/providers/drivers_provider.dart';
import 'package:step_up_fuels/features/vehicles/domain/entities/vehicle.dart';
import 'package:step_up_fuels/features/vehicles/presentation/providers/vehicles_provider.dart';
import 'package:step_up_fuels/shared/providers/theme_provider.dart';
import 'package:step_up_fuels/shared/widgets/buttons/primary_button.dart';
import 'package:step_up_fuels/shared/widgets/cards/mobile_card.dart';
import 'package:step_up_fuels/shared/widgets/empty_states/app_error_widget.dart';
import 'package:step_up_fuels/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:step_up_fuels/shared/widgets/inputs/app_text_field.dart';
import 'package:step_up_fuels/shared/widgets/layout/app_mobile_header.dart';
import 'package:uuid/uuid.dart';

class DriversScreen extends ConsumerWidget {
  const DriversScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final driversAsync = ref.watch(driversListProvider);
    final isMobile = context.isMobile;

    if (isMobile) {
      return _buildMobileDrivers(context, ref, driversAsync);
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Builder(
              builder: (context) {
                final isMobileOrSmall = context.isMobileOrSmallTablet;

                final headerText = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Drivers Directory',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage delivery drivers, licenses validity, and vehicle assignments.',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );

                final actionButton = PrimaryButton(
                  label: 'Add Driver',
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => const DriverFormDialog(),
                    );
                  },
                );

                return isMobileOrSmall
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          headerText,
                          const SizedBox(height: 16),
                          SizedBox(width: double.infinity, child: actionButton),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: headerText),
                          const SizedBox(width: 16),
                          actionButton,
                        ],
                      );
              },
            ),
            const SizedBox(height: 24),

            // Search Bar & Stats
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    hint: 'Search driver name, phone, license...',
                    prefixIcon: Icons.search_rounded,
                    onChanged: (val) {
                      ref.read(driverSearchQueryProvider.notifier).state = val;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Drivers Grid List
            Expanded(
              child: driversAsync.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const Center(
                      child: EmptyStateWidget(
                        icon: Icons.badge_outlined,
                        title: 'No Drivers Found',
                        subtitle:
                            'Register a driver profile to manage assignments.',
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 380,
                          mainAxisExtent: 220,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final driver = list[index];
                      return _DriverGridCard(driver: driver);
                    },
                  );
                },
                error: (err, st) => const AppErrorWidget(
                  isCompact: true,
                  message: 'Unable to load drivers list.',
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.brandAmber),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDrivers(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Driver>> driversAsync,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Sticky Mobile Header (Search + KPI Bar)
            driversAsync.maybeWhen(
              data: (list) {
                final totalDrivers = list.length;
                final activeDrivers = list
                    .where((d) => d.status == DriverStatus.active)
                    .length;
                final now = DateTime.now();
                final expiringSoonCount = list.where((d) {
                  return d.licenseExpiry.isBefore(
                        now.add(const Duration(days: 30)),
                      ) &&
                      d.licenseExpiry.isAfter(now);
                }).length;
                final expiredCount = list
                    .where((d) => d.licenseExpiry.isBefore(now))
                    .length;

                return AppMobileHeader(
                  searchWidget: AppTextField(
                    hint: 'Search driver name, phone, license...',
                    prefixIcon: Icons.search_rounded,
                    showClearButton: true,
                    onChanged: (val) {
                      ref.read(driverSearchQueryProvider.notifier).state = val;
                    },
                    onClear: () {
                      ref.read(driverSearchQueryProvider.notifier).state = '';
                    },
                  ),
                  kpis: [
                    AppKpiItem(
                      label: 'ACTIVE DRIVERS',
                      value: '$activeDrivers / $totalDrivers Available',
                      valueColor: AppColors.success,
                    ),
                    AppKpiItem(
                      label: 'LICENSE ALERTS',
                      value: expiredCount > 0
                          ? '$expiredCount Expired!'
                          : (expiringSoonCount > 0
                              ? '$expiringSoonCount Expiring'
                              : 'All Valid'),
                      labelColor: expiredCount > 0
                          ? AppColors.error
                          : (expiringSoonCount > 0
                              ? AppColors.warning
                              : AppColors.success),
                      valueColor: expiredCount > 0
                          ? AppColors.error
                          : (expiringSoonCount > 0
                              ? AppColors.warning
                              : AppColors.success),
                    ),
                  ],
                );
              },
              orElse: () => AppMobileHeader(
                searchWidget: AppTextField(
                  hint: 'Search driver name, phone, license...',
                  prefixIcon: Icons.search_rounded,
                  showClearButton: true,
                  onChanged: (val) {
                    ref.read(driverSearchQueryProvider.notifier).state = val;
                  },
                  onClear: () {
                    ref.read(driverSearchQueryProvider.notifier).state = '';
                  },
                ),
              ),
            ),

            // Driver List
            Expanded(
              child: driversAsync.when(
                data: (list) {
                  if (list.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.brandAmber,
                      onRefresh: () async => ref.refresh(driversListProvider),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 60),
                          Center(
                            child: EmptyStateWidget(
                              icon: Icons.badge_outlined,
                              title: 'No Drivers Found',
                              subtitle:
                                  'Adjust your search query or tap + to register.',
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.brandAmber,
                    onRefresh: () async => ref.refresh(driversListProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final driver = list[index];
                        final now = DateTime.now();
                        final isLicenseExpired = driver.licenseExpiry.isBefore(
                          now,
                        );
                        final isLicenseExpiringSoon =
                            driver.licenseExpiry.isBefore(
                              now.add(const Duration(days: 30)),
                            ) &&
                            !isLicenseExpired;

                        Color statusColor = AppColors.success;
                        if (driver.status == DriverStatus.suspended ||
                            isLicenseExpired) {
                          statusColor = AppColors.error;
                        } else if (driver.status == DriverStatus.inactive) {
                          statusColor = AppColors.darkTextTertiary;
                        }

                        return MobileCard(
                          title: driver.name,
                          subtitle: driver.phone.isNotEmpty
                              ? 'Contact: ${driver.phone}'
                              : 'No phone registered',
                          leadingIcon: Icons.person_rounded,
                          leadingColor: AppColors.brandAmber,
                          heroLabel: 'License Expiry',
                          heroMetric: AppDateUtils.toDisplay(
                            driver.licenseExpiry,
                          ),
                          heroColor: isLicenseExpired
                              ? AppColors.error
                              : (isLicenseExpiringSoon
                                  ? AppColors.warning
                                  : (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary)),
                          statusBadge: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isLicenseExpired
                                  ? 'License Expired'
                                  : driver.status.displayName,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                          attributes: [
                            MobileCardAttribute(
                              label: 'License No',
                              value: driver.licenseNumber,
                            ),
                          ],
                          onTap: () {
                            showModalBottomSheet<void>(
                              context: context,
                              backgroundColor: isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightSurface,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder: (sheetCtx) => SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        driver.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.lightTextPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'License: ${driver.licenseNumber} • Expiry: ${AppDateUtils.toDisplay(driver.licenseExpiry)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? AppColors.darkTextTertiary
                                              : AppColors.lightTextTertiary,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      ListTile(
                                        leading: const Icon(
                                          Icons.assignment_ind_rounded,
                                          color: AppColors.brandAmber,
                                        ),
                                        title: const Text('Manage Bowser Assignment'),
                                        onTap: () {
                                          Navigator.pop(sheetCtx);
                                          showDialog<void>(
                                            context: context,
                                            builder: (_) => DriverAssignmentDialog(
                                              driver: driver,
                                            ),
                                          );
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(
                                          Icons.edit_outlined,
                                          color: AppColors.brandAmber,
                                        ),
                                        title: const Text('Edit Driver Profile'),
                                        onTap: () {
                                          Navigator.pop(sheetCtx);
                                          showDialog<void>(
                                            context: context,
                                            builder: (_) => DriverFormDialog(
                                              driver: driver,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.brandAmber),
                ),
                error: (err, st) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: AppErrorWidget(
                    message: 'Failed to load drivers list.',
                    onRetry: () => ref.refresh(driversListProvider),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.brandAmber,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text(
          'New Driver',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              fullscreenDialog: true,
              builder: (_) => const DriverFormDialog(),
            ),
          );
        },
      ),
    );
  }
}

class _DriverGridCard extends ConsumerWidget {
  const _DriverGridCard({required this.driver});
  final Driver driver;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(driverAssignmentsProvider(driver.id));
    final vehiclesAsync = ref.watch(vehiclesListProvider);

    final isLicenseExpired = driver.licenseExpiry.isBefore(DateTime.now());
    final isLicenseExpiringSoon =
        driver.licenseExpiry.isBefore(
          DateTime.now().add(const Duration(days: 30)),
        ) &&
        !isLicenseExpired;

    final theme = Theme.of(context);
    final cardBg = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = isLicenseExpired
        ? AppColors.error.withValues(alpha: 0.5)
        : (isLicenseExpiringSoon
              ? AppColors.brandAmber.withValues(alpha: 0.5)
              : theme.colorScheme.outline);

    return Card(
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    driver.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: driver.status == DriverStatus.active
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    driver.status.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: driver.status == DriverStatus.active
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Contact
            Row(
              children: [
                Icon(
                  Icons.phone_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  driver.phone,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // License
            Row(
              children: [
                Icon(
                  Icons.badge_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lic: ${driver.licenseNumber}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // License Expiry alert
            Row(
              children: [
                Icon(
                  isLicenseExpired || isLicenseExpiringSoon
                      ? Icons.warning_amber_rounded
                      : Icons.calendar_today_rounded,
                  size: 14,
                  color: isLicenseExpired
                      ? AppColors.error
                      : (isLicenseExpiringSoon
                            ? AppColors.brandAmber
                            : theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: 8),
                Text(
                  'Expires: ${AppDateUtils.toDisplay(driver.licenseExpiry)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isLicenseExpired || isLicenseExpiringSoon
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isLicenseExpired
                        ? AppColors.error
                        : (isLicenseExpiringSoon
                              ? AppColors.brandAmber
                              : theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            if (context.isMobile)
              const SizedBox(height: 16)
            else
              const Spacer(),
            Divider(color: theme.colorScheme.outline, height: 1),
            const SizedBox(height: 12),

            // Assignment Actions
            assignmentsAsync.when(
              data: (assignments) {
                final activeAsg = assignments.firstWhere(
                  (a) => a.isActive,
                  orElse: () => DriverAssignment(
                    id: '',
                    driverId: '',
                    vehicleId: '',
                    assignedAt: DateTime.now(),
                    isActive: false,
                  ),
                );

                return vehiclesAsync.when(
                  data: (vehiclesList) {
                    final vehicle = vehiclesList.firstWhere(
                      (v) => v.id == activeAsg.vehicleId,
                      orElse: () => Vehicle(
                        id: '',
                        registrationNumber: 'Unassigned',
                        model: '',
                        capacity: 0,
                        status: VehicleStatus.inactive,
                        createdBy: '',
                        createdAt: DateTime.now(),
                        updatedBy: '',
                        updatedAt: DateTime.now(),
                        version: 1,
                      ),
                    );

                    final hasActive = activeAsg.isActive;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bowser: ${vehicle.registrationNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: hasActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: hasActive
                                ? AppColors.brandAmber
                                : AppColors.darkTextSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            showDialog<void>(
                              context: context,
                              builder: (context) => DriverAssignmentDialog(
                                driver: driver,
                                currentAssignment: hasActive ? activeAsg : null,
                              ),
                            );
                          },
                          child: Text(
                            hasActive ? 'Change' : 'Assign Bowser',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.brandAmber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  error: (_, __) => const SizedBox(),
                  loading: () => const SizedBox(),
                );
              },
              error: (_, __) => const SizedBox(),
              loading: () => const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

class DriverFormDialog extends ConsumerStatefulWidget {
  const DriverFormDialog({super.key, this.driver});
  final Driver? driver;

  @override
  ConsumerState<DriverFormDialog> createState() => _DriverFormDialogState();
}

class _DriverFormDialogState extends ConsumerState<DriverFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _licenseController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late DateTime _expiry;
  late DriverStatus _status;

  @override
  void initState() {
    super.initState();
    final d = widget.driver;
    _nameController = TextEditingController(text: d?.name ?? '');
    _licenseController = TextEditingController(text: d?.licenseNumber ?? '');
    _phoneController = TextEditingController(text: d?.phone ?? '');
    _emailController = TextEditingController(text: d?.email ?? '');
    _expiry = d?.licenseExpiry ?? DateTime.now().add(const Duration(days: 365));
    _status = d?.status ?? DriverStatus.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _licenseController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.driver != null;

    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 460,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Edit Driver Profile' : 'Register Driver',
                  style: TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _nameController,
                  label: 'Driver Name *',
                  hint: 'e.g. Ramesh Kumar',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _phoneController,
                  label: 'Contact Number *',
                  hint: 'e.g. 9876543210',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _emailController,
                  label: 'Email (optional)',
                  hint: 'e.g. ramesh@gmail.com',
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _licenseController,
                  label: 'Driving License Number *',
                  hint: 'e.g. DL-1420110012345',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'License Expiry Date',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppDateUtils.toDisplay(_expiry),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      icon: const Icon(
                        Icons.edit_calendar_rounded,
                        color: AppColors.brandAmber,
                      ),
                      label: const Text(
                        'Change Date',
                        style: TextStyle(color: AppColors.brandAmber),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _expiry,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 10),
                          ),
                        );
                        if (picked != null) {
                          setState(() => _expiry = picked);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<DriverStatus>(
                  initialValue: _status,
                  dropdownColor: AppColors.darkSurface,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: DriverStatus.values.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(s.displayName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _status = val);
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.darkTextSecondary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    PrimaryButton(
                      label: 'Save',
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        final driver = Driver(
                          id: widget.driver?.id ?? const Uuid().v4(),
                          name: _nameController.text.trim(),
                          licenseNumber: _licenseController.text
                              .trim()
                              .toUpperCase(),
                          licenseExpiry: _expiry,
                          phone: _phoneController.text.trim(),
                          email: _emailController.text.trim().isEmpty
                              ? null
                              : _emailController.text.trim(),
                          status: _status,
                          createdBy: widget.driver?.createdBy ?? 'system',
                          createdAt: widget.driver?.createdAt ?? DateTime.now(),
                          updatedBy: 'system',
                          updatedAt: DateTime.now(),
                          version: widget.driver?.version ?? 1,
                        );

                        await ref
                            .read(driversListProvider.notifier)
                            .saveDriver(driver);
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DriverAssignmentDialog extends ConsumerStatefulWidget {
  const DriverAssignmentDialog({
    super.key,
    required this.driver,
    this.currentAssignment,
  });
  final Driver driver;
  final DriverAssignment? currentAssignment;

  @override
  ConsumerState<DriverAssignmentDialog> createState() =>
      _DriverAssignmentDialogState();
}

class _DriverAssignmentDialogState
    extends ConsumerState<DriverAssignmentDialog> {
  String? _selectedVehicleId;

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesListProvider);

    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assign Bowser (${widget.driver.name})',
              style: TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            vehiclesAsync.when(
              data: (list) {
                final activeVehicles = list
                    .where(
                      (v) =>
                          v.status == VehicleStatus.active &&
                          v.deletedAt == null,
                    )
                    .toList();

                if (activeVehicles.isEmpty) {
                  return Text(
                    'No active vehicles available for assignment. Please register or active bowser vehicles first.',
                    style: TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 13,
                    ),
                  );
                }

                // Default selection
                if (_selectedVehicleId == null && activeVehicles.isNotEmpty) {
                  _selectedVehicleId = activeVehicles.first.id;
                }

                return DropdownButtonFormField<String>(
                  initialValue: _selectedVehicleId,
                  dropdownColor: AppColors.darkSurface,
                  decoration: const InputDecoration(
                    labelText: 'Select Bowser Vehicle',
                  ),
                  items: activeVehicles.map((v) {
                    return DropdownMenuItem(
                      value: v.id,
                      child: Text(v.registrationNumber),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedVehicleId = val);
                  },
                );
              },
              error: (err, st) => const Text(
                'Error loading vehicles',
                style: TextStyle(color: AppColors.error),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.brandAmber),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.darkTextSecondary),
                  ),
                ),
                const SizedBox(width: 12),
                PrimaryButton(
                  label: 'Assign',
                  onPressed: _selectedVehicleId == null
                      ? null
                      : () async {
                          final assignment = DriverAssignment(
                            id: const Uuid().v4(),
                            driverId: widget.driver.id,
                            vehicleId: _selectedVehicleId!,
                            assignedAt: DateTime.now(),
                            isActive: true,
                          );

                          await ref
                              .read(executeDriverAssignmentProvider.notifier)
                              .assignDriver(assignment);
                          if (context.mounted) Navigator.pop(context);
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
