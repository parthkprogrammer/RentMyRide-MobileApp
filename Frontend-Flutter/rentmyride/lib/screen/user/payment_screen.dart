import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rentmyride/service/vehicle_service.dart';
import 'package:rentmyride/theme.dart';

part '../../widget/user/payment_widgets.dart';

class PaymentScreen extends StatefulWidget {
  final String vehicleId;

  const PaymentScreen({super.key, required this.vehicleId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPayment = 'Credit Card';

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

    final total = 312.50;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color:
                            isDark
                                ? AppColors.darkDivider
                                : AppColors.lightDivider,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, size: 24),
                          onPressed: () => context.pop(),
                        ),
                        Row(
                          children: [
                            Icon(Icons.shield_rounded, color: successColor, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              'Secure Checkout',
                              style: context.textStyles.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.info_outline_rounded, size: 24),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  color: const Color(0xFFF0FDF4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_rounded, size: 14, color: successColor),
                      const SizedBox(width: 4),
                      Text(
                        'End-to-end encrypted payment',
                        style: context.textStyles.labelMedium?.copyWith(
                          color: successColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: successColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dates',
                            style: context.textStyles.labelSmall?.copyWith(
                              color:
                                  isDark
                                      ? AppColors.darkSecondaryText
                                      : AppColors.lightSecondaryText,
                            ),
                          ),
                        ],
                      ),
                      Expanded(child: Container(height: 2, color: successColor)),
                      Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '2',
                              style: context.textStyles.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Payment',
                            style: context.textStyles.labelSmall?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(
                          height: 2,
                          color:
                              isDark
                                  ? AppColors.darkDivider
                                  : AppColors.lightDivider,
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    isDark
                                        ? AppColors.darkDivider
                                        : AppColors.lightDivider,
                              ),
                            ),
                            child: Text(
                              '3',
                              style: context.textStyles.labelSmall?.copyWith(
                                color:
                                    isDark
                                        ? AppColors.darkSecondaryText
                                        : AppColors.lightSecondaryText,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Confirm',
                            style: context.textStyles.labelSmall?.copyWith(
                              color:
                                  isDark
                                      ? AppColors.darkSecondaryText
                                      : AppColors.lightSecondaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: AppSpacing.horizontalLg,
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                      color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: Image.asset(
                          vehicle.imageUrl,
                          width: 100,
                          height: 70,
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
                              style: context.textStyles.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'Oct 24 - Oct 27 (3 Days)',
                                  style: context.textStyles.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
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
                      PaymentMethodCard(
                        icon: Icons.credit_card_rounded,
                        name: 'Credit Card',
                        detail: 'Visa Ã¢â‚¬Â¢Ã¢â‚¬Â¢Ã¢â‚¬Â¢Ã¢â‚¬Â¢ 4242',
                        isSelected: _selectedPayment == 'Credit Card',
                        onTap: () => setState(() => _selectedPayment = 'Credit Card'),
                      ),
                      PaymentMethodCard(
                        icon: Icons.account_balance_wallet_rounded,
                        name: 'Apple Pay',
                        detail: 'Instant & Secure',
                        isSelected: _selectedPayment == 'Apple Pay',
                        onTap: () => setState(() => _selectedPayment = 'Apple Pay'),
                      ),
                      PaymentMethodCard(
                        icon: Icons.account_balance_rounded,
                        name: 'UPI / Bank Transfer',
                        detail: 'Pay via any UPI app',
                        isSelected: _selectedPayment == 'UPI',
                        onTap: () => setState(() => _selectedPayment = 'UPI'),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color:
                                isDark
                                    ? AppColors.darkDivider
                                    : AppColors.lightDivider,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_offer_outlined,
                              color:
                                  isDark
                                      ? AppColors.darkSecondaryText
                                      : AppColors.lightSecondaryText,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Enter promo code',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Apply',
                                style: TextStyle(color: primaryColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: AppSpacing.paddingLg,
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(
                            color:
                                isDark
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
                            const SummaryRow(
                              label: 'Rental Fee (\$85 x 3 days)',
                              value: '\$255.00',
                            ),
                            const SummaryRow(
                              label: 'Insurance (Premium)',
                              value: '\$45.00',
                            ),
                            const SummaryRow(
                              label: 'Service Fee',
                              value: '\$12.50',
                            ),
                            Divider(
                              color:
                                  isDark
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
                            color:
                                isDark
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
                                  color:
                                      isDark
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
                                    'Your transaction is protected by RentMyRide Guarantee',
                                    style: context.textStyles.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              color:
                                  isDark
                                      ? AppColors.darkDivider
                                      : AppColors.lightDivider,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Payment Partner',
                                  style: context.textStyles.labelSmall?.copyWith(
                                    color:
                                        isDark
                                            ? AppColors.darkSecondaryText
                                            : AppColors.lightSecondaryText,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.payments_rounded,
                                      size: 16,
                                      color: primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Stripe',
                                      style: context.textStyles.labelLarge
                                          ?.copyWith(fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 120),
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
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                title: const Text('Payment Successful'),
                                content: const Text(
                                  'Your booking has been confirmed!',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      context.go('/user-dashboard');
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text('Pay \$${total.toStringAsFixed(2)} Now'),
                      iconAlignment: IconAlignment.end,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 16,
                          color: successColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Payment Confidence Guaranteed',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: successColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
