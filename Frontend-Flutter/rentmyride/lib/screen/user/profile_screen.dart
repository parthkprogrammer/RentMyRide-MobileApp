import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rentmyride/model/payment_method_model.dart';
import 'package:rentmyride/model/user_model.dart';
import 'package:rentmyride/service/booking_service.dart';
import 'package:rentmyride/service/theme_service.dart';
import 'package:rentmyride/service/user_service.dart';
import 'package:rentmyride/service/vehicle_service.dart';
import 'package:rentmyride/theme.dart';
import 'package:rentmyride/utils/image_source_resolver.dart';

part '../../widget/user/profile_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final accentColor =
        isDark ? AppColors.darkAccent : AppColors.lightSecondary;
    final successColor =
        isDark ? AppColors.darkSuccess : AppColors.lightSuccess;

    final userService = context.watch<UserService>();
    final vehicleService = context.watch<VehicleService>();
    final bookingService = context.watch<BookingService>();
    final themeService = context.watch<ThemeService>();
    final user = userService.currentUser;
    final imagePicker = ImagePicker();

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_off_rounded, size: 44),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'No active profile',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bookings = bookingService.getBookingsByUser(user.id)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final favoriteVehicles = userService.favoriteVehicleIdsForCurrentUser
        .map(vehicleService.getVehicleById)
        .whereType()
        .toList();
    final paymentMethods = userService.currentUserPaymentMethods;
    ImageProvider<Object>? resolveProfileImage(String? path) {
      final value = path?.trim() ?? '';
      if (value.isEmpty) return null;
      if (value.startsWith('http://') || value.startsWith('https://')) {
        return NetworkImage(value);
      }
      if (value.startsWith('assets/')) {
        return AssetImage(value);
      }
      if (value.startsWith('data:image/')) {
        final commaIndex = value.indexOf(',');
        if (commaIndex == -1) return null;
        try {
          final bytes = base64Decode(value.substring(commaIndex + 1));
          return MemoryImage(bytes);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    Future<String?> pickImageFromGalleryAsDataUri() async {
      try {
        final picked = await imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
          maxWidth: 1080,
        );
        if (picked == null) return null;
        final bytes = await picked.readAsBytes();
        if (bytes.isEmpty) return null;
        final fileName = picked.name.toLowerCase();
        final mimeType = fileName.endsWith('.png')
            ? 'image/png'
            : fileName.endsWith('.webp')
                ? 'image/webp'
                : 'image/jpeg';
        return 'data:$mimeType;base64,${base64Encode(bytes)}';
      } catch (_) {
        if (!context.mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to access gallery. Please try again.'),
          ),
        );
        return null;
      }
    }

    Future<bool> ensureLicenseVerified() async {
      final latestUser = context.read<UserService>().currentUser;
      if (latestUser?.isVerified ?? false) return true;
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete driving license verification first.'),
        ),
      );
      return false;
    }

    Future<void> openAddPaymentMethodSheet() async {
      if (!await ensureLicenseVerified()) return;
      if (!context.mounted) return;
      final latestUser = context.read<UserService>().currentUser ?? user;
      final formKey = GlobalKey<FormState>();
      final holderController = TextEditingController(text: latestUser.name);
      final last4Controller = TextEditingController();
      final expiryController = TextEditingController(text: '12/29');
      var selectedBrand = 'Visa';

      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (sheetContext) {
          final maxHeight = MediaQuery.of(sheetContext).size.height * 0.88;
          return SafeArea(
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
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
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Add Payment Method',
                          style: sheetContext.textStyles.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DropdownButtonFormField<String>(
                          initialValue: selectedBrand,
                          items: const [
                            DropdownMenuItem(
                                value: 'Visa', child: Text('Visa')),
                            DropdownMenuItem(
                              value: 'Mastercard',
                              child: Text('Mastercard'),
                            ),
                            DropdownMenuItem(
                              value: 'Amex',
                              child: Text('American Express'),
                            ),
                          ],
                          onChanged: (value) => selectedBrand = value ?? 'Visa',
                          decoration:
                              const InputDecoration(labelText: 'Card Brand'),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: holderController,
                          decoration:
                              const InputDecoration(labelText: 'Card Holder'),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: last4Controller,
                          maxLength: 4,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Last 4 Digits'),
                          validator: (value) {
                            final cleaned = value?.trim() ?? '';
                            if (cleaned.length != 4) return 'Enter 4 digits';
                            if (int.tryParse(cleaned) == null) {
                              return 'Digits only';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: expiryController,
                          decoration: const InputDecoration(
                              labelText: 'Expiry (MM/YY)'),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            await sheetContext
                                .read<UserService>()
                                .addPaymentMethod(
                                  PaymentMethodModel(
                                    id: 'pm-${DateTime.now().microsecondsSinceEpoch}',
                                    brand: selectedBrand,
                                    holderName: holderController.text.trim(),
                                    last4: last4Controller.text.trim(),
                                    expiry: expiryController.text.trim(),
                                    isDefault: paymentMethods.isEmpty,
                                    createdAt: DateTime.now(),
                                  ),
                                );
                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                          },
                          child: const Text('Save Method'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    Future<void> openProfilePhotoSheet() async {
      final shouldBrowse = await showModalBottomSheet<bool>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Update Profile Image',
                  style: sheetContext.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Choose an image from your phone gallery.',
                  style: sheetContext.textStyles.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(sheetContext, true),
                  icon: const Icon(Icons.photo_library_rounded),
                  label: const Text('Browse Gallery'),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext, false),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      );

      if (shouldBrowse != true || !context.mounted) {
        return;
      }
      final selectedAsset = await pickImageFromGalleryAsDataUri();
      if (selectedAsset == null || !context.mounted) return;
      final userService = context.read<UserService>();
      final latestUser = userService.currentUser ?? user;
      await userService.updateUser(
        latestUser.copyWith(
          photoUrl: selectedAsset,
          updatedAt: DateTime.now(),
        ),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated')),
      );
    }

    Future<void> openLicenseVerificationSheet() async {
      final wasAlreadyVerified = user.isVerified;
      final didSubmit = await showModalBottomSheet<bool>(
        context: context,
        showDragHandle: true,
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        builder: (_) => _LicenseVerificationSheet(initialUser: user),
      );

      if (!context.mounted || didSubmit != true) return;
      final isNowVerified =
          context.read<UserService>().currentUser?.isVerified ?? false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !isNowVerified
                ? 'Verification not completed'
                : (wasAlreadyVerified
                    ? 'License details updated'
                    : 'Driving license verification completed'),
          ),
        ),
      );
    }

    final profileImageProvider = resolveProfileImage(user.photoUrl);
    final hasProfilePhoto = profileImageProvider != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/user-dashboard');
            }
          },
        ),
        title: const Text('Profile'),
      ),
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
                          backgroundImage: profileImageProvider,
                          child: hasProfilePhoto
                              ? null
                              : Icon(Icons.person,
                                  size: 50, color: primaryColor),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Material(
                            color: primaryColor,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: openProfilePhotoSheet,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkBackground
                                        : AppColors.lightBackground,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.photo_library_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
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
                          user.name,
                          style: context.textStyles.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          user.isVerified
                              ? Icons.verified_rounded
                              : Icons.pending_actions_rounded,
                          color: user.isVerified
                              ? accentColor
                              : (isDark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.lightSecondaryText),
                          size: 20,
                        ),
                      ],
                    ),
                    Text(
                      user.email,
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: isDark
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
                    Expanded(
                      child: StatCard(
                        value: '${bookings.length}',
                        label: 'Bookings',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: StatCard(
                        value: user.rating?.toStringAsFixed(1) ?? '4.8',
                        label: 'Rating',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: StatCard(
                        value:
                            '${DateTime.now().difference(user.createdAt).inDays ~/ 365}y',
                        label: 'Member',
                      ),
                    ),
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
                  child: Column(
                    children: [
                      Row(
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
                                  user.isVerified
                                      ? 'Verified account holder'
                                      : 'Verification pending - complete to use booking and payment',
                                  style: context.textStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            user.isVerified
                                ? Icons.check_circle_rounded
                                : Icons.pending_actions_rounded,
                            color: user.isVerified ? successColor : accentColor,
                            size: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: openLicenseVerificationSheet,
                          icon: const Icon(Icons.upload_file_rounded, size: 16),
                          label: Text(
                            user.isVerified ? 'Update License' : 'Complete Now',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!user.isVerified)
                Padding(
                  padding: AppSpacing.horizontalLg,
                  child: Container(
                    margin: const EdgeInsets.only(top: AppSpacing.sm),
                    padding: AppSpacing.paddingMd,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      color: const Color(0xFFFFFBEB),
                      border: Border.all(color: const Color(0xFFFCD34D)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Please verify your driving license to continue using key features.',
                            style: context.textStyles.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: AppSpacing.horizontalLg,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Booking History',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${bookings.length} total',
                      style: context.textStyles.labelMedium?.copyWith(
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (bookings.isEmpty)
                Padding(
                  padding: AppSpacing.horizontalLg,
                  child: const ProfileSectionEmptyState(
                    title: 'No bookings yet',
                    subtitle: 'Your confirmed trips will appear here.',
                  ),
                )
              else
                Padding(
                  padding: AppSpacing.horizontalLg,
                  child: Column(
                    children: bookings
                        .take(4)
                        .map(
                          (booking) => BookingHistoryCard(
                            bookingId: booking.id,
                            vehicleName: vehicleService
                                    .getVehicleById(booking.vehicleId)
                                    ?.name ??
                                'Vehicle',
                            dateRange:
                                '${DateFormat('dd MMM').format(booking.pickupDate)} - ${DateFormat('dd MMM yyyy').format(booking.returnDate)}',
                            amount:
                                '\$${booking.totalAmount.toStringAsFixed(2)}',
                            status: booking.status.name.toUpperCase(),
                          ),
                        )
                        .toList(),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: AppSpacing.horizontalLg,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Favorites',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${favoriteVehicles.length} saved',
                      style: context.textStyles.labelMedium?.copyWith(
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (favoriteVehicles.isEmpty)
                Padding(
                  padding: AppSpacing.horizontalLg,
                  child: const ProfileSectionEmptyState(
                    title: 'No favorites yet',
                    subtitle: 'Tap the heart on a vehicle to save it here.',
                  ),
                )
              else
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    padding: AppSpacing.horizontalLg,
                    scrollDirection: Axis.horizontal,
                    itemCount: favoriteVehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = favoriteVehicles[index];
                      return FavoriteVehicleCard(
                        vehicleName: vehicle.name,
                        imagePath: vehicle.imageUrl,
                        priceText:
                            '\$${vehicle.pricePerDay.toStringAsFixed(0)}/day',
                        onTap: () => context.push('/vehicle/${vehicle.id}'),
                      );
                    },
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: AppSpacing.horizontalLg,
                child: Text(
                  'Payment Methods',
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
                    ...paymentMethods.map(
                      (method) => PaymentMethodTile(
                        method: method,
                        onSetDefault: () => context
                            .read<UserService>()
                            .setDefaultPaymentMethod(method.id),
                        onDelete: () => context
                            .read<UserService>()
                            .removePaymentMethod(method.id),
                      ),
                    ),
                    ProfileMenuItem(
                      icon: Icons.add_card_rounded,
                      title: 'Add Payment Method',
                      subtitle: 'Save another card for quick checkout',
                      onTap: openAddPaymentMethodSheet,
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
                              color: isDark
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
                            value: themeService.isDarkModeForRole('user'),
                            onChanged: (enabled) => context
                                .read<ThemeService>()
                                .toggleDarkModeForRole('user', enabled),
                            activeThumbColor: primaryColor,
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
                  children: [
                    ProfileMenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Help Center',
                      subtitle: '',
                      onTap: () => context.push('/help-center'),
                    ),
                    ProfileMenuItem(
                      icon: Icons.shield_outlined,
                      title: 'Privacy Policy',
                      subtitle: '',
                      onTap: () => context.push('/privacy-policy'),
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
                          color: isDark
                              ? AppColors.darkError
                              : AppColors.lightError,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Logout',
                          style: context.textStyles.bodyLarge?.copyWith(
                            color: isDark
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

class _LicenseVerificationSheet extends StatefulWidget {
  final UserModel initialUser;

  const _LicenseVerificationSheet({required this.initialUser});

  @override
  State<_LicenseVerificationSheet> createState() =>
      _LicenseVerificationSheetState();
}

class _LicenseVerificationSheetState extends State<_LicenseVerificationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _licenseController = TextEditingController();
  final _imagePicker = ImagePicker();

  String? _selectedDocDataUri;
  bool _isPicking = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _licenseController.dispose();
    super.dispose();
  }

  Future<String?> _pickImageFromGalleryAsDataUri() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1080,
      );
      if (picked == null) return null;
      final bytes = await picked.readAsBytes();
      if (bytes.isEmpty) return null;

      final fileName = picked.name.toLowerCase();
      final mimeType = fileName.endsWith('.png')
          ? 'image/png'
          : fileName.endsWith('.webp')
              ? 'image/webp'
              : 'image/jpeg';
      return 'data:$mimeType;base64,${base64Encode(bytes)}';
    } catch (_) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to access gallery. Please try again.'),
        ),
      );
      return null;
    }
  }

  Future<void> _onUploadPressed() async {
    if (_isPicking || _isSubmitting) return;
    setState(() => _isPicking = true);
    final picked = await _pickImageFromGalleryAsDataUri();
    if (!mounted) return;
    setState(() {
      _isPicking = false;
      if (picked != null) {
        _selectedDocDataUri = picked;
      }
    });
  }

  Future<void> _onCompletePressed() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDocDataUri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload your license document from gallery.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final userService = context.read<UserService>();
    final latestUser = userService.currentUser ?? widget.initialUser;
    await userService.updateUser(
      latestUser.copyWith(
        isVerified: true,
        updatedAt: DateTime.now(),
        photoUrl: latestUser.photoUrl ?? _selectedDocDataUri,
      ),
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final previewProvider = imageProviderFromSource(_selectedDocDataUri);
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
                    'Driving License Verification',
                    style: context.textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Complete this step to use booking and payment features.',
                    style: context.textStyles.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _licenseController,
                    decoration: const InputDecoration(
                      labelText: 'Driving License Number',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().length < 6)
                            ? 'Enter valid license number'
                            : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: _isSubmitting ? null : _onUploadPressed,
                    icon: _isPicking
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload_file_rounded),
                    label: Text(
                      _selectedDocDataUri == null
                          ? 'Upload License from Gallery'
                          : 'Replace Uploaded Document',
                    ),
                  ),
                  if (previewProvider != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Image(
                        image: previewProvider,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
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
                          onPressed: _isSubmitting ? null : _onCompletePressed,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.verified_user_rounded),
                          label: const Text('Complete Verification'),
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
