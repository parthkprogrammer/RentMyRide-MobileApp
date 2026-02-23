part of '../../screen/user/user_dashboard.dart';

class DashboardActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  const DashboardActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final errorColor = isDark ? AppColors.darkError : AppColors.lightError;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: borderColor),
          ),
          child: Stack(
            children: [
              Center(child: Icon(icon, size: 22)),
              if (badgeCount > 0)
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
                        badgeCount > 9 ? '9+' : '$badgeCount',
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
      ),
    );
  }
}

class DashboardEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const DashboardEmptyState({
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
          const Icon(Icons.search_off_rounded, size: 36),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: context.textStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : null),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: context.textStyles.labelLarge?.copyWith(
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;

  const VehicleCard({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return GestureDetector(
      onTap: () => context.push('/vehicle/${vehicle.id}'),
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.lg),
                    topRight: Radius.circular(AppRadius.lg),
                  ),
                  child: Image(
                    image: imageProviderWithFallback(vehicle.imageUrl),
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF59E0B),
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${vehicle.rating}',
                          style: context.textStyles.labelSmall?.copyWith(
                            color: isDark
                                ? AppColors.darkPrimaryText
                                : AppColors.lightPrimaryText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: AppSpacing.md,
                  left: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      '\$${vehicle.pricePerDay.toStringAsFixed(0)}/day',
                      style: context.textStyles.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: AppSpacing.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          vehicle.name,
                          style: context.textStyles.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.favorite_border_rounded, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${vehicle.fuelType} - ${vehicle.transmission} - ${vehicle.seats} Seats',
                    style: context.textStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
