import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final vehicle = context.watch<VehicleService>().getVehicleById(widget.vehicleId);
    if (vehicle == null) {
      return const Scaffold(body: Center(child: Text('Vehicle not found')));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final successColor = isDark ? AppColors.darkSuccess : AppColors.lightSuccess;

    final rentalFee = vehicle.pricePerDay * 5;
    final insuranceFee = _selectedInsurance == 'Premium Protection' ? 75.0 : 25.0;
    final serviceFee = 25.40;
    final taxes = 12.10;
    final total = rentalFee + insuranceFee + serviceFee + taxes;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    48,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    border: Border(
                      bottom: BorderSide(
                        color:
                            isDark
                                ? AppColors.darkDivider
                                : AppColors.lightDivider,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, size: 24),
                            onPressed: () => context.pop(),
                          ),
                          Text(
                            'Review Booking',
                            style: context.textStyles.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.info_outlined,
                              color:
                                  isDark
                                      ? AppColors.darkSecondaryText
                                      : AppColors.lightSecondaryText,
                              size: 20,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: ProgressStep(label: 'Duration', isActive: true),
                          ),
                          Expanded(
                            child: ProgressStep(
                              label: 'Insurance',
                              isActive: true,
                            ),
                          ),
                          Expanded(
                            child: ProgressStep(label: 'Payment', isActive: false),
                          ),
                          Expanded(
                            child: ProgressStep(label: 'Confirm', isActive: false),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: AppSpacing.paddingLg,
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
                        title: 'Oct 24 - Oct 29, 2023',
                        subtitle: '5 Days Total',
                        isSelected: true,
                      ),
                      SelectionTile(
                        icon: Icons.location_on_rounded,
                        title: 'Downtown Hub',
                        subtitle: 'Pick-up & Drop-off point',
                        isSelected: false,
                      ),
                      const SizedBox(height: AppSpacing.lg),
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
                              borderRadius: BorderRadius.circular(AppRadius.full),
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
                        onTap:
                            () => setState(
                              () => _selectedInsurance = 'Premium Protection',
                            ),
                      ),
                      InsuranceCard(
                        plan: 'Standard Cover',
                        price: '+\$25.00',
                        description:
                            'Basic collision damage waiver with \$500 deductible.',
                        isSelected: _selectedInsurance == 'Standard Cover',
                        onTap:
                            () => setState(
                              () => _selectedInsurance = 'Standard Cover',
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(
                            color:
                                isDark
                                    ? AppColors.darkDivider
                                    : AppColors.lightDivider,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
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
                              label: 'Taxes & VAT (15%)',
                              value: '\$${taxes.toStringAsFixed(2)}',
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              child: Divider(
                                thickness: 1.5,
                                color:
                                    isDark
                                        ? AppColors.darkPrimaryText
                                        : AppColors.lightPrimaryText,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TOTAL AMOUNT',
                                      style: context.textStyles.labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    Text(
                                      'Inclusive of all taxes',
                                      style: context.textStyles.bodySmall,
                                    ),
                                  ],
                                ),
                                Text(
                                  '\$${total.toStringAsFixed(2)}',
                                  style: context.textStyles.headlineLarge
                                      ?.copyWith(
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
                            color: const Color(
                              0xFF3B82F6,
                            ).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              color:
                                  isDark
                                      ? AppColors.darkSecondary
                                      : AppColors.lightSecondary,
                              size: 24,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                'Secure booking with RentMyRide Protection Guarantee.',
                                style: context.textStyles.bodySmall?.copyWith(
                                  color:
                                      isDark
                                          ? AppColors.darkSecondary
                                          : AppColors.lightSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: AppSpacing.paddingLg,
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(
                  top: BorderSide(
                    color:
                        isDark ? AppColors.darkDivider : AppColors.lightDivider,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
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
                          'Total for 5 days',
                          style: context.textStyles.labelSmall?.copyWith(
                            color:
                                isDark
                                    ? AppColors.darkSecondaryText
                                    : AppColors.lightSecondaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/payment/${widget.vehicleId}'),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Proceed to Payment'),
                        iconAlignment: IconAlignment.end,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
