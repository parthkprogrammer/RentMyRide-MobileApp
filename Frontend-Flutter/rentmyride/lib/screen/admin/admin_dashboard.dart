import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentmyride/service/user_service.dart';
import 'package:rentmyride/service/vehicle_service.dart';
import 'package:rentmyride/theme.dart';

part '../../widget/admin/admin_dashboard_widgets.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final vehicles = context.watch<VehicleService>().vehicles;
    final users = context.watch<UserService>().users;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: AppSpacing.paddingLg,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  border: Border(
                    bottom: BorderSide(
                      color:
                          isDark
                              ? AppColors.darkDivider
                              : AppColors.lightDivider,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin Control Center',
                              style: context.textStyles.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Enterprise Governance & Oversight',
                              style: context.textStyles.bodySmall,
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: primaryColor,
                          child: Text(
                            'AD',
                            style: context.textStyles.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search users, VIN, or reports...',
                              prefixIcon: const Icon(Icons.search),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? AppColors.darkBackground
                                    : AppColors.lightBackground,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color:
                                  isDark
                                      ? AppColors.darkDivider
                                      : AppColors.lightDivider,
                            ),
                          ),
                          child: const Icon(Icons.tune_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MetricCard(
                            icon: Icons.group_rounded,
                            label: 'Total Users',
                            value: '${users.length}k',
                            trend: '+12%',
                            isPositive: true,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: MetricCard(
                            icon: Icons.directions_car_rounded,
                            label: 'Active Fleet',
                            value: '${vehicles.length}',
                            trend: '+5%',
                            isPositive: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Reported Vehicles',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ReportedVehicleItem(
                      vehicle: 'Tesla Model S (ABC-123)',
                      reason: 'Safety concerns reported by renter',
                    ),
                    ReportedVehicleItem(
                      vehicle: 'Honda Civic (XYZ-789)',
                      reason: 'Inaccurate photos provided',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pending Approvals',
                          style: context.textStyles.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? AppColors.darkAccent
                                    : AppColors.lightAccent,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            '3 NEW',
                            style: context.textStyles.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ApprovalItem(
                      title: 'Tesla Model 3 - 2023',
                      owner: 'John Doe',
                      img:
                          'assets/images/Tesla_Model_3_white_electric_car_null_1771667568328.jpg',
                    ),
                    ApprovalItem(
                      title: 'BMW X5 xDrive',
                      owner: 'Sarah Smith',
                      img:
                          'assets/images/black_luxury_BMW_SUV_null_1771667576545.jpg',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'User Governance',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    UserManageCard(
                      initials: 'AJ',
                      name: 'Alex Johnson',
                      role: 'Renter Ã¢â‚¬Â¢ 14 Bookings',
                      reported: false,
                      isSuspended: false,
                    ),
                    UserManageCard(
                      initials: 'MG',
                      name: 'Maria Garcia',
                      role: 'Owner Ã¢â‚¬Â¢ 3 Vehicles',
                      reported: true,
                      isSuspended: false,
                    ),
                    UserManageCard(
                      initials: 'RC',
                      name: 'Robert Chen',
                      role: 'Renter Ã¢â‚¬Â¢ New Account',
                      reported: false,
                      isSuspended: true,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'System Commands',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.5,
                      children: [
                        SystemCommandCard(
                          icon: Icons.shield_rounded,
                          label: 'Security Audit',
                          color: primaryColor,
                        ),
                        SystemCommandCard(
                          icon: Icons.auto_graph_rounded,
                          label: 'Market Reports',
                          color:
                              isDark
                                  ? AppColors.darkSuccess
                                  : AppColors.lightSuccess,
                        ),
                        SystemCommandCard(
                          icon: Icons.account_tree_rounded,
                          label: 'API Status',
                          color:
                              isDark
                                  ? AppColors.darkSecondary
                                  : AppColors.lightSecondary,
                        ),
                        SystemCommandCard(
                          icon: Icons.settings_applications_rounded,
                          label: 'System Config',
                          color:
                              isDark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.lightSecondaryText,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.campaign_rounded),
        label: const Text('Broadcast Notice'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
