part of '../../screen/user/booking_screen.dart';

class ProgressStep extends StatelessWidget {
  final String label;
  final bool isActive;

  const ProgressStep({super.key, required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final hintColor = isDark ? AppColors.darkHint : AppColors.lightHint;

    return Column(
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? primaryColor : dividerColor,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textStyles.labelSmall?.copyWith(
            color: isActive ? primaryColor : hintColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class SelectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback? onTap;

  const SelectionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
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
            border: Border.all(
              color:
                  isSelected
                      ? primaryColor
                      : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  icon,
                  color:
                      isSelected
                          ? primaryColor
                          : (isDark
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textStyles.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(subtitle, style: context.textStyles.bodySmall),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color:
                    isSelected
                        ? primaryColor
                        : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InsuranceCard extends StatelessWidget {
  final String plan;
  final String price;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const InsuranceCard({
    super.key,
    required this.plan,
    required this.price,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color:
                isSelected
                    ? primaryColor
                    : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color:
                    isSelected
                        ? primaryColor
                        : (isDark
                            ? AppColors.darkDivider
                            : AppColors.lightDivider),
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        plan,
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        price,
                        style: context.textStyles.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: context.textStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

class PriceRow extends StatelessWidget {
  final String label;
  final String value;

  const PriceRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: context.textStyles.bodyMedium?.copyWith(
                color:
                    isDark
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            value,
            style: context.textStyles.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
