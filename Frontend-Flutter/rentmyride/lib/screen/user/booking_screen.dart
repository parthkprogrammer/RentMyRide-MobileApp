import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rentmyride/model/booking_draft_model.dart';
import 'package:rentmyride/model/booking_model.dart';
import 'package:rentmyride/service/booking_service.dart';
import 'package:rentmyride/service/user_service.dart';
import 'package:rentmyride/service/vehicle_service.dart';
import 'package:rentmyride/theme.dart';

part '../../widget/user/booking_widgets.dart';

class BookingScreen extends StatefulWidget {
  final String vehicleId;

  const BookingScreen({super.key, required this.vehicleId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String _selectedInsurance = 'Premium Protection';
  DateTimeRange? _selectedRange;
  String? _pickupLocation;
  String? _dropLocation;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedRange = DateTimeRange(
      start: now.add(const Duration(days: 1)),
      end: now.add(const Duration(days: 4)),
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedRange,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingService = context.watch<BookingService>();
    final sessionUser = context.watch<UserService>().currentUser;
    final vehicleService = context.watch<VehicleService>();
    final vehicle = vehicleService.getVehicleById(widget.vehicleId);
    if (vehicle == null) {
      return const Scaffold(body: Center(child: Text('Vehicle not found')));
    }

    final locations = vehicleService.vehicles
        .map((entry) => entry.location)
        .toSet()
        .toList()
      ..sort();
    _pickupLocation ??= vehicle.location;
    _dropLocation ??= vehicle.location;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final successColor =
        isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
    final isCompactPhone = context.isCompactPhone;
    final horizontalPadding = isCompactPhone ? AppSpacing.md : AppSpacing.lg;
    final sectionPadding = EdgeInsets.all(horizontalPadding);
    final bottomInset = MediaQuery.of(context).padding.bottom + 132;

    final range = _selectedRange!;
    final rentalDays = (range.end.difference(range.start).inDays).clamp(1, 365);
    final rentalFee = vehicle.pricePerDay * rentalDays;
    final insuranceFee =
        _selectedInsurance == 'Premium Protection' ? 75.0 : 25.0;
    final serviceFee = 25.40;
    final taxes = (rentalFee + insuranceFee) * 0.05;
    final total = rentalFee + insuranceFee + serviceFee + taxes;
    final dateLabel =
        '${DateFormat('dd MMM yyyy').format(range.start)} - ${DateFormat('dd MMM yyyy').format(range.end)}';
    final activeOrConfirmedBookings = sessionUser == null
        ? const <BookingModel>[]
        : bookingService
            .getBookingsByUser(sessionUser.id)
            .where(
              (booking) =>
                  booking.status == BookingStatus.confirmed ||
                  booking.status == BookingStatus.active,
            )
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    Future<void> onProceedToPayment() async {
      final currentUser = sessionUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login again to continue')),
        );
        return;
      }
      if (_pickupLocation == null || _dropLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select pickup and drop locations')),
        );
        return;
      }

      final shouldContinue = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (sheetContext) => SafeArea(
              child: Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Proceed to Payment',
                      style: sheetContext.textStyles.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '$rentalDays day${rentalDays > 1 ? 's' : ''} - ${vehicle.name}',
                      style: sheetContext.textStyles.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Pickup: $_pickupLocation',
                      style: sheetContext.textStyles.bodySmall,
                    ),
                    Text(
                      'Drop: $_dropLocation',
                      style: sheetContext.textStyles.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: AppSpacing.paddingMd,
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkDivider
                              : AppColors.lightDivider,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: sheetContext.textStyles.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: sheetContext.textStyles.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(sheetContext, true),
                      child: const Text('Confirm and Continue'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext, false),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
          ) ??
          false;

      if (!shouldContinue) return;

      final now = DateTime.now();
      await bookingService.upsertDraft(
        BookingDraftModel(
          id: 'draft-${now.microsecondsSinceEpoch}',
          userId: currentUser.id,
          vehicleId: vehicle.id,
          ownerId: vehicle.ownerId,
          pickupDate: range.start,
          returnDate: range.end,
          pickupLocation: _pickupLocation!,
          dropLocation: _dropLocation!,
          insurancePlan: _selectedInsurance,
          rentalFee: rentalFee,
          insuranceFee: insuranceFee,
          serviceFee: serviceFee,
          taxes: taxes,
          totalAmount: total,
          createdAt: now,
          updatedAt: now,
        ),
      );
      if (!mounted) return;
      this.context.push('/payment/${widget.vehicleId}');
    }

