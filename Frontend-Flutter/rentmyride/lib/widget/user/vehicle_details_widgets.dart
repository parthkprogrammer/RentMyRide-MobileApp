part of '../../screen/user/vehicle_details_screen.dart';

class RoundActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const RoundActionIcon({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: iconColor),
        ),
      ),
    );
  }
}

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

class ChatPreviewCard extends StatelessWidget {
  final String ownerName;
  final String subtitle;
  final VoidCallback onOpenChat;

  const ChatPreviewCard({
    super.key,
    required this.ownerName,
    required this.subtitle,
    required this.onOpenChat,
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
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            child: Text(ownerName.substring(0, 1).toUpperCase()),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ownerName,
                  style: context.textStyles.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: context.textStyles.bodySmall,
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onOpenChat,
            icon: const Icon(Icons.chat_rounded, size: 16),
            label: Text(
              'Open',
              style: TextStyle(color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final String reviewerName;
  final double rating;
  final String comment;
  final String dateLabel;

  const ReviewCard({
    super.key,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.dateLabel,
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
              Expanded(
                child: Text(
                  reviewerName,
                  style: context.textStyles.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
              const SizedBox(width: 2),
              Text(
                rating.toStringAsFixed(1),
                style: context.textStyles.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(comment, style: context.textStyles.bodyMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            dateLabel,
            style: context.textStyles.labelSmall,
          ),
        ],
      ),
    );
  }
}

class VehicleSectionEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const VehicleSectionEmptyState({
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
          const Icon(Icons.rate_review_outlined, size: 30),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: context.textStyles.titleMedium?.copyWith(
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
