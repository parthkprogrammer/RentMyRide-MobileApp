import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rentmyride/service/user_service.dart';
import 'package:rentmyride/theme.dart';

part '../../widget/user/profile_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightSecondary;
    final successColor = isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
    final user = context.watch<UserService>().currentUser;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: primaryColor.withValues(alpha: 0.1),
                          child: Icon(Icons.person, size: 50, color: primaryColor),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    isDark
                                        ? AppColors.darkBackground
                                        : AppColors.lightBackground,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user?.name ?? 'User',
                          style: context.textStyles.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.verified_rounded, color: accentColor, size: 20),
                      ],
                    ),
                    Text(
                      user?.email ?? '',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color:
                            isDark
                                ? AppColors.darkSecondaryText
                                : AppColors.lightSecondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: AppSpacing.horizontalLg,
                child: Row(
                  children: [
                    const Expanded(child: StatCard(value: '12', label: 'Bookings')),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(child: StatCard(value: '4.9', label: 'Rating')),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(child: StatCard(value: '3y', label: 'Member')),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: AppSpacing.horizontalLg,
                child: Text(
                  'Verification',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: AppSpacing.horizontalLg,
                child: Container(
                  padding: AppSpacing.paddingLg,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: const Color(0xFFBBDEFB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(
                          Icons.badge_rounded,
                          color: primaryColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Driving License',
                              style: context.textStyles.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Verified until Oct 2025',
                              style: context.textStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.check_circle_rounded, color: successColor, size: 24),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: AppSpacing.horizontalLg,
                child: Text(
                  'Account Settings',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: AppSpacing.horizontalLg,
                child: Column(
                  children: [
                    const ProfileMenuItem(
                      icon: Icons.history_rounded,
                      title: 'Booking History',
                      subtitle: 'View all your past trips',
                    ),
                    const ProfileMenuItem(
                      icon: Icons.favorite_border_rounded,
                      title: 'Favorites',
                      subtitle: 'Cars you\'ve saved',
                    ),
                    const ProfileMenuItem(
                      icon: Icons.payment_rounded,
                      title: 'Payment Methods',
                      subtitle: 'Visa Ã¢â‚¬Â¢Ã¢â‚¬Â¢Ã¢â‚¬Â¢Ã¢â‚¬Â¢ 4242',
                    ),
                    Container(
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
                              color:
                                  isDark
                                      ? AppColors.darkBackground
                                      : AppColors.lightBackground,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              Icons.dark_mode_rounded,
                              color: primaryColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Dark Mode',
                              style: context.textStyles.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Switch(
                            value: isDark,
                            onChanged: (v) {},
                            activeColor: primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: AppSpacing.horizontalLg,
                child: Text(
                  'Support',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: AppSpacing.horizontalLg,
                child: Column(
                  children: const [
                    ProfileMenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Help Center',
                      subtitle: '',
                    ),
                    ProfileMenuItem(
                      icon: Icons.shield_outlined,
                      title: 'Privacy Policy',
                      subtitle: '',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: AppSpacing.horizontalLg,
                child: GestureDetector(
                  onTap: () {
                    context.read<UserService>().logout();
                    context.go('/');
                  },
                  child: Container(
                    padding: AppSpacing.paddingMd,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color:
                            isDark ? AppColors.darkError : AppColors.lightError,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color:
                              isDark ? AppColors.darkError : AppColors.lightError,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Logout',
                          style: context.textStyles.bodyLarge?.copyWith(
                            color:
                                isDark
                                    ? AppColors.darkError
                                    : AppColors.lightError,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
