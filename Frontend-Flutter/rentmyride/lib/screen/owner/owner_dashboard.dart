import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rentmyride/model/booking_model.dart';
import 'package:rentmyride/service/admin_service.dart';
import 'package:rentmyride/service/booking_service.dart';
import 'package:rentmyride/service/notification_service.dart';
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
    final successColor = isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
    final userService = context.watch<UserService>();
    final owner = userService.currentUser;
    if (owner == null) {
      return const Scaffold(body: Center(child: Text('No owner session found')));
    }

    final vehicleService = context.watch<VehicleService>();
    final bookingService = context.watch<BookingService>();
    final notificationService = context.watch<NotificationService>();
    final adminService = context.watch<AdminService>();
    final vehicles = vehicleService.getVehiclesByOwner(owner.id);
    final ownerBookings = bookingService.getBookingsByOwner(owner.id)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final activeRentals = ownerBookings
        .where(
          (booking) =>
              booking.status == BookingStatus.active ||
              booking.status == BookingStatus.confirmed,
        )
        .toList();
    final reviews = vehicleService.getReviewsForOwner(owner.id);
    final totalRevenue = ownerBookings
        .where((booking) => booking.status != BookingStatus.cancelled)
        .fold<double>(0, (sum, booking) => sum + booking.totalAmount);
    final unreadCount = notificationService.unreadCountForUser(owner.id);

    Future<void> showOwnerNotifications() async {
      final notifications = notificationService.notificationsForUser(owner.id);
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Notifications',
                      style: context.textStyles.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => notificationService.markAllRead(owner.id),
                      child: const Text('Mark all read'),
                    ),
                  ],
                ),
                if (notifications.isEmpty)
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('No notifications'),
                  )
                else
                  ...notifications.map(
                    (entry) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        entry.isRead
                            ? Icons.notifications_none_rounded
                            : Icons.notifications_active_rounded,
                      ),
                      title: Text(entry.title),
                      subtitle: Text(entry.message),
                      onTap: () => notificationService.markRead(
                        userId: owner.id,
                        notificationId: entry.id,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    Future<void> addBankAccount() async {
      final controller = TextEditingController(text: userService.ownerBankAccount(owner.id));
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Add Bank Account'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Account / UPI / IBAN'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await context
                    .read<UserService>()
                    .setOwnerBankAccount(owner.id, controller.text);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
      controller.dispose();
    }

    Future<void> reportUserFromBooking(BookingModel booking) async {
      final targetUser = userService.getUserById(booking.userId);
      final reasonController = TextEditingController();
      final authorityController = TextEditingController(text: 'Damage Review Board');
      final contactController = TextEditingController(text: 'claims@authority.gov');
      final formKey = GlobalKey<FormState>();

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Report User (Damage Case)'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Reason'),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: authorityController,
                  decoration: const InputDecoration(labelText: 'Authority'),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: contactController,
                  decoration: const InputDecoration(labelText: 'Authority Contact'),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Required' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                await context.read<AdminService>().addUserReport(
                      reportedById: owner.id,
                      reportedByName: owner.name,
                      userId: booking.userId,
                      userLabel: targetUser?.name ?? 'User',
                      reason: reasonController.text.trim(),
                      authorityName: authorityController.text.trim(),
                      authorityContact: contactController.text.trim(),
                      documents: const ['DamagePhotos.zip', 'ClaimForm.pdf'],
                    );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Damage case reported to admin')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      );

      reasonController.dispose();
      authorityController.dispose();
      contactController.dispose();
    }

    Future<void> showQuickReports() async {
      final myReports = adminService.reports.where((entry) => entry.reportedById == owner.id);
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'My Reports',
                  style: context.textStyles.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (myReports.isEmpty)
                  const ListTile(title: Text('No reports filed yet'))
                else
                  ...myReports.map(
                    (report) => ListTile(
                      title: Text(report.targetLabel),
                      subtitle: Text(report.reason),
                      trailing: Text(report.status.name.toUpperCase()),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    Future<void> showQuickSchedule() async {
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Upcoming Schedule',
                  style: context.textStyles.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (activeRentals.isEmpty)
                  const ListTile(title: Text('No active rentals scheduled'))
                else
                  ...activeRentals.map(
                    (booking) => ListTile(
                      leading: const Icon(Icons.calendar_today_rounded),
                      title: Text('Booking ${booking.id}'),
                      subtitle: Text(
                        '${DateFormat('dd MMM').format(booking.pickupDate)} - ${DateFormat('dd MMM yyyy').format(booking.returnDate)}',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    Future<void> showQuickSettings() async {
      var instantBooking = true;
      var autoReply = false;
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => StatefulBuilder(
          builder: (context, setSheetState) => SafeArea(
            child: Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Owner Settings',
                    style: context.textStyles.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SwitchListTile(
                    value: instantBooking,
                    title: const Text('Enable Instant Booking'),
                    onChanged: (value) => setSheetState(() => instantBooking = value),
                  ),
                  SwitchListTile(
                    value: autoReply,
                    title: const Text('Enable Auto Reply'),
                    onChanged: (value) => setSheetState(() => autoReply = value),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Owner Dashboard',
                          style: context.textStyles.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Welcome back, ${owner.name}',
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
                  NotificationBadgeButton(
                    count: unreadCount,
                    onTap: showOwnerNotifications,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GestureDetector(
                    onTap: () => context.push('/owner-profile'),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: primaryColor.withValues(alpha: 0.15),
                      child: Text(
                        owner.name.substring(0, 1).toUpperCase(),
                        style: context.textStyles.titleMedium?.copyWith(
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
                    child: OwnerStatCard(
                      icon: Icons.payments_rounded,
                      value: '\$${totalRevenue.toStringAsFixed(2)}',
                      label: 'Total Revenue',
                      trend: '+${(ownerBookings.length * 1.8).toStringAsFixed(1)}%',
                      trendUp: true,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: OwnerStatCard(
                      icon: Icons.key_rounded,
                      value: '${activeRentals.length}',
                      label: 'Active Rentals',
                      trend: '${vehicles.length} vehicles',
                      trendUp: activeRentals.isNotEmpty,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: AppSpacing.paddingLg,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenue Section',
                      style: context.textStyles.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Current payout account: ${userService.ownerBankAccount(owner.id).isEmpty ? 'Not added' : userService.ownerBankAccount(owner.id)}',
                      style: context.textStyles.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: showOwnerNotifications,
                            icon: const Icon(Icons.notifications_rounded),
                            label: const Text('Notifications'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: addBankAccount,
                            icon: const Icon(Icons.account_balance_rounded),
                            label: const Text('Add Bank'),
                          ),
                        ),
                      ],
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
                children: [
                  Expanded(
                    child: QuickActionCard(
                      icon: Icons.add_rounded,
                      label: 'Add Car',
                      onTap: () => context.push('/add-vehicle'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: QuickActionCard(
                      icon: Icons.assessment_rounded,
                      label: 'Reports',
                      onTap: showQuickReports,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: QuickActionCard(
                      icon: Icons.schedule_rounded,
                      label: 'Schedule',
                      onTap: showQuickSchedule,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: QuickActionCard(
                      icon: Icons.settings_rounded,
                      label: 'Settings',
                      onTap: showQuickSettings,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Rentals',
                    style: context.textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${activeRentals.length}',
                    style: context.textStyles.labelLarge?.copyWith(
                      color: successColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (activeRentals.isEmpty)
                const OwnerEmptyState(
                  title: 'No active rentals',
                  subtitle: 'Confirmed and active bookings will appear here.',
                )
              else
                ...activeRentals.map(
                  (booking) => OwnerBookingCard(
                    booking: booking,
                    vehicleName:
                        vehicleService.getVehicleById(booking.vehicleId)?.name ??
                            'Vehicle',
                    onReportUser: () => reportUserFromBooking(booking),
                  ),
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
                  TextButton(
                    onPressed: () => context.push('/owner-bookings'),
                    child: Text(
                      'View All',
                      style: context.textStyles.labelLarge?.copyWith(
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (ownerBookings.isEmpty)
                const OwnerEmptyState(
                  title: 'No bookings yet',
                  subtitle: 'Bookings will appear after users confirm payments.',
                )
              else
                ...ownerBookings.take(3).map(
                  (booking) => OwnerBookingCard(
                    booking: booking,
                    vehicleName:
                        vehicleService.getVehicleById(booking.vehicleId)?.name ??
                            'Vehicle',
                    onReportUser: () => reportUserFromBooking(booking),
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
                const OwnerEmptyState(
                  title: 'No reviews yet',
                  subtitle: 'User feedback for your vehicles will show here.',
                )
              else
                ...reviews.take(4).map(
                  (review) => OwnerReviewCard(
                    name: review.reviewerName,
                    rating: review.rating,
                    comment: review.comment,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
