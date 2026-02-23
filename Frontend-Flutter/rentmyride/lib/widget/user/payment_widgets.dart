part of '../../screen/user/payment_screen.dart';

class PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final String detail;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodCard({
    super.key,
    required this.icon,
    required this.name,
    required this.detail,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final isCompactPhone = context.isCompactPhone;
    final iconWidth = isCompactPhone ? 48.0 : 56.0;
    final iconHeight = isCompactPhone ? 36.0 : 40.0;

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
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
          child: Row(
            children: [
              Container(
                width: iconWidth,
                height: iconHeight,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
              child: Icon(icon, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodySmall,
                    ),
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
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const SummaryRow({super.key, required this.label, required this.value});

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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
