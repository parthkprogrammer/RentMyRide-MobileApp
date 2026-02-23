part of '../../screen/owner/owner_dashboard.dart';

class NotificationBadgeButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const NotificationBadgeButton({
    super.key,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final errorColor = isDark ? AppColors.darkError : AppColors.lightError;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.full),
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor),
        ),
        child: Stack(
          children: [
            const Center(child: Icon(Icons.notifications_none_rounded)),
            if (count > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: errorColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: context.textStyles.labelSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class OwnerStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String trend;
  final bool trendUp;

  const OwnerStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.trend,
    required this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryColor, size: 22),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: context.textStyles.bodySmall),
          const SizedBox(height: 2),
          Text(
            trend,
            style: context.textStyles.labelSmall?.copyWith(
              color: trendUp
                  ? (isDark ? AppColors.darkSuccess : AppColors.lightSuccess)
                  : (isDark ? AppColors.darkError : AppColors.lightError),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryColor),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: context.textStyles.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class OwnerBookingCard extends StatelessWidget {
  final BookingModel booking;
  final String vehicleName;
  final VoidCallback onReportUser;

  const OwnerBookingCard({
    super.key,
    required this.booking,
    required this.vehicleName,
    required this.onReportUser,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.directions_car_rounded, color: primaryColor),
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
                      '${DateFormat('dd MMM').format(booking.pickupDate)} - ${DateFormat('dd MMM yyyy').format(booking.returnDate)}',
                      style: context.textStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '\$${booking.totalAmount.toStringAsFixed(0)}',
                style: context.textStyles.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(
                booking.status.name.toUpperCase(),
                style: context.textStyles.labelSmall?.copyWith(
                  color: primaryColor,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onReportUser,
                icon: const Icon(Icons.report_gmailerrorred_rounded, size: 16),
                label: const Text('Report User'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OwnerReviewCard extends StatelessWidget {
  final String name;
  final double rating;
  final String comment;

  const OwnerReviewCard({
    super.key,
    required this.name,
    required this.rating,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: context.textStyles.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
              const SizedBox(width: 2),
              Text(rating.toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment, style: context.textStyles.bodySmall),
        ],
      ),
    );
  }
}

class OwnerEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const OwnerEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
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
