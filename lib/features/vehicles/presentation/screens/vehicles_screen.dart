import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/utils/date_utils.dart';
import 'package:step_up_fuels/features/drivers/domain/entities/driver_assignment.dart';
import 'package:step_up_fuels/features/drivers/presentation/providers/drivers_provider.dart';
import 'package:step_up_fuels/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:step_up_fuels/features/products/presentation/providers/products_provider.dart';
import 'package:step_up_fuels/features/vehicles/domain/entities/vehicle.dart';
import 'package:step_up_fuels/features/vehicles/domain/entities/vehicle_service_record.dart';
import 'package:step_up_fuels/features/vehicles/presentation/providers/vehicles_provider.dart';
import 'package:step_up_fuels/shared/providers/theme_provider.dart';
import 'package:step_up_fuels/shared/widgets/buttons/primary_button.dart';
import 'package:step_up_fuels/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:step_up_fuels/shared/widgets/inputs/app_text_field.dart';
import 'package:uuid/uuid.dart';

class VehiclesScreen extends ConsumerWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Row(
        children: [
          // Left: Vehicle list sidebar
          Container(
            width: 380,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: AppColors.darkBorder)),
            ),
            child: const _VehicleMasterList(),
          ),
          // Right: Detail view
          const Expanded(child: _VehicleDetailView()),
        ],
      ),
    );
  }
}

class _VehicleMasterList extends ConsumerWidget {
  const _VehicleMasterList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesListProvider);
    final selectedId = ref.watch(selectedVehicleIdProvider);
    final statusFilter = ref.watch(vehicleStatusFilterProvider);

    return Column(
      children: [
        // Header & Search
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bowsers / Fleet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.brandAmber,
                    ),
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (context) => const VehicleFormDialog(),
                      );
                    },
                    tooltip: 'Register Bowser',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(
                hint: 'Search reg no or model...',
                prefixIcon: Icons.search_rounded,
                onChanged: (val) {
                  ref.read(vehicleSearchQueryProvider.notifier).state = val;
                },
              ),
            ],
          ),
        ),

        // Filters Panel
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Show Inactive/Deleted:',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.darkTextSecondary,
                ),
              ),
              Switch(
                value: statusFilter == null || statusFilter == false,
                activeThumbColor: AppColors.brandAmber,
                onChanged: (val) {
                  ref.read(vehicleStatusFilterProvider.notifier).state = val
                      ? null
                      : true;
                },
              ),
            ],
          ),
        ),
        Divider(color: AppColors.darkBorder),

        // Vehicles cards list
        Expanded(
          child: vehiclesAsync.when(
            data: (list) {
              if (list.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: EmptyStateWidget(
                      icon: Icons.local_shipping_outlined,
                      title: 'No Bowsers Registered',
                      subtitle: 'Add a new mobile fuel delivery vehicle.',
                    ),
                  ),
                );
              }

              // Auto-select first vehicle if none is selected
              if (selectedId == null && list.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(selectedVehicleIdProvider.notifier).state =
                      list.first.id;
                });
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final vehicle = list[index];
                  final isSelected = vehicle.id == selectedId;
                  final isDeleted = vehicle.deletedAt != null;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () {
                        ref.read(selectedVehicleIdProvider.notifier).state =
                            vehicle.id;
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.darkSurface
                              : AppColors.darkCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.brandAmber
                                : (isDeleted
                                      ? AppColors.error.withValues(alpha: 0.3)
                                      : AppColors.darkBorder),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  vehicle.registrationNumber,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkTextPrimary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        vehicle.status == VehicleStatus.active
                                        ? AppColors.success.withValues(
                                            alpha: 0.15,
                                          )
                                        : AppColors.error.withValues(
                                            alpha: 0.15,
                                          ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    vehicle.status.displayName,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          vehicle.status == VehicleStatus.active
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              vehicle.model,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.darkTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Capacity: ${vehicle.capacity} LTRS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.darkTextTertiary,
                                  ),
                                ),
                                Consumer(
                                  builder: (context, ref, child) {
                                    final assignmentsAsync = ref.watch(
                                      vehicleAssignmentsProvider(vehicle.id),
                                    );
                                    return assignmentsAsync.when(
                                      data: (assignments) {
                                        final activeAssignment = assignments
                                            .firstWhere(
                                              (a) => a.isActive,
                                              orElse: () => DriverAssignment(
                                                id: '',
                                                driverId: '',
                                                vehicleId: '',
                                                assignedAt: DateTime.now(),
                                                isActive: false,
                                              ),
                                            );

                                        if (!activeAssignment.isActive) {
                                          return Text(
                                            'Unassigned',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.darkTextTertiary,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          );
                                        }

                                        final driverAsync = ref.watch(
                                          driverByIdProvider(
                                            activeAssignment.driverId,
                                          ),
                                        );
                                        return driverAsync.when(
                                          data: (driver) => Text(
                                            driver.name,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.brandAmber,
                                            ),
                                          ),
                                          error: (_, __) => const SizedBox(),
                                          loading: () => const SizedBox(),
                                        );
                                      },
                                      error: (_, __) => const SizedBox(),
                                      loading: () => const SizedBox(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            error: (err, st) => Center(child: Text('Error: $err')),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.brandAmber),
            ),
          ),
        ),
      ],
    );
  }
}

