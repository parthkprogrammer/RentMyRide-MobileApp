import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rentmyride/model/user_model.dart';
import 'package:rentmyride/model/vehicle_model.dart';
import 'package:rentmyride/service/notification_service.dart';
import 'package:rentmyride/service/user_service.dart';
import 'package:rentmyride/service/vehicle_service.dart';
import 'package:rentmyride/theme.dart';
import 'package:rentmyride/utils/image_source_resolver.dart';

part '../../widget/owner/add_vehicle_widgets.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _depositController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  static const List<String> _categories = [
    'Cars',
    'SUVs',
    'Bikes',
    'Electric',
    'Sports',
  ];
  static const List<String> _fuelTypes = [
    'Petrol',
    'Diesel',
    'Electric',
    'Hybrid',
    'CNG',
  ];
  static const List<String> _transmissions = ['Automatic', 'Manual'];
  static const List<int> _seatOptions = [2, 4, 5, 6, 7, 8];
  static const List<String> _documentOptions = [
    'RC Document',
    'Insurance Policy',
    'PUC Certificate',
    'Fitness Certificate',
  ];
  static const List<String> _fallbackLocations = [
    'San Francisco, CA',
    'Los Angeles, CA',
    'San Diego, CA',
  ];
  String _selectedCategory = _categories.first;
  String _selectedFuelType = _fuelTypes.first;
  String _selectedTransmission = _transmissions.first;
  int _selectedSeats = 5;
  String _selectedLocation = _fallbackLocations.first;
  final Set<String> _selectedDocuments = {'RC Document', 'Insurance Policy'};
  final List<String> _selectedImages = [];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _depositController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String?> _pickImageFromGalleryAsDataUri() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 72,
        maxWidth: 1440,
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
      _showSnack('Unable to access gallery. Please try again.');
      return null;
    }
  }

  Widget _twoColumnLayout({
    required Widget left,
    required Widget right,
  }) {
    final isWide = MediaQuery.of(context).size.width >= 760;
    if (isWide) {
      return Row(
        children: [
          Expanded(child: left),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: right),
        ],
      );
    }
    return Column(
      children: [
        left,
        const SizedBox(height: AppSpacing.md),
        right,
      ],
    );
  }

  Future<void> _showImagePickerSheet() async {
    if (_selectedImages.length >= 8) {
      _showSnack('You can upload up to 8 vehicle images.');
      return;
    }

    final shouldBrowse = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Upload Vehicle Image',
                style: sheetContext.textStyles.titleLarge?.copyWith(
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

    if (shouldBrowse != true) return;
    final selected = await _pickImageFromGalleryAsDataUri();
    if (selected == null || !mounted) return;
    setState(() => _selectedImages.add(selected));
  }

  Future<void> _showLocationPicker(List<String> options) async {
    var selectedLocation = _selectedLocation;
    final customLocationController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.md,
              bottom:
                  MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Change Pickup Location',
                  style: context.textStyles.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...options.map(
                  (location) => RadioListTile<String>(
                    value: location,
                    groupValue: selectedLocation,
                    title: Text(location),
                    onChanged: (value) {
                      if (value == null) return;
                      setSheetState(() => selectedLocation = value);
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: customLocationController,
                  decoration: const InputDecoration(
                    labelText: 'Add custom location',
                    prefixIcon: Icon(Icons.edit_location_alt_outlined),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: () {
                    final custom = customLocationController.text.trim();
                    final nextLocation =
                        custom.isNotEmpty ? custom : selectedLocation;
                    if (nextLocation.isEmpty) {
                      Navigator.pop(sheetContext);
                      return;
                    }
                    setState(() => _selectedLocation = nextLocation);
                    Navigator.pop(sheetContext);
                  },
                  child: const Text('Use this location'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    customLocationController.dispose();
  }

  void _saveDraft() {
    _showSnack('Vehicle draft saved locally (mock).');
  }

  Future<void> _submitForApproval() async {
    final vehicleService = context.read<VehicleService>();
    final userService = context.read<UserService>();
    final notificationService = context.read<NotificationService>();

    if (!_formKey.currentState!.validate()) return;

    if (_selectedImages.isEmpty) {
      _showSnack('Upload at least one vehicle image.');
      return;
    }
    if (!_selectedDocuments.contains('RC Document') ||
        !_selectedDocuments.contains('Insurance Policy')) {
      _showSnack('RC Document and Insurance Policy are required.');
      return;
    }

    final owner = context.read<UserService>().currentUser;
    if (owner == null || owner.role != UserRole.owner) {
      _showSnack('Owner session not found. Please login again.');
      return;
    }

    final pricePerDay = double.tryParse(_priceController.text.trim());
    final securityDeposit = double.tryParse(_depositController.text.trim());
    if (pricePerDay == null || pricePerDay <= 0) {
      _showSnack('Enter a valid daily price.');
      return;
    }
    if (securityDeposit == null || securityDeposit < 0) {
      _showSnack('Enter a valid security deposit.');
      return;
    }

    final now = DateTime.now();
    final vehicle = VehicleModel(
      id: 'pending-${now.microsecondsSinceEpoch}',
      name: _nameController.text.trim(),
      ownerId: owner.id,
      category: _selectedCategory,
      imageUrl: _selectedImages.first,
      additionalImages:
          _selectedImages.length > 1 ? _selectedImages.sublist(1) : const [],
      pricePerDay: pricePerDay,
      rating: 0,
      reviewCount: 0,
      fuelType: _selectedFuelType,
      transmission: _selectedTransmission,
      seats: _selectedSeats,
      location: _selectedLocation,
      description: _descriptionController.text.trim(),
      features: _selectedDocuments.toList(),
      securityDeposit: securityDeposit,
      createdAt: now,
      updatedAt: now,
    );

    await vehicleService.submitVehicleForApproval(
      vehicle: vehicle,
      ownerId: owner.id,
      documents: _selectedDocuments.toList(),
    );

    for (final admin in userService.usersByRole(UserRole.admin)) {
      await notificationService.sendToUser(
        userId: admin.id,
        title: 'Pending Vehicle Approval',
        message: '${owner.name} submitted ${vehicle.name} for admin approval.',
      );
    }

    if (!mounted) return;
    _showSnack('Vehicle submitted for approval.');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final vehicleService = context.watch<VehicleService>();
    final locationOptions = <String>{
      ..._fallbackLocations,
      ...vehicleService.vehicles.map((entry) => entry.location),
    }.toList()
      ..sort();
    if (!locationOptions.contains(_selectedLocation)) {
      _selectedLocation = locationOptions.first;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Form(
            key: _formKey,
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
                      child: StepIndicator(
                        number: '1',
                        isActive: true,
                        isCompleted: true,
                      ),
                    ),
                    Expanded(
                      child: StepIndicator(
                        number: '2',
                        isActive: true,
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
                          color: isDark
                              ? AppColors.darkDivider
                              : AppColors.lightDivider,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '3',
                          style: context.textStyles.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                FormLabel(label: 'Vehicle Photos'),
                Text(
                  'Add one or more images using Upload.',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    ..._selectedImages.map(
                      (asset) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: Image(
                              image: imageProviderWithFallback(asset),
                              width: 136,
                              height: 96,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Material(
                              color: Colors.black.withValues(alpha: 0.55),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () {
                                  setState(() => _selectedImages.remove(asset));
                                },
                                child: const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      onTap: _showImagePickerSheet,
                      child: Container(
                        width: 136,
                        height: 96,
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkDivider
                                : AppColors.lightDivider,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_rounded),
                            SizedBox(height: 6),
                            Text('Upload'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                FormLabel(label: 'Vehicle Name'),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Tesla Model 3 2023',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vehicle name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _twoColumnLayout(
                  left: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormLabel(label: 'Category'),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        items: _categories
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _selectedCategory = value);
                        },
                      ),
                    ],
                  ),
                  right: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormLabel(label: 'Fuel Type'),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedFuelType,
                        items: _fuelTypes
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _selectedFuelType = value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _twoColumnLayout(
                  left: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormLabel(label: 'Transmission'),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedTransmission,
                        items: _transmissions
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _selectedTransmission = value);
                        },
                      ),
                    ],
                  ),
                  right: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormLabel(label: 'Seats'),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedSeats,
                        items: _seatOptions
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text('$value'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _selectedSeats = value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _twoColumnLayout(
                  left: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormLabel(label: 'Price per Day'),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. 99.00',
                          prefixText: '\$ ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          final parsed = double.tryParse(value?.trim() ?? '');
                          if (parsed == null || parsed <= 0) {
                            return 'Enter valid amount';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  right: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormLabel(label: 'Security Deposit'),
                      TextFormField(
                        controller: _depositController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. 500.00',
                          prefixText: '\$ ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          final parsed = double.tryParse(value?.trim() ?? '');
                          if (parsed == null || parsed < 0) {
                            return 'Enter valid amount';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pickup Location',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showLocationPicker(locationOptions),
                      icon: const Icon(Icons.location_on_rounded, size: 16),
                      label: const Text('Change Location'),
                    ),
                  ],
                ),
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
                  child: Text(_selectedLocation),
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
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Verified Documents',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _documentOptions
                      .map(
                        (doc) => FilterChip(
                          label: Text(doc),
                          selected: _selectedDocuments.contains(doc),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedDocuments.add(doc);
                              } else {
                                _selectedDocuments.remove(doc);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                FormLabel(label: 'Description'),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Mention key features and pickup notes.',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 10) {
                      return 'Add a short description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                _twoColumnLayout(
                  left: OutlinedButton(
                    onPressed: _saveDraft,
                    child: const Text('Save Draft'),
                  ),
                  right: ElevatedButton.icon(
                    onPressed: _submitForApproval,
                    icon: const Icon(Icons.upload_file_rounded),
                    label: const Text('Submit for Approval'),
                    iconAlignment: IconAlignment.end,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
