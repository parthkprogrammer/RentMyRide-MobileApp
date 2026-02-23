part of '../../screen/user/profile_screen.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;

  const StatCard({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: context.textStyles.labelSmall?.copyWith(
              color: isDark
                  ? AppColors.darkSecondaryText
                  : AppColors.lightSecondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: primaryColor, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textStyles.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(subtitle, style: context.textStyles.bodySmall),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? AppColors.darkHint : AppColors.lightHint,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileSectionEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const ProfileSectionEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_rounded, size: 24),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: context.textStyles.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: context.textStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class BookingHistoryCard extends StatelessWidget {
  final String bookingId;
  final String vehicleName;
  final String dateRange;
  final String amount;
  final String status;

  const BookingHistoryCard({
    super.key,
    required this.bookingId,
    required this.vehicleName,
    required this.dateRange,
    required this.amount,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(Icons.receipt_long_rounded, color: primaryColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicleName,
                  style: context.textStyles.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$bookingId • $dateRange',
                  style: context.textStyles.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: context.textStyles.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                status,
                style: context.textStyles.labelSmall?.copyWith(
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoriteVehicleCard extends StatelessWidget {
  final String vehicleName;
  final String imagePath;
  final String priceText;
  final VoidCallback onTap;

  const FavoriteVehicleCard({
    super.key,
    required this.vehicleName,
    required this.imagePath,
    required this.priceText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                bottomLeft: Radius.circular(AppRadius.lg),
              ),
              child: Image(
                image: imageProviderWithFallback(imagePath),
                width: 90,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: AppSpacing.paddingMd,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      vehicleName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(priceText, style: context.textStyles.bodySmall),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentMethodTile extends StatelessWidget {
  final PaymentMethodModel method;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const PaymentMethodTile({
    super.key,
    required this.method,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: method.isDefault
              ? primaryColor
              : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(Icons.credit_card_rounded, color: primaryColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${method.brand} •••• ${method.last4}',
                  style: context.textStyles.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${method.holderName} • Exp ${method.expiry}',
                  style: context.textStyles.bodySmall,
                ),
              ],
            ),
          ),
          if (!method.isDefault)
            TextButton(
              onPressed: onSetDefault,
              child: const Text('Default'),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                'DEFAULT',
                style: context.textStyles.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }
}