class _VehicleDetailView extends ConsumerWidget {
  const _VehicleDetailView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedVehicleIdProvider);
    if (selectedId == null) {
      return const Center(
        child: EmptyStateWidget(
          icon: Icons.local_shipping_outlined,
          title: 'Select a Bowser',
          subtitle:
              'Choose a delivery vehicle from the list to view live stock and maintenance logs.',
        ),
      );
    }

    final vehicleAsync = ref.watch(selectedVehicleProvider);

    return vehicleAsync.when(
      data: (vehicle) => _VehicleDetailCard(vehicle: vehicle),
      error: (err, st) => Center(child: Text('Error: $err')),
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.brandAmber),
      ),
    );
  }
}

class _VehicleDetailCard extends ConsumerStatefulWidget {
  const _VehicleDetailCard({required this.vehicle});
  final Vehicle vehicle;

  @override
  ConsumerState<_VehicleDetailCard> createState() => _VehicleDetailCardState();
}

class _VehicleDetailCardState extends ConsumerState<_VehicleDetailCard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.vehicle;
    final productsAsync = ref.watch(productsListProvider);
    final assignmentsAsync = ref.watch(vehicleAssignmentsProvider(vehicle.id));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.brandAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: AppColors.brandAmber,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.registrationNumber,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Model: ${vehicle.model} • Capacity: ${vehicle.capacity} L',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (vehicle.deletedAt == null) ...[
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: AppColors.darkTextPrimary,
                  ),
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => VehicleFormDialog(vehicle: vehicle),
                    );
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: AppColors.darkBorder),
          const SizedBox(height: 16),

          // Info Widgets (Live stock & Active Driver)
          Row(
            children: [
              // Live stock widget
              Expanded(
                child: productsAsync.when(
                  data: (prods) {
                    if (prods.isEmpty) return const SizedBox();
                    final firstProd = prods.first;
                    final stockAsync = ref.watch(
                      stockBalanceProvider((
                        locationId: vehicle.id,
                        productId: firstProd.id,
                      )),
                    );
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.gas_meter_outlined,
                            color: AppColors.brandAmber,
                            size: 30,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LIVE BOWSER FUEL STOCK',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.darkTextTertiary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              stockAsync.when(
                                data: (stock) => Text(
                                  '${stock.toStringAsFixed(2)} LTRS',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.brandAmber,
                                  ),
                                ),
                                error: (_, __) => const Text(
                                  'N/A',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.error,
                                  ),
                                ),
                                loading: () => const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  error: (_, __) => const SizedBox(),
                  loading: () => const SizedBox(),
                ),
              ),
              const SizedBox(width: 16),

              // Active driver widget
              Expanded(
                child: assignmentsAsync.when(
                  data: (assignments) {
                    final activeAssignment = assignments.firstWhere(
                      (a) => a.isActive,
                      orElse: () => DriverAssignment(
                        id: '',
                        driverId: '',
                        vehicleId: '',
                        assignedAt: DateTime.now(),
                        isActive: false,
                      ),
                    );

                    if (!activeAssignment.isActive) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.badge_outlined,
                              color: AppColors.darkTextTertiary,
                              size: 30,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CURRENT ASSIGNED DRIVER',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.darkTextTertiary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Not Assigned',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }

                    final driverAsync = ref.watch(
                      driverByIdProvider(activeAssignment.driverId),
                    );

                    return driverAsync.when(
                      data: (driver) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.darkCard,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.darkBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.badge_outlined,
                                color: AppColors.brandAmber,
                                size: 30,
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CURRENT ASSIGNED DRIVER',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.darkTextTertiary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    driver.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkTextPrimary,
                                    ),
                                  ),
                                  if (driver.phone.isNotEmpty)
                                    Text(
                                      'Mob: ${driver.phone}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.darkTextSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      error: (_, __) => const SizedBox(),
                      loading: () => const SizedBox(
                        height: 60,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.brandAmber,
                          ),
                        ),
                      ),
                    );
                  },
                  error: (_, __) => const SizedBox(),
                  loading: () => const SizedBox(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tabs headers
          TabBar(
            controller: _tabController,
            dividerColor: AppColors.darkBorder,
            indicatorColor: AppColors.brandAmber,
            labelColor: AppColors.brandAmber,
            unselectedLabelColor: AppColors.darkTextSecondary,
            tabs: const [
              Tab(text: 'Service & Expenses'),
              Tab(text: 'Assignment History'),
            ],
          ),
          const SizedBox(height: 16),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ServiceRecordsTab(vehicleId: vehicle.id),
                _AssignmentsHistoryTab(vehicleId: vehicle.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceRecordsTab extends ConsumerWidget {
  const _ServiceRecordsTab({required this.vehicleId});
  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(vehicleServiceRecordsProvider(vehicleId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Maintenance & Expense History',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.darkTextPrimary,
              ),
            ),
            PrimaryButton(
              label: 'Add Record',
              icon: Icons.add,
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (context) =>
                      ServiceRecordFormDialog(vehicleId: vehicleId),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: recordsAsync.when(
            data: (list) {
              if (list.isEmpty) {
                return Center(
                  child: Text(
                    'No maintenance logs recorded.',
                    style: TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 13,
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final rec = list[index];
                  return Card(
                    color: AppColors.darkCard,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: AppColors.darkBorder),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.brandAmber.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.build_outlined,
                          color: AppColors.brandAmber,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        '${rec.serviceType.displayName} • ₹${rec.cost.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkTextPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Center: ${rec.serviceCenter}\nDetails: ${rec.details}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.darkTextSecondary,
                          height: 1.3,
                        ),
                      ),
                      isThreeLine: true,
                      trailing: Text(
                        AppDateUtils.toDisplay(rec.serviceDate),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.darkTextTertiary,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            error: (err, st) => Center(child: Text('Error: $err')),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.brandAmber),
            ),
          ),
        ),
      ],
    );
  }
}

