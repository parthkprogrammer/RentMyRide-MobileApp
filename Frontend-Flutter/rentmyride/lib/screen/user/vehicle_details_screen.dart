import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rentmyride/service/user_service.dart';
import 'package:rentmyride/service/vehicle_service.dart';
import 'package:rentmyride/theme.dart';

part '../../widget/user/vehicle_details_widgets.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final String vehicleId;

  const VehicleDetailsScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    final vehicle = context.watch<VehicleService>().getVehicleById(vehicleId);
    if (vehicle == null) {
      return const Scaffold(body: Center(child: Text('Vehicle not found')));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final owner = context.watch<UserService>().getUserById(vehicle.ownerId);

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    Image.asset(
                      vehicle.imageUrl,
                      height: 350,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  size: 22,
                                ),
                                onPressed: () => context.pop(),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.full,
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.favorite_border_rounded,
                                      color:
                                          isDark
                                              ? AppColors.darkError
                                              : AppColors.lightError,
                                      size: 22,
                                    ),
                                    onPressed: () {},
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.full,
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.share_rounded,
                                      size: 22,
                                    ),
                                    onPressed: () {},
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 24,
                            height: 6,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: AppSpacing.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicle.name,
                                  style: context.textStyles.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Color(0xFF60A5FA),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${vehicle.rating}',
                                      style: context.textStyles.bodyMedium
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${vehicle.reviewCount} reviews)',
                                      style: context.textStyles.bodyMedium
                                          ?.copyWith(
                                            color:
                                                isDark
                                                    ? AppColors.darkSecondaryText
                                                    : AppColors.lightSecondaryText,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${vehicle.pricePerDay.toStringAsFixed(0)}',
                                style: context.textStyles.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              Text(
                                'per day',
                                style: context.textStyles.labelSmall?.copyWith(
                                  color:
                                      isDark
                                          ? AppColors.darkSecondaryText
                                          : AppColors.lightSecondaryText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Divider(
                        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: SpecCard(
                              icon: Icons.electric_car_rounded,
                              label: 'Range',
                              value: vehicle.range ?? 'N/A',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: SpecCard(
                              icon: Icons.speed_rounded,
                              label: '0-60 mph',
                              value: vehicle.acceleration ?? 'N/A',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: SpecCard(
                              icon: Icons.airline_seat_recline_extra_rounded,
                              label: 'Seats',
                              value: '${vehicle.seats} Adults',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: SpecCard(
                              icon: Icons.settings_input_component_rounded,
                              label: 'Drive',
                              value: vehicle.transmission,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'About this vehicle',
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        vehicle.description,
                        style: context.textStyles.bodyMedium?.copyWith(
                          color:
                              isDark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.lightSecondaryText,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children:
                            vehicle.features
                                .map((f) => FeatureChip(label: f))
                                .toList(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: AppSpacing.paddingMd,
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color:
                                isDark
                                    ? AppColors.darkDivider
                                    : AppColors.lightDivider,
                          ),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 25,
                              child: Icon(Icons.person, size: 28),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        owner?.name ?? 'Owner',
                                        style: context.textStyles.bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.verified_rounded,
                                        color:
                                            isDark
                                                ? AppColors.darkAccent
                                                : AppColors.lightSecondary,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Member since 2021 ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ 98% Response rate',
                                    style: context.textStyles.labelSmall
                                        ?.copyWith(
                                          color:
                                              isDark
                                                  ? AppColors.darkSecondaryText
                                                  : AppColors.lightSecondaryText,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 16,
                              ),
                              label: const Text('Chat'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Pickup Location',
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color:
                                isDark
                                    ? AppColors.darkSecondaryText
                                    : AppColors.lightSecondaryText,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            vehicle.location,
                            style: context.textStyles.bodyMedium?.copyWith(
                              color:
                                  isDark
                                      ? AppColors.darkSecondaryText
                                      : AppColors.lightSecondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: Image.asset(
                          'assets/images/minimal_city_map_with_pin_null_1771667574634.png',
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(
                  top: BorderSide(
                    color:
                        isDark ? AppColors.darkDivider : AppColors.lightDivider,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total Price',
                          style: context.textStyles.labelSmall?.copyWith(
                            color:
                                isDark
                                    ? AppColors.darkSecondaryText
                                    : AppColors.lightSecondaryText,
                          ),
                        ),
                        Text(
                          '\$${(vehicle.pricePerDay * 2).toStringAsFixed(2)}',
                          style: context.textStyles.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '2 days total',
                          style: context.textStyles.labelSmall?.copyWith(
                            color:
                                isDark
                                    ? AppColors.darkSecondaryText
                                    : AppColors.lightSecondaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.push('/booking/${vehicle.id}'),
                        child: const Text('Book Now'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
