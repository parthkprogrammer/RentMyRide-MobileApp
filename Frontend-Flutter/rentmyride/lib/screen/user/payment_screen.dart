import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rentmyride/model/booking_model.dart';
import 'package:rentmyride/service/booking_service.dart';
import 'package:rentmyride/service/notification_service.dart';
import 'package:rentmyride/service/user_service.dart';
import 'package:rentmyride/service/vehicle_service.dart';
import 'package:rentmyride/theme.dart';
import 'package:rentmyride/utils/image_source_resolver.dart';

part '../../widget/user/payment_widgets.dart';

class PaymentScreen extends StatefulWidget {
  final String vehicleId;

  const PaymentScreen({super.key, required this.vehicleId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedPaymentMethodId;

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    final bookingService = context.watch<BookingService>();
    final vehicleService = context.watch<VehicleService>();
    final currentUser = userService.currentUser;
    final vehicle = vehicleService.getVehicleById(widget.vehicleId);

    if (vehicle == null || currentUser == null) {
      return const Scaffold(
          body: Center(child: Text('Unable to continue checkout')));
    }

    final draft = bookingService.getDraft(
      userId: currentUser.id,
      vehicleId: widget.vehicleId,
    );

    final pickupDate =
        draft?.pickupDate ?? DateTime.now().add(const Duration(days: 1));
    final returnDate =
        draft?.returnDate ?? DateTime.now().add(const Duration(days: 4));
    final pickupLocation = draft?.pickupLocation ?? vehicle.location;
    final rentalFee = draft?.rentalFee ?? vehicle.pricePerDay * 3;
    final insuranceFee = draft?.insuranceFee ?? 45.0;
    final serviceFee = draft?.serviceFee ?? 12.50;
    final taxes = draft?.taxes ?? 18.00;
    final total =
        draft?.totalAmount ?? (rentalFee + insuranceFee + serviceFee + taxes);
    final days = (returnDate.difference(pickupDate).inDays).clamp(1, 365);

    final paymentMethods = userService.currentUserPaymentMethods;
    if (_selectedPaymentMethodId == null && paymentMethods.isNotEmpty) {
      _selectedPaymentMethodId = paymentMethods
          .firstWhere(
            (method) => method.isDefault,
            orElse: () => paymentMethods.first,
          )
          .id;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final successColor =
        isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
    final isCompactPhone = context.isCompactPhone;
    final horizontalPadding = isCompactPhone ? AppSpacing.md : AppSpacing.lg;
    final bottomInset = MediaQuery.of(context).padding.bottom + 140;

    Future<void> onPayNow() async {
      final bookingService = context.read<BookingService>();
      final notificationService = context.read<NotificationService>();

      if (_selectedPaymentMethodId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add a payment method before paying')),
        );
        return;
      }

      var booking = await bookingService.confirmDraft(
        userId: currentUser.id,
        vehicleId: widget.vehicleId,
      );

      booking ??= BookingModel(
        id: 'RM${DateTime.now().microsecondsSinceEpoch.toString().substring(7)}',
        userId: currentUser.id,
        vehicleId: widget.vehicleId,
        ownerId: vehicle.ownerId,
        pickupDate: pickupDate,
        returnDate: returnDate,
        pickupLocation: pickupLocation,
        insurancePlan: draft?.insurancePlan ?? 'Premium Protection',
        rentalFee: rentalFee,
        insuranceFee: insuranceFee,
        serviceFee: serviceFee,
        taxes: taxes,
        totalAmount: total,
        status: BookingStatus.confirmed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      if (draft == null) {
        await bookingService.createBooking(booking);
      }

      await notificationService.sendToUser(
        userId: currentUser.id,
        title: 'Payment Successful',
        message: 'Booking ${booking.id} has been confirmed.',
      );
      await notificationService.sendToUser(
        userId: vehicle.ownerId,
        title: 'New Booking Received',
        message: '${vehicle.name} has a confirmed booking (${booking.id}).',
      );

      if (!mounted) return;
      await showDialog<void>(
        context: this.context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Payment Successful'),
          content: Text('Your booking ${booking!.id} has been confirmed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      this.context.go('/user-dashboard');
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: onPayNow,
                icon: const Icon(Icons.lock_rounded),
                label: Text('Pay \$${total.toStringAsFixed(2)} Now'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded,
                      size: 16, color: successColor),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Payment Confidence Guaranteed',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodySmall?.copyWith(
                        color: successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
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
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? AppColors.darkDivider
                          : AppColors.lightDivider,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, size: 24),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/booking/${widget.vehicleId}');
                        }
                      },
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shield_rounded,
                              color: successColor, size: 20),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Secure Checkout',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textStyles.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline_rounded, size: 24),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: AppSpacing.sm,
                ),
                color: const Color(0xFFF0FDF4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_rounded, size: 14, color: successColor),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'End-to-end encrypted payment',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.labelMedium?.copyWith(
                          color: successColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkDivider
                          : AppColors.lightDivider,
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: Image(
                          image: imageProviderWithFallback(vehicle.imageUrl),
                          width: isCompactPhone ? 84 : 100,
                          height: isCompactPhone ? 62 : 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textStyles.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${DateFormat('dd MMM').format(pickupDate)} - ${DateFormat('dd MMM yyyy').format(returnDate)} ($days days)',
                              style: context.textStyles.bodySmall,
                            ),
                            Text(
                              'Pickup: $pickupLocation',
                              style: context.textStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Payment Method',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (paymentMethods.isEmpty)
                      Container(
                        padding: AppSpacing.paddingLg,
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkDivider
                                : AppColors.lightDivider,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('No payment methods available.'),
                            const SizedBox(height: AppSpacing.sm),
                            OutlinedButton(
                              onPressed: () => context.push('/profile'),
                              child: const Text('Add Payment Method'),
                            ),
                          ],
                        ),
                      )
                    else
                      ...paymentMethods.map(
                        (method) => PaymentMethodCard(
                          icon: Icons.credit_card_rounded,
                          name: method.brand,
                          detail: '**** ${method.last4} - ${method.expiry}',
                          isSelected: _selectedPaymentMethodId == method.id,
                          onTap: () => setState(() {
                            _selectedPaymentMethodId = method.id;
                          }),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: AppSpacing.paddingLg,
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
                            'Price Details',
                            style: context.textStyles.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SummaryRow(
                            label:
                                'Rental Fee (\$${vehicle.pricePerDay.toStringAsFixed(0)} x $days days)',
                            value: '\$${rentalFee.toStringAsFixed(2)}',
                          ),
                          SummaryRow(
                            label:
                                'Insurance (${draft?.insurancePlan ?? 'Premium'})',
                            value: '\$${insuranceFee.toStringAsFixed(2)}',
                          ),
                          SummaryRow(
                            label: 'Service Fee',
                            value: '\$${serviceFee.toStringAsFixed(2)}',
                          ),
                          SummaryRow(
                            label: 'Taxes',
                            value: '\$${taxes.toStringAsFixed(2)}',
                          ),
                          Divider(
                            color: isDark
                                ? AppColors.darkDivider
                                : AppColors.lightDivider,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Amount',
                                style: context.textStyles.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${total.toStringAsFixed(2)}',
                                style: context.textStyles.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
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
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkDivider
                              : AppColors.lightDivider,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.security_rounded,
                                color: isDark
                                    ? AppColors.darkSecondary
                                    : AppColors.lightSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                '256-bit SSL Secure Encryption',
                                style: context.textStyles.labelMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Icon(
                                Icons.verified_user_rounded,
                                color: successColor,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Transaction protected by RentMyRide Guarantee',
                                  style: context.textStyles.bodySmall,
                                ),
                              ),
                            ],
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