class _AssignmentsHistoryTab extends ConsumerWidget {
  const _AssignmentsHistoryTab({required this.vehicleId});
  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(vehicleAssignmentsProvider(vehicleId));

    return assignmentsAsync.when(
      data: (assignments) {
        if (assignments.isEmpty) {
          return Center(
            child: Text(
              'No drivers have been assigned to this vehicle yet.',
              style: TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 13,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: assignments.length,
          itemBuilder: (context, index) {
            final asg = assignments[index];
            final driverAsync = ref.watch(driverByIdProvider(asg.driverId));

            return driverAsync.when(
              data: (driver) {
                return Card(
                  color: AppColors.darkCard,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: AppColors.darkBorder),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            (asg.isActive
                                    ? AppColors.success
                                    : AppColors.darkTextTertiary)
                                .withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        asg.isActive
                            ? Icons.check_circle_outline_rounded
                            : Icons.history_rounded,
                        color: asg.isActive
                            ? AppColors.success
                            : AppColors.darkTextTertiary,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      driver.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Assigned: ${AppDateUtils.toDisplay(asg.assignedAt)}\n${asg.releasedAt != null ? 'Released: ${AppDateUtils.toDisplay(asg.releasedAt!)}' : 'Currently Active'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.darkTextSecondary,
                        height: 1.3,
                      ),
                    ),
                    isThreeLine: asg.releasedAt != null,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (asg.isActive
                                    ? AppColors.success
                                    : AppColors.darkTextTertiary)
                                .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        asg.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: asg.isActive
                              ? AppColors.success
                              : AppColors.darkTextSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
              error: (err, _) => Card(
                color: AppColors.darkCard,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(
                    'Error loading driver: $err',
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: CircularProgressIndicator(),
              ),
            );
          },
        );
      },
      error: (err, st) => Center(child: Text('Error: $err')),
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.brandAmber),
      ),
    );
  }
}

class VehicleFormDialog extends ConsumerStatefulWidget {
  const VehicleFormDialog({super.key, this.vehicle});
  final Vehicle? vehicle;

  @override
  ConsumerState<VehicleFormDialog> createState() => _VehicleFormDialogState();
}

