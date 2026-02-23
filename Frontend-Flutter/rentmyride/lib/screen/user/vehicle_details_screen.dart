import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rentmyride/service/admin_service.dart';
import 'package:rentmyride/service/user_service.dart';
import 'package:rentmyride/service/vehicle_service.dart';
import 'package:rentmyride/theme.dart';
import 'package:rentmyride/utils/image_source_resolver.dart';

part '../../widget/user/vehicle_details_widgets.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final String vehicleId;

  const VehicleDetailsScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    final vehicleService = context.watch<VehicleService>();
    final userService = context.watch<UserService>();
    final vehicle = vehicleService.getVehicleById(vehicleId);
    if (vehicle == null) {
      return const Scaffold(body: Center(child: Text('Vehicle not found')));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final owner = userService.getUserById(vehicle.ownerId);
    final reviews = vehicleService.getReviewsForVehicle(vehicle.id);
    final isFavorite = userService.isFavorite(vehicle.id);
    final bottomInset = MediaQuery.of(context).padding.bottom + 120;

    Future<void> onSharePressed() async {
      final shareText =
          '${vehicle.name} at \$${vehicle.pricePerDay.toStringAsFixed(0)}/day in ${vehicle.location}';
      await Clipboard.setData(ClipboardData(text: shareText));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle details copied to clipboard')),
        );
      }
    }

    Future<void> onReportVehicle() async {
      final didSubmit = await showModalBottomSheet<bool>(
        context: context,
        showDragHandle: true,
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        builder: (_) => _VehicleReportSheet(
          vehicleId: vehicle.id,
          vehicleLabel: vehicle.name,
        ),
      );

      if (!context.mounted || didSubmit != true) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle reported to admin')),
      );
    }

    return Scaffold(
      bottomNavigationBar: Container(
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Starting from',
                    style: context.textStyles.labelSmall?.copyWith(
                      color: isDark
                          ? AppColors.darkSecondaryText
                          : AppColors.lightSecondaryText,
                    ),
                  ),
                  Text(
                    '\$${vehicle.pricePerDay.toStringAsFixed(0)}/day',
                    style: context.textStyles.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push('/booking/${vehicle.id}'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  child: const Text('Book Now'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  Image(
                    image: imageProviderWithFallback(vehicle.imageUrl),
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: AppSpacing.md,
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RoundActionIcon(
                          icon: Icons.arrow_back_rounded,
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/user-dashboard');
                            }
                          },
                        ),
                        Row(
                          children: [
                            RoundActionIcon(
                              icon: isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              iconColor: isFavorite
                                  ? (isDark
                                      ? AppColors.darkError
                                      : AppColors.lightError)
                                  : null,
                              onTap: () => context
                                  .read<UserService>()
                                  .toggleFavorite(vehicle.id),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            RoundActionIcon(
                              icon: Icons.share_rounded,
                              onTap: onSharePressed,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            RoundActionIcon(
                              icon: Icons.flag_outlined,
                              onTap: onReportVehicle,
                            ),
                          ],
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
                                style:
                                    context.textStyles.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFF59E0B),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${vehicle.rating}',
                                    style:
                                        context.textStyles.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${vehicle.reviewCount} reviews)',
                                    style:
                                        context.textStyles.bodyMedium?.copyWith(
                                      color: isDark
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
                              vehicle.category,
                              style: context.textStyles.labelLarge?.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              vehicle.location,
                              style: context.textStyles.labelSmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
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
                            value: '${vehicle.seats}',
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
                        color: isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: vehicle.features
                          .map((item) => FeatureChip(label: item))
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: AppSpacing.paddingMd,
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkDivider
                              : AppColors.lightDivider,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            child: Text(
                              (owner?.name ?? 'O')
                                  .substring(0, 1)
                                  .toUpperCase(),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  owner?.name ?? 'Owner',
                                  style: context.textStyles.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Verified owner - Fast response',
                                  style:
                                      context.textStyles.labelSmall?.copyWith(
                                    color: isDark
                                        ? AppColors.darkSecondaryText
                                        : AppColors.lightSecondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () =>
                                context.push('/chat/${vehicle.id}'),
                            icon: const Icon(Icons.chat_bubble_outline_rounded,
                                size: 16),
                            label: const Text('Chat'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Chat with owner',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ChatPreviewCard(
                      ownerName: owner?.name ?? 'Owner',
                      subtitle: 'Ask for pickup details, timing, and docs.',
                      onOpenChat: () => context.push('/chat/${vehicle.id}'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Pickup location',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: isDark
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          vehicle.location,
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.darkSecondaryText
                                : AppColors.lightSecondaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkDivider
                              : AppColors.lightDivider,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.asset(
                            'assets/images/minimal_city_map_with_pin_null_1771667574634.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Reviews',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (reviews.isEmpty)
                      const VehicleSectionEmptyState(
                        title: 'No reviews yet',
                        subtitle:
                            'This vehicle will show reviews after first bookings.',
                      )
                    else
                      Column(
                        children: reviews
                            .map(
                              (review) => ReviewCard(
                                reviewerName: review.reviewerName,
                                rating: review.rating,
                                comment: review.comment,
                                dateLabel:
                                    '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleReportSheet extends StatefulWidget {
  final String vehicleId;
  final String vehicleLabel;

  const _VehicleReportSheet({
    required this.vehicleId,
    required this.vehicleLabel,
  });

  @override
  State<_VehicleReportSheet> createState() => _VehicleReportSheetState();
}

class _VehicleReportSheetState extends State<_VehicleReportSheet> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _authorityController = TextEditingController(text: 'Road Safety Unit');
  final _contactController =
      TextEditingController(text: 'support@authority.gov');
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _authorityController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    final userService = context.read<UserService>();
    final adminService = context.read<AdminService>();
    final currentUser = userService.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login required')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await adminService.addVehicleReport(
      reportedById: currentUser.id,
      reportedByName: currentUser.name,
      vehicleId: widget.vehicleId,
      vehicleLabel: widget.vehicleLabel,
      reason: _reasonController.text.trim(),
      authorityName: _authorityController.text.trim(),
      authorityContact: _contactController.text.trim(),
      documents: const ['UserIncidentNote.txt'],
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Report Vehicle',
                    style: context.textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Share issue details for admin review.',
                    style: context.textStyles.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _reasonController,
                    maxLines: 3,
                    decoration:
                        const InputDecoration(labelText: 'Report Reason'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Required'
                            : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _authorityController,
                    decoration: const InputDecoration(labelText: 'Authority'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Required'
                            : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _contactController,
                    decoration:
                        const InputDecoration(labelText: 'Authority Contact'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Required'
                            : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _submit,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.flag_outlined),
                          label: const Text('Submit Report'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
