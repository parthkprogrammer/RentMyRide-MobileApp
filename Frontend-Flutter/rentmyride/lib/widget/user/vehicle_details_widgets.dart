part of '../../screen/user/vehicle_details_screen.dart';

class SpecCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const SpecCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryColor, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.textStyles.labelSmall?.copyWith(
              color:
                  isDark
                      ? AppColors.darkSecondaryText
                      : AppColors.lightSecondaryText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: context.textStyles.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureChip extends StatelessWidget {
  final String label;

  const FeatureChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: isDark ? AppColors.darkSuccess : AppColors.lightSuccess,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(label, style: context.textStyles.labelSmall),
        ],
      ),
    );
  }
}
