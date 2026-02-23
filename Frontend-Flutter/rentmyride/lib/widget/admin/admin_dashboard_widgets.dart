part of '../../screen/admin/admin_dashboard.dart';

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String trend;
  final bool isPositive;

  const MetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.trend,
    required this.isPositive,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? (isDark
                          ? AppColors.darkSuccess
                          : AppColors.lightSuccess)
                      : (isDark ? AppColors.darkError : AppColors.lightError),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  trend,
                  style: context.textStyles.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: context.textStyles.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: context.textStyles.labelMedium),
        ],
      ),
    );
  }
}

class ReportedVehicleItem extends StatelessWidget {
  final String vehicle;
  final String reason;

  const ReportedVehicleItem({
    super.key,
    required this.vehicle,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.car_crash_rounded,
              color: isDark ? AppColors.darkError : AppColors.lightError,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle,
                  style: context.textStyles.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text('Reason: $reason', style: context.textStyles.labelSmall),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Investigate'),
          ),
        ],
      ),
    );
  }
}

class ApprovalItem extends StatelessWidget {
  final String title;
  final String owner;
  final String img;

  const ApprovalItem({
    super.key,
    required this.title,
    required this.owner,
    required this.img,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final successColor =
        isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
    final errorColor = isDark ? AppColors.darkError : AppColors.lightError;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

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
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Image.asset(img, width: 60, height: 44, fit: BoxFit.cover),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text('Owner: $owner', style: context.textStyles.labelSmall),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: IconButton(
                  icon: Icon(Icons.close_rounded, color: errorColor, size: 20),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: IconButton(
                  icon:
                      Icon(Icons.check_rounded, color: successColor, size: 20),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UserManageCard extends StatefulWidget {
  final String initials;
  final String name;
  final String role;
  final bool reported;
  final bool isSuspended;

  const UserManageCard({
    super.key,
    required this.initials,
    required this.name,
    required this.role,
    required this.reported,
    required this.isSuspended,
  });

  @override
  State<UserManageCard> createState() => _UserManageCardState();
}

class _UserManageCardState extends State<UserManageCard> {
  late bool _isSuspended;

  @override
  void initState() {
    super.initState();
    _isSuspended = widget.isSuspended;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final errorColor = isDark ? AppColors.darkError : AppColors.lightError;
    final successColor =
        isDark ? AppColors.darkSuccess : AppColors.lightSuccess;

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
              CircleAvatar(
                radius: 20,
                backgroundColor: backgroundColor,
                child: Text(
                  widget.initials,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: context.textStyles.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(widget.role, style: context.textStyles.labelSmall),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit_note_rounded, size: 20),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          Divider(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.report_problem_rounded,
                    color: widget.reported ? errorColor : successColor,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.reported ? 'Flagged for review' : 'Account Healthy',
                    style: context.textStyles.labelSmall?.copyWith(
                      color: widget.reported
                          ? errorColor
                          : (isDark
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Suspend',
                    style: context.textStyles.labelMedium?.copyWith(
                      color: isDark
                          ? AppColors.darkSecondaryText
                          : AppColors.lightSecondaryText,
                    ),
                  ),
                  Switch(
                    value: _isSuspended,
                    onChanged: (v) => setState(() => _isSuspended = v),
                    activeThumbColor: errorColor,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SystemCommandCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const SystemCommandCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;

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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppSpacing.sm),
          Text(label,
              style: context.textStyles.labelMedium,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