class _VehicleFormDialogState extends ConsumerState<VehicleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _regController;
  late TextEditingController _modelController;
  late TextEditingController _capacityController;
  late TextEditingController _notesController;
  late VehicleStatus _status;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _regController = TextEditingController(text: v?.registrationNumber ?? '');
    _modelController = TextEditingController(text: v?.model ?? '');
    _capacityController = TextEditingController(
      text: v?.capacity.toString() ?? '',
    );
    _notesController = TextEditingController(text: v?.notes ?? '');
    _status = v?.status ?? VehicleStatus.active;
  }

  @override
  void dispose() {
    _regController.dispose();
    _modelController.dispose();
    _capacityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.vehicle != null;

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
                  isEdit ? 'Edit Vehicle Info' : 'Register Vehicle',
                  style: TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _regController,
                  label: 'Registration Number *',
                  hint: 'e.g. MH-12-Q-4532',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _modelController,
                  label: 'Model / Specification *',
                  hint: 'e.g. Tata LPT 1613 Bowser',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _capacityController,
                  label: 'Capacity (Litres) *',
                  hint: 'e.g. 6000',
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (double.tryParse(v) == null) {
                      return 'Must be a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<VehicleStatus>(
                  initialValue: _status,
                  dropdownColor: AppColors.darkSurface,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: VehicleStatus.values.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(s.displayName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _status = val);
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _notesController,
                  label: 'Remarks',
                  hint: 'Optional notes',
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
                        final capacity = double.parse(
                          _capacityController.text.trim(),
                        );

                        final vehicle = Vehicle(
                          id: widget.vehicle?.id ?? const Uuid().v4(),
                          registrationNumber: _regController.text
                              .trim()
                              .toUpperCase(),
                          model: _modelController.text.trim(),
                          capacity: capacity,
                          status: _status,
                          notes: _notesController.text.trim().isEmpty
                              ? null
                              : _notesController.text.trim(),
                          createdBy: widget.vehicle?.createdBy ?? 'system',
                          createdAt:
                              widget.vehicle?.createdAt ?? DateTime.now(),
                          updatedBy: 'system',
                          updatedAt: DateTime.now(),
                          version: widget.vehicle?.version ?? 1,
                        );

                        await ref
                            .read(vehiclesListProvider.notifier)
                            .saveVehicle(vehicle);
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

class ServiceRecordFormDialog extends ConsumerStatefulWidget {
  const ServiceRecordFormDialog({super.key, required this.vehicleId});
  final String vehicleId;

  @override
  ConsumerState<ServiceRecordFormDialog> createState() =>
      _ServiceRecordFormDialogState();
}

class _ServiceRecordFormDialogState
    extends ConsumerState<ServiceRecordFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _costController;
  late TextEditingController _centerController;
  late TextEditingController _detailsController;
  late VehicleServiceType _type;

  @override
  void initState() {
    super.initState();
    _costController = TextEditingController();
    _centerController = TextEditingController();
    _detailsController = TextEditingController();
    _type = VehicleServiceType.routine;
  }

  @override
  void dispose() {
    _costController.dispose();
    _centerController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  'Record Vehicle Maintenance',
                  style: TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<VehicleServiceType>(
                  initialValue: _type,
                  dropdownColor: AppColors.darkSurface,
                  decoration: const InputDecoration(labelText: 'Service Type'),
                  items: VehicleServiceType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(t.displayName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _type = val);
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _costController,
                  label: 'Cost (INR) *',
                  hint: 'e.g. 4500',
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (double.tryParse(v) == null) {
                      return 'Must be a valid decimal';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _centerController,
                  label: 'Service Center / Provider *',
                  hint: 'e.g. Tata Motors Authorized Center',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _detailsController,
                  label: 'Work Details / Explanation *',
                  hint: 'e.g. Engine oil change, air filter replacement',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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
                        final cost = double.parse(_costController.text.trim());

                        final record = VehicleServiceRecord(
                          id: const Uuid().v4(),
                          vehicleId: widget.vehicleId,
                          serviceDate: DateTime.now(),
                          serviceType: _type,
                          cost: cost,
                          details: _detailsController.text.trim(),
                          serviceCenter: _centerController.text.trim(),
                          createdBy: 'system',
                          createdAt: DateTime.now(),
                          updatedBy: 'system',
                          updatedAt: DateTime.now(),
                          version: 1,
                        );

                        await ref
                            .read(saveServiceRecordProvider.notifier)
                            .saveRecord(record);
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
