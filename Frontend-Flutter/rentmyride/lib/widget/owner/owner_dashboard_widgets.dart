part of '../../screen/owner/owner_dashboard.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String trend;
  final bool trendUp;

  const StatCard({
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
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: primaryColor, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      trendUp
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  children: [
                    Icon(
                      trendUp
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 10,
                      color:
                          trendUp
                              ? (isDark
                                  ? AppColors.darkSuccess
                                  : AppColors.lightSuccess)
                              : (isDark
                                  ? AppColors.darkError
                                  : AppColors.lightError),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend,
                      style: context.textStyles.labelSmall?.copyWith(
                        color:
                            trendUp
                                ? (isDark
                                    ? AppColors.darkSuccess
                                    : AppColors.lightSuccess)
                                : (isDark
                                    ? AppColors.darkError
                                    : AppColors.lightError),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: context.textStyles.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: context.textStyles.bodySmall),
        ],
      ),
    );
  }
}

class ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const ActionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: context.textStyles.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class RentalItem extends StatelessWidget {
  final String car;
  final String renter;
  final String status;
  final Color statusBg;
  final Color statusColor;
  final String price;
  final String img;

  const RentalItem({
    super.key,
    required this.car,
    required this.renter,
    required this.status,
    required this.statusBg,
    required this.statusColor,
    required this.price,
    required this.img,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Image.asset(img, width: 80, height: 60, fit: BoxFit.cover),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car,
                  style: context.textStyles.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 14),
                    const SizedBox(width: 4),
                    Text(renter, style: context.textStyles.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  status,
                  style: context.textStyles.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: context.textStyles.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
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

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: context.textStyles.bodySmall),
        ],
      ),
    );
  }
}
