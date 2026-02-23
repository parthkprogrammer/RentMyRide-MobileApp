part of '../../screen/login_screen.dart';

class RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final String desc;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleChip({
    super.key,
    required this.label,
    required this.icon,
    required this.desc,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final isCompactPhone = context.isCompactPhone;
    final iconSize = isCompactPhone ? 20.0 : 24.0;
    final chipIconContainerSize = isCompactPhone ? 38.0 : 44.0;
    final chipPadding = EdgeInsets.symmetric(
      horizontal: isCompactPhone ? 10 : AppSpacing.md,
      vertical: isCompactPhone ? 10 : AppSpacing.md,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: chipPadding,
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : surfaceColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: isSelected ? primaryColor : dividerColor),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: Column(
          children: [
            Container(
              width: chipIconContainerSize,
              height: chipIconContainerSize,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? Colors.white.withValues(alpha: 0.13)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Icon(
                icon,
                color:
                    isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText),
                size: iconSize,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: context.textStyles.labelSmall?.copyWith(
                color:
                    isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColors.darkPrimaryText
                            : AppColors.lightPrimaryText),
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              desc,
              style: context.textStyles.bodySmall?.copyWith(
                color:
                    isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText),
                fontSize: isCompactPhone ? 9 : 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  final String label;
  final Color surfaceColor;
  final Color dividerColor;
  final VoidCallback? onTap;

  const SocialButton({
    super.key,
    required this.label,
    required this.surfaceColor,
    required this.dividerColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompactPhone = context.isCompactPhone;
    final buttonHeight = isCompactPhone ? 50.0 : 56.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Theme.of(context).colorScheme.primary.withValues(
          alpha: 0.06,
        ),
        child: Container(
          height: buttonHeight,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: dividerColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: context.textStyles.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
