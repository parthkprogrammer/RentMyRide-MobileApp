import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rentmyride/model/app_notification_model.dart';
import 'package:rentmyride/model/booking_model.dart';
import 'package:rentmyride/model/vehicle_model.dart';
import 'package:rentmyride/service/booking_service.dart';
import 'package:rentmyride/service/notification_service.dart';
import 'package:rentmyride/service/user_service.dart';
import 'package:rentmyride/service/vehicle_service.dart';
import 'package:rentmyride/theme.dart';
import 'package:rentmyride/utils/image_source_resolver.dart';

part '../../widget/user/user_dashboard_widgets.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _CategoryOption {
  final String label;
  final IconData icon;

  const _CategoryOption({required this.label, required this.icon});
}

class _UserDashboardState extends State<UserDashboard> {
  static const List<_CategoryOption> _categories = [
    _CategoryOption(label: 'All', icon: Icons.apps_rounded),
    _CategoryOption(label: 'Cars', icon: Icons.directions_car_rounded),
    _CategoryOption(label: 'Electric', icon: Icons.electric_car_rounded),
    _CategoryOption(label: 'Sports', icon: Icons.sports_score_rounded),
    _CategoryOption(label: 'Bikes', icon: Icons.electric_bike_rounded),
    _CategoryOption(label: 'SUVs', icon: Icons.airport_shuttle_rounded),
  ];

  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';
  String _selectedSort = 'Recommended';
  String _searchQuery = '';
  bool _availableOnly = false;
  String? _locationFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isBikeCategory(String value) {
    final normalized = value.toLowerCase();
    return normalized.contains('bike') ||
        normalized.contains('motorcycle') ||
        normalized.contains('scooter');
  }

  bool _matchesCategory(VehicleModel vehicle) {
    final normalized = vehicle.category.toLowerCase();
    switch (_selectedCategory) {
      case 'All':
        return true;
      case 'Cars':
        return normalized == 'car' ||
            normalized == 'cars' ||
            normalized == 'sedan' ||
            normalized == 'hatchback' ||
            normalized == 'coupe';
      case 'SUVs':
        return normalized == 'suv' || normalized == 'suvs';
      case 'Bikes':
        return _isBikeCategory(normalized);
      default:
        return normalized == _selectedCategory.toLowerCase();
    }
  }

  List<VehicleModel> _vehiclesForMap(List<VehicleModel> vehicles) {
    final query = _searchQuery.trim().toLowerCase();

    return vehicles.where((vehicle) {
      if (_availableOnly && !vehicle.isAvailable) return false;
      if (!_matchesCategory(vehicle)) return false;
      if (query.isEmpty) return true;

      final searchable = [
        vehicle.name,
        vehicle.category,
        vehicle.fuelType,
        vehicle.location,
      ].join(' ').toLowerCase();

      return searchable.contains(query);
    }).toList();
  }

  List<VehicleModel> _visibleVehicles(List<VehicleModel> vehicles) {
    final filtered = _vehiclesForMap(vehicles).where((vehicle) {
      if (_locationFilter == null) return true;
      return vehicle.location == _locationFilter;
    }).toList();

    filtered.sort((a, b) {
      switch (_selectedSort) {
        case 'Price: Low to High':
          return a.pricePerDay.compareTo(b.pricePerDay);
        case 'Price: High to Low':
          return b.pricePerDay.compareTo(a.pricePerDay);
        case 'Top Rated':
          return b.rating.compareTo(a.rating);
        case 'Newest':
          return b.createdAt.compareTo(a.createdAt);
        case 'Recommended':
        default:
          final rating = b.rating.compareTo(a.rating);
          if (rating != 0) return rating;
          return b.reviewCount.compareTo(a.reviewCount);
      }
    });

    return filtered;
  }

