import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rentmyride/service/user_service.dart';
import 'package:rentmyride/service/vehicle_service.dart';
import 'package:rentmyride/theme.dart';

part '../../widget/owner/owner_dashboard_widgets.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final user = context.watch<UserService>().currentUser;
    final vehicles = context.watch<VehicleService>().vehicles;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Owner Dashboard',
                        style: context.textStyles.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Welcome back, ${user?.name ?? "Owner"}',
                        style: context.textStyles.bodyMedium?.copyWith(
                          color:
                              isDark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.lightSecondaryText,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor, width: 2),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      backgroundColor: surfaceColor,
                      child: Text(
                        'AR',
                        style: context.textStyles.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.payments_rounded,
                      value: '\$4,250',
                      label: 'Total Revenue',
                      trend: '+12.5%',
                      trendUp: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatCard(
                      icon: Icons.key_rounded,
                      value: '${vehicles.length}',
                      label: 'Active Rentals',
                      trend: '+2.1%',
                      trendUp: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Revenue Overview',
                              style: context.textStyles.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Growth +8.2% this week',
                              style: context.textStyles.bodySmall?.copyWith(
                                color:
                                    isDark
                                        ? AppColors.darkSuccess
                                        : AppColors.lightSuccess,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const labels = [
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat',
                                    'Sun',
                                  ];
                                  if (value.toInt() >= 0 &&
                                      value.toInt() < labels.length) {
                                    return Text(
                                      labels[value.toInt()],
                                      style: context.textStyles.labelSmall,
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 1200),
                                FlSpot(1, 1800),
                                FlSpot(2, 1500),
                                FlSpot(3, 2200),
                                FlSpot(4, 1900),
                                FlSpot(5, 2500),
                                FlSpot(6, 2100),
                              ],
                              isCurved: true,
                              color: primaryColor,
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: primaryColor.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Quick Actions',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ActionChip(
                      icon: Icons.add_rounded,
                      label: 'Add Car',
                      color: const Color(0xFFE3F2FD),
                      iconColor: primaryColor,
                      onTap: () => context.push('/add-vehicle'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ActionChip(
                      icon: Icons.assessment_rounded,
                      label: 'Reports',
                      color: const Color(0xFFF3E5F5),
                      iconColor: const Color(0xFF9C27B0),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ActionChip(
                      icon: Icons.schedule_rounded,
                      label: 'Schedule',
                      color: const Color(0xFFE8F5E9),
                      iconColor:
                          isDark ? AppColors.darkSuccess : AppColors.lightSuccess,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ActionChip(
                      icon: Icons.settings_rounded,
                      label: 'Settings',
                      color: const Color(0xFFFFF3E0),
                      iconColor: const Color(0xFFF57C00),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Bookings',
                    style: context.textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'View All',
                    style: context.textStyles.labelLarge?.copyWith(
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              RentalItem(
                car: 'Tesla Model 3',
                renter: 'John Doe',
                status: 'ACTIVE',
                statusBg: const Color(0xFFDCFCE7),
                statusColor: isDark ? AppColors.darkSuccess : AppColors.lightSuccess,
                price: '\$120/day',
                img:
                    'assets/images/Tesla_Model_3_white_electric_car_null_1771667568328.jpg',
              ),
              RentalItem(
                car: 'BMW M4 Competition',
                renter: 'Sarah Smith',
                status: 'PENDING',
                statusBg: const Color(0xFFFEF9C3),
                statusColor: const Color(0xFFA16207),
                price: '\$185/day',
                img: 'assets/images/BMW_M4_blue_null_1771667571068.jpg',
              ),
              RentalItem(
                car: 'Porsche 911 Carrera',
                renter: 'Mike Ross',
                status: 'COMPLETED',
                statusBg: const Color(0xFFDBEAFE),
                statusColor:
                    isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
                price: '\$350/day',
                img:
                    'assets/images/Porsche_911_silver_sports_car_null_1771667569111.jpg',
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
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
                    Text(
                      'Vehicle Utilization',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 140,
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    value: 65,
                                    color: primaryColor,
                                    title: '65%',
                                    radius: 35,
                                    titleStyle: context.textStyles.labelSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  PieChartSectionData(
                                    value: 25,
                                    color:
                                        isDark
                                            ? AppColors.darkAccent
                                            : AppColors.lightAccent,
                                    title: '25%',
                                    radius: 35,
                                    titleStyle: context.textStyles.labelSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  PieChartSectionData(
                                    value: 10,
                                    color:
                                        isDark
                                            ? AppColors.darkError
                                            : AppColors.lightError,
                                    title: '10%',
                                    radius: 35,
                                    titleStyle: context.textStyles.labelSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                                sectionsSpace: 2,
                                centerSpaceRadius: 35,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LegendItem(color: primaryColor, label: '65% Rented'),
                            LegendItem(
                              color:
                                  isDark
                                      ? AppColors.darkAccent
                                      : AppColors.lightAccent,
                              label: '25% Available',
                            ),
                            LegendItem(
                              color:
                                  isDark
                                      ? AppColors.darkError
                                      : AppColors.lightError,
                              label: '10% Service',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