    return Scaffold(
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          AppSpacing.md,
          horizontalPadding,
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: isCompactPhone
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: context.textStyles.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          'Total for $rentalDays day${rentalDays > 1 ? 's' : ''}',
                          style: context.textStyles.labelSmall?.copyWith(
                            color: isDark
                                ? AppColors.darkSecondaryText
                                : AppColors.lightSecondaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ElevatedButton.icon(
                      onPressed: onProceedToPayment,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Proceed to Payment'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                      ),
                      iconAlignment: IconAlignment.end,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: context.textStyles.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          'Total for $rentalDays day${rentalDays > 1 ? 's' : ''}',
                          style: context.textStyles.labelSmall?.copyWith(
                            color: isDark
                                ? AppColors.darkSecondaryText
                                : AppColors.lightSecondaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onProceedToPayment,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Proceed to Payment'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                        ),
                        iconAlignment: IconAlignment.end,
                      ),
                    ),
                  ],
                ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? AppColors.darkDivider
                          : AppColors.lightDivider,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, size: 24),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/vehicle/${widget.vehicleId}');
                            }
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Review Booking',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textStyles.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.info_outlined),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: const [
                        Expanded(
                            child: ProgressStep(
                                label: 'Duration', isActive: true)),
                        Expanded(
                            child: ProgressStep(
                                label: 'Insurance', isActive: true)),
                        Expanded(
                            child: ProgressStep(
                                label: 'Payment', isActive: false)),
                        Expanded(
                            child: ProgressStep(
                                label: 'Confirm', isActive: false)),
                      ],
                    ),
                  ],
                ),
              ),
              if (activeOrConfirmedBookings.isNotEmpty)
                Padding(
                  padding: sectionPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Bookings (Confirmed & Active)',
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...activeOrConfirmedBookings.take(3).map(
                            (booking) => Container(
                              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.darkDivider
                                      : AppColors.lightDivider,
                                ),
                              ),
                              child: ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xs,
                                ),
                                leading: const Icon(Icons.event_available_rounded),
                                title: Text(
                                  vehicleService
                                          .getVehicleById(booking.vehicleId)
                                          ?.name ??
                                      'Vehicle',
                                ),
                                subtitle: Text(
                                  '${DateFormat('dd MMM').format(booking.pickupDate)} - ${DateFormat('dd MMM yyyy').format(booking.returnDate)}',
                                ),
                                trailing: Text(
                                  booking.status.name.toUpperCase(),
                                  style: context.textStyles.labelSmall?.copyWith(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: booking.vehicleId == widget.vehicleId
                                    ? null
                                    : () => context.push(
                                          '/booking/${booking.vehicleId}',
                                        ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              Padding(
                padding: sectionPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rental Period',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SelectionTile(
                      icon: Icons.calendar_today_rounded,
                      title: dateLabel,
                      subtitle:
                          '$rentalDays day${rentalDays > 1 ? 's' : ''} total',
                      isSelected: true,
                      onTap: _pickDateRange,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Pickup & Drop Location',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue: _pickupLocation,
                      decoration: const InputDecoration(
                        labelText: 'Pickup Location',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      items: locations
                          .map((location) => DropdownMenuItem(
                                value: location,
                                child: Text(location),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _pickupLocation = value),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue: _dropLocation,
                      decoration: const InputDecoration(
                        labelText: 'Drop Location',
                        prefixIcon: Icon(Icons.flag_outlined),
                      ),
                      items: locations
                          .map((location) => DropdownMenuItem(
                                value: location,
                                child: Text(location),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _dropLocation = value),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (isCompactPhone)
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Insurance Plan',
                            style: context.textStyles.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                            ),
                            child: Text(
                              'RECOMMENDED',
                              style: context.textStyles.labelSmall?.copyWith(
                                color: successColor,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Insurance Plan',
                            style: context.textStyles.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                            ),
                            child: Text(
                              'RECOMMENDED',
                              style: context.textStyles.labelSmall?.copyWith(
                                color: successColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: AppSpacing.md),
                    InsuranceCard(
                      plan: 'Premium Protection',
                      price: '+\$75.00',
                      description:
                          'Full collision coverage, zero deductible, and 24/7 roadside assistance.',
                      isSelected: _selectedInsurance == 'Premium Protection',
                      onTap: () => setState(() {
                        _selectedInsurance = 'Premium Protection';
                      }),
                    ),
                    InsuranceCard(
                      plan: 'Standard Cover',
                      price: '+\$25.00',
                      description:
                          'Basic collision waiver with deductible and support coverage.',
                      isSelected: _selectedInsurance == 'Standard Cover',
                      onTap: () => setState(() {
                        _selectedInsurance = 'Standard Cover';
                      }),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkDivider
                              : AppColors.lightDivider,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Price Breakdown',
                            style: context.textStyles.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          PriceRow(
                            label: 'Rental Fee (${vehicle.name})',
                            value: '\$${rentalFee.toStringAsFixed(2)}',
                          ),
                          PriceRow(
                            label: 'Insurance ($_selectedInsurance)',
                            value: '\$${insuranceFee.toStringAsFixed(2)}',
                          ),
                          PriceRow(
                            label: 'Service Fee',
                            value: '\$${serviceFee.toStringAsFixed(2)}',
                          ),
                          PriceRow(
                            label: 'Taxes',
                            value: '\$${taxes.toStringAsFixed(2)}',
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md),
                            child: Divider(
                              thickness: 1.5,
                              color: isDark
                                  ? AppColors.darkPrimaryText
                                  : AppColors.lightPrimaryText,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'TOTAL',
                                style: context.textStyles.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '\$${total.toStringAsFixed(2)}',
                                style: context.textStyles.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: AppSpacing.paddingMd,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7FF),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.verified_user_rounded,
                            color: isDark
                                ? AppColors.darkSecondary
                                : AppColors.lightSecondary,
                            size: 24,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Secure booking with RentMyRide protection.',
                              style: context.textStyles.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.darkSecondary
                                    : AppColors.lightSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