  void _showNotificationsSheet(BuildContext context) {
    final user = context.read<UserService>().currentUser;
    if (user == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorColor = isDark ? AppColors.darkError : AppColors.lightError;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.lightDivider;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.8,
          ),
          child: Consumer<NotificationService>(
            builder: (context, notificationService, _) {
              final notifications =
                  notificationService.notificationsForUser(user.id);
              return SingleChildScrollView(
                padding: AppSpacing.paddingLg,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Notifications',
                          style: sheetContext.textStyles.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () async =>
                              notificationService.markAllRead(user.id),
                          child: const Text('Mark all read'),
                        ),
                      ],
                    ),
                    if (notifications.isEmpty)
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.notifications_off_outlined),
                        title: Text('No notifications'),
                        subtitle:
                            Text('Broadcasts and booking updates will appear here.'),
                      )
                    else
                      ...notifications.map((item) {
                        final isEmergency =
                            item.type == AppNotificationType.emergency;
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: isEmergency
                                ? errorColor.withValues(alpha: 0.1)
                                : null,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: isEmergency
                                ? Border.all(
                                    color: errorColor.withValues(alpha: 0.45),
                                  )
                                : Border.all(color: dividerColor),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            leading: Icon(
                              isEmergency
                                  ? Icons.warning_amber_rounded
                                  : (item.isRead
                                      ? Icons.notifications_none_rounded
                                      : Icons.notifications_active_rounded),
                              color: isEmergency ? errorColor : null,
                            ),
                            title: Text(item.title),
                            subtitle: Text(item.message),
                            trailing: isEmergency
                                ? Text(
                                    'ALERT',
                                    style:
                                        sheetContext.textStyles.labelSmall?.copyWith(
                                      color: errorColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Text(
                                    '${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}',
                                  ),
                            onTap: () => notificationService.markRead(
                              userId: user.id,
                              notificationId: item.id,
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showProfileSheet(BuildContext context) {
    final user = context.read<UserService>().currentUser;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 28,
                child: Text(
                  (user?.name ?? 'U').substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                user?.name ?? 'Guest User',
                style: sheetContext.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(user?.email ?? ''),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                leading: const Icon(Icons.person_outline_rounded),
                title: const Text('Open Profile'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  if (!mounted) return;
                  this.context.push('/profile');
                },
              ),
              ListTile(
                leading: const Icon(Icons.book_online_rounded),
                title: const Text('My Bookings'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  if (!mounted) return;
                  final currentUser = this.context.read<UserService>().currentUser;
                  if (currentUser == null) return;
                  final activeOrConfirmed = this
                      .context
                      .read<BookingService>()
                      .getBookingsByUser(currentUser.id)
                      .where(
                        (booking) =>
                            booking.status == BookingStatus.confirmed ||
                            booking.status == BookingStatus.active,
                      )
                      .toList()
                    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  final vehicles = this.context.read<VehicleService>().vehicles;
                  final targetVehicleId = activeOrConfirmed.isNotEmpty
                      ? activeOrConfirmed.first.vehicleId
                      : (vehicles.isNotEmpty ? vehicles.first.id : null);
                  if (targetVehicleId == null) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(content: Text('No vehicles available')),
                    );
                    return;
                  }
                  this.context.push('/booking/$targetVehicleId');
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  if (!mounted) return;
                  this.context.read<UserService>().logout();
                  this.context.go('/');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: StatefulBuilder(
          builder: (sheetContext, setSheetState) => Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Quick Settings',
                      style: sheetContext.textStyles.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        if (!mounted) return;
                        setState(() {
                          _selectedCategory = 'All';
                          _selectedSort = 'Recommended';
                          _availableOnly = false;
                          _locationFilter = null;
                          _searchQuery = '';
                          _searchController.clear();
                        });
                        setSheetState(() {});
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _availableOnly,
                  title: const Text('Show available only'),
                  onChanged: (value) {
                    if (!mounted) return;
                    setState(() => _availableOnly = value);
                    setSheetState(() {});
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.sort_rounded),
                  title: const Text('Sort rides'),
                  subtitle: Text(_selectedSort),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    if (!mounted) return;
                    _showFilterSheet(this.context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    const sortOptions = [
      'Recommended',
      'Price: Low to High',
      'Price: High to Low',
      'Top Rated',
      'Newest',
    ];

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: StatefulBuilder(
          builder: (sheetContext, setSheetState) => Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Filter & Sort',
                      style: sheetContext.textStyles.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        if (!mounted) return;
                        setState(() {
                          _selectedSort = 'Recommended';
                          _availableOnly = false;
                        });
                        setSheetState(() {});
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _availableOnly,
                  title: const Text('Available only'),
                  onChanged: (value) {
                    if (!mounted) return;
                    setState(() => _availableOnly = value);
                    setSheetState(() {});
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sort by',
                    style: sheetContext.textStyles.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  initialValue: _selectedSort,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  items: sortOptions
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    if (!mounted) return;
                    setState(() => _selectedSort = value);
                    setSheetState(() {});
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMapSheet(BuildContext context, List<VehicleModel> vehiclesForMap) {
    final locations = <String, int>{};
    for (final vehicle in vehiclesForMap) {
      locations.update(vehicle.location, (value) => value + 1,
          ifAbsent: () => 1);
    }

    final sortedLocations = locations.keys.toList()..sort();

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: StatefulBuilder(
          builder: (sheetContext, setSheetState) => Padding(
            padding: AppSpacing.paddingLg,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ride Locations',
                    style: sheetContext.textStyles.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: Image.asset(
                      'assets/images/minimal_city_map_with_pin_null_1771667574634.png',
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      ChoiceChip(
                        label: Text('All (${vehiclesForMap.length})'),
                        selected: _locationFilter == null,
                        onSelected: (_) {
                          if (!mounted) return;
                          setState(() => _locationFilter = null);
                          setSheetState(() {});
                        },
                      ),
                      ...sortedLocations.map(
                        (location) => ChoiceChip(
                          label: Text('$location (${locations[location]})'),
                          selected: _locationFilter == location,
                          onSelected: (_) {
                            if (!mounted) return;
                            setState(() => _locationFilter = location);
                            setSheetState(() {});
                          },
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final hintColor = isDark ? AppColors.darkHint : AppColors.lightHint;

    final vehicles = context.watch<VehicleService>().vehicles;
    final currentUser = context.watch<UserService>().currentUser;
    final unreadNotificationCount = currentUser == null
        ? 0
        : context
            .watch<NotificationService>()
            .unreadCountForUser(currentUser.id);
    final vehiclesForMap = _vehiclesForMap(vehicles);
    final visibleVehicles = _visibleVehicles(vehicles);
    final locationText = _locationFilter ?? 'All Locations';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            onTap: () => _showMapSheet(context, vehiclesForMap),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Location',
                                  style:
                                      context.textStyles.labelSmall?.copyWith(
                                    color: isDark
                                        ? AppColors.darkSecondaryText
                                        : AppColors.lightSecondaryText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      color: primaryColor,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        locationText,
                                        style: context.textStyles.bodyLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: isDark
                                          ? AppColors.darkSecondaryText
                                          : AppColors.lightSecondaryText,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        DashboardActionButton(
                          icon: Icons.notifications_none_rounded,
                          badgeCount: unreadNotificationCount,
                          onTap: () => _showNotificationsSheet(context),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        DashboardActionButton(
                          icon: Icons.person_outline_rounded,
                          onTap: () => _showProfileSheet(context),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        DashboardActionButton(
                          icon: Icons.settings_rounded,
                          onTap: () => _showSettingsSheet(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkDivider
                                    : AppColors.lightDivider,
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) =>
                                  setState(() => _searchQuery = value),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                icon: Icon(
                                  Icons.search_rounded,
                                  color: hintColor,
                                  size: 22,
                                ),
                                hintText: 'Search for your dream ride...',
                                hintStyle:
                                    context.textStyles.bodyMedium?.copyWith(
                                  color: hintColor,
                                ),
                                suffixIcon: _searchQuery.isEmpty
                                    ? null
                                    : IconButton(
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _searchQuery = '');
                                        },
                                        icon: Icon(
                                          Icons.close_rounded,
                                          color: hintColor,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          onTap: () => _showFilterSheet(context),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/modern_electric_car_interior_dashboard_null_1771667573700.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF1E3A8A).withValues(alpha: 0.93),
                              const Color(0xFF3B82F6).withValues(alpha: 0.4),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        padding: AppSpacing.paddingLg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkAccent
                                    : AppColors.lightSecondary,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                              ),
                              child: Text(
                                'SUMMER SALE',
                                style: context.textStyles.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Get 20% Off\nElectric Vehicles',
                              style: context.textStyles.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Valid until July 30',
                              style: context.textStyles.labelSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categories',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Showing: $_selectedCategory',
                      style: context.textStyles.labelLarge?.copyWith(
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: _categories
                      .map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.md),
                          child: CategoryChip(
                            label: category.label,
                            icon: category.icon,
                            isSelected: _selectedCategory == category.label,
                            onTap: () => setState(
                              () => _selectedCategory = category.label,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategory == 'All'
                          ? 'Featured Rides'
                          : '$_selectedCategory Rides',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showMapSheet(context, vehiclesForMap),
                      child: Text(
                        'View Map',
                        style: context.textStyles.labelLarge?.copyWith(
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (visibleVehicles.isEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: DashboardEmptyState(
                    title: 'No rides found',
                    subtitle: _selectedCategory == 'Bikes'
                        ? 'No bikes match this search right now. Try clearing filters.'
                        : 'Try changing category, location, or search text.',
                  ),
                )
              else
                SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: visibleVehicles.length,
                    itemBuilder: (context, index) => VehicleCard(
                      vehicle: visibleVehicles[index],
                    ),
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
