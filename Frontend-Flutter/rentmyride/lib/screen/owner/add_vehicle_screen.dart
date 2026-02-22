import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rentmyride/theme.dart';

part '../../widget/owner/add_vehicle_widgets.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.pop(),
                  ),
                  Text(
                    'List Your Vehicle',
                    style: context.textStyles.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: StepIndicator(
                      number: '1',
                      isActive: true,
                      isCompleted: true,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: StepIndicator(
                      number: '2',
                      isActive: false,
                      isCompleted: false,
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isDark
                                ? AppColors.darkDivider
                                : AppColors.lightDivider,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '3',
                        style: context.textStyles.bodySmall?.copyWith(
                          color:
                              isDark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.lightSecondaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              FormLabel(label: 'Vehicle Photos'),
              Text(
                'Upload at least 3 high-quality images of your ride',
                style: context.textStyles.bodySmall?.copyWith(
                  color:
                      isDark
                          ? AppColors.darkSecondaryText
                          : AppColors.lightSecondaryText,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Container(
                            width: 140,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: primaryColor),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Image.asset(
                              'assets/images/modern_blue_sedan_car_side_view_null_1771667575645.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.53),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.md),
                    ImagePlaceholder(),
                    const SizedBox(width: AppSpacing.md),
                    ImagePlaceholder(),
                    const SizedBox(width: AppSpacing.md),
                    ImagePlaceholder(),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FormLabel(label: 'Vehicle Name'),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'e.g. Tesla Model 3 2023',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: SpecDropdown(label: 'Category', hint: 'Select')),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: SpecDropdown(label: 'Fuel Type', hint: 'Select'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: SpecDropdown(label: 'Transmission', hint: 'Select'),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel(label: 'Seats'),
                        TextField(
                          decoration: const InputDecoration(hintText: '4'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Divider(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Pricing & Deposit',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel(label: 'Price per Day'),
                        TextField(
                          decoration: const InputDecoration(
                            hintText: '0.00',
                            prefixText: '\$ ',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormLabel(label: 'Security Deposit'),
                        TextField(
                          decoration: const InputDecoration(
                            hintText: '0.00',
                            prefixText: '\$ ',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              FormLabel(label: 'Pickup Location'),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/minimal_city_map_with_pin_null_1771667574634.png',
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: AppSpacing.md,
                      right: AppSpacing.md,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.location_on_rounded, size: 16),
                        label: const Text('Change Location'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: surfaceColor,
                          foregroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Save Draft'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vehicle added successfully!'),
                          ),
                        );
                        context.pop();
                      },
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Next Step'),
                      iconAlignment: IconAlignment.end,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
