import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rentmyride/model/admin_report_model.dart';
import 'package:rentmyride/model/app_notification_model.dart';
import 'package:rentmyride/model/system_command_model.dart';
import 'package:rentmyride/model/user_model.dart';
import 'package:rentmyride/model/user_governance_model.dart';
import 'package:rentmyride/model/vehicle_submission_model.dart';
import 'package:rentmyride/service/admin_service.dart';
import 'package:rentmyride/service/notification_service.dart';
import 'package:rentmyride/service/user_service.dart';
import 'package:rentmyride/service/vehicle_service.dart';
import 'package:rentmyride/theme.dart';
import 'package:rentmyride/utils/image_source_resolver.dart';

part '../../widget/admin/admin_dashboard_widgets.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  static const List<String> _sections = [
    'Overview',
    'Reports',
    'Approvals',
    'Governance',
    'Commands',
  ];

  final TextEditingController _searchController = TextEditingController();
  String _activeSection = 'Overview';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _showSection(String section) =>
      _activeSection == 'Overview' || _activeSection == section;

  bool _matchesSearch(List<String> values) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return true;
    final searchable = values.join(' ').toLowerCase();
    return searchable.contains(query);
  }

  List<String> _notificationAudienceIds(UserService userService) {
    return userService.users
        .where(
          (user) => user.role == UserRole.user || user.role == UserRole.owner,
        )
        .map((entry) => entry.id)
        .toList();
  }

  IconData _iconForCommand(String iconKey) {
    switch (iconKey) {
      case 'shield':
        return Icons.shield_rounded;
      case 'graph':
        return Icons.auto_graph_rounded;
      case 'api':
        return Icons.account_tree_rounded;
      case 'settings':
        return Icons.settings_applications_rounded;
      default:
        return Icons.flash_on_rounded;
    }
  }

  Future<void> _sendEmergencyNotification() async {
    final userService = context.read<UserService>();
    final audience = _notificationAudienceIds(userService);
    if (audience.isEmpty) return;

    await context.read<NotificationService>().sendBroadcast(
          userIds: audience,
          title: 'Emergency Alert',
          message:
              'Please pause new trips and check the app for urgent safety guidance.',
          type: AppNotificationType.emergency,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Emergency notification sent.')),
    );
  }

  Future<void> _openAdminNotifications() async {
    final admin = context.read<UserService>().currentUser;
    if (admin == null) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.82,
          ),
          child: Consumer<NotificationService>(
            builder: (context, notificationService, _) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final errorColor =
                  isDark ? AppColors.darkError : AppColors.lightError;
              final dividerColor =
                  isDark ? AppColors.darkDivider : AppColors.lightDivider;
              final notifications =
                  notificationService.notificationsForUser(admin.id);

              return SingleChildScrollView(
                padding: AppSpacing.paddingLg,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Incoming Notifications',
                          style: context.textStyles.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () =>
                              notificationService.markAllRead(admin.id),
                          child: const Text('Mark all read'),
                        ),
                      ],
                    ),
                    if (notifications.isEmpty)
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.notifications_off_outlined),
                        title: Text('No notifications'),
                      )
                    else
                      ...notifications.map((entry) {
                        final isEmergency =
                            entry.type == AppNotificationType.emergency;
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: isEmergency
                                ? errorColor.withValues(alpha: 0.12)
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
                                  ? Icons.notification_important_rounded
                                  : (entry.isRead
                                      ? Icons.notifications_none_rounded
                                      : Icons.notifications_active_rounded),
                              color: isEmergency ? errorColor : null,
                            ),
                            title: Text(entry.title),
                            subtitle: Text(entry.message),
                            trailing: isEmergency
                                ? Text(
                                    'EMERGENCY',
                                    style:
                                        context.textStyles.labelSmall?.copyWith(
                                      color: errorColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Text(
                                    '${entry.createdAt.hour.toString().padLeft(2, '0')}:${entry.createdAt.minute.toString().padLeft(2, '0')}',
                                  ),
                            onTap: () => notificationService.markRead(
                              userId: admin.id,
                              notificationId: entry.id,
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

  Future<void> _openBroadcastDialog() async {
    final audience = _notificationAudienceIds(context.read<UserService>());
    if (audience.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recipients found for broadcast.')),
      );
      return;
    }

    final didSend = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => _BroadcastNotificationSheet(
        recipientUserIds: audience,
      ),
    );

    if (!mounted || didSend != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Broadcast sent successfully.')),
    );
  }

  Future<void> _openCreateReportDialog() async {
    final adminService = context.read<AdminService>();
    final userService = context.read<UserService>();
    final vehicleService = context.read<VehicleService>();

    var selectedType = AdminReportType.vehicleByUser;
    final reasonController = TextEditingController();
    final authorityController =
        TextEditingController(text: 'Transport Authority');
    final contactController = TextEditingController(text: 'authority@city.gov');
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final reporterPool = selectedType == AdminReportType.vehicleByUser
              ? userService.usersByRole(UserRole.user)
              : userService.usersByRole(UserRole.owner);
          final targetUsers = userService.usersByRole(UserRole.user);
          final targetVehicles = vehicleService.vehicles;

          if (reporterPool.isEmpty) {
            return AlertDialog(
              title: const Text('Create Report'),
              content:
                  const Text('No eligible users found for this report type.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Close'),
                ),
              ],
            );
          }

          String selectedReporterId = reporterPool.first.id;
          String selectedTargetId =
              selectedType == AdminReportType.vehicleByUser
                  ? (targetVehicles.isNotEmpty ? targetVehicles.first.id : '')
                  : (targetUsers.isNotEmpty ? targetUsers.first.id : '');

          return AlertDialog(
            title: const Text('Create Report'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<AdminReportType>(
                      initialValue: selectedType,
                      decoration:
                          const InputDecoration(labelText: 'Report Type'),
                      items: const [
                        DropdownMenuItem(
                          value: AdminReportType.vehicleByUser,
                          child: Text('User reporting vehicle'),
                        ),
                        DropdownMenuItem(
                          value: AdminReportType.userByOwner,
                          child: Text('Owner reporting user'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => selectedType = value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue: selectedReporterId,
                      decoration:
                          const InputDecoration(labelText: 'Reported By'),
                      items: reporterPool
                          .map(
                            (entry) => DropdownMenuItem(
                              value: entry.id,
                              child: Text(entry.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        selectedReporterId = value;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      initialValue:
                          selectedTargetId.isEmpty ? null : selectedTargetId,
                      decoration: InputDecoration(
                        labelText: selectedType == AdminReportType.vehicleByUser
                            ? 'Vehicle'
                            : 'User',
                      ),
                      items: (selectedType == AdminReportType.vehicleByUser
                              ? targetVehicles
                                  .map((entry) =>
                                      (id: entry.id, label: entry.name))
                                  .toList()
                              : targetUsers
                                  .map((entry) =>
                                      (id: entry.id, label: entry.name))
                                  .toList())
                          .map(
                            (entry) => DropdownMenuItem(
                              value: entry.id,
                              child: Text(entry.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        selectedTargetId = value;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: reasonController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Reason'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Required'
                              : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: authorityController,
                      decoration: const InputDecoration(labelText: 'Authority'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Required'
                              : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: contactController,
                      decoration:
                          const InputDecoration(labelText: 'Authority Contact'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Required'
                              : null,
                    ),
                  ],
                ),
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
                  if (selectedTargetId.isEmpty) return;
                  final reporter = userService.getUserById(selectedReporterId);
                  if (reporter == null) return;

                  if (selectedType == AdminReportType.vehicleByUser) {
                    final vehicle =
                        vehicleService.getVehicleById(selectedTargetId);
                    if (vehicle == null) return;
                    await adminService.addVehicleReport(
                      reportedById: reporter.id,
                      reportedByName: reporter.name,
                      vehicleId: vehicle.id,
                      vehicleLabel: vehicle.name,
                      reason: reasonController.text.trim(),
                      authorityName: authorityController.text.trim(),
                      authorityContact: contactController.text.trim(),
                      documents: const ['ManualReport.txt'],
                    );
                  } else {
                    final targetUser =
                        userService.getUserById(selectedTargetId);
                    if (targetUser == null) return;
                    await adminService.addUserReport(
                      reportedById: reporter.id,
                      reportedByName: reporter.name,
                      userId: targetUser.id,
                      userLabel: targetUser.name,
                      reason: reasonController.text.trim(),
                      authorityName: authorityController.text.trim(),
                      authorityContact: contactController.text.trim(),
                      documents: const ['ManualDamageReport.txt'],
                    );
                  }

                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );

  }

  Future<void> _approveSubmission(VehicleSubmissionModel submission) async {
    final vehicleService = context.read<VehicleService>();
    final notificationService = context.read<NotificationService>();
    final approved =
        await vehicleService.approveVehicleSubmission(submission.id);
    if (approved == null) return;
    await notificationService.sendToUser(
      userId: approved.ownerId,
      title: 'Vehicle Approved',
      message: '${approved.vehicle.name} is now visible to users.',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Submission approved.')),
    );
  }

  Future<void> _rejectSubmission(VehicleSubmissionModel submission) async {
    final vehicleService = context.read<VehicleService>();
    final notificationService = context.read<NotificationService>();
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Submission'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Reason'),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Required' : null,
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
              final rejected = await vehicleService.rejectVehicleSubmission(
                submission.id,
                reason: reasonController.text.trim(),
              );
              if (rejected == null) return;
              await notificationService.sendToUser(
                userId: rejected.ownerId,
                title: 'Vehicle Rejected',
                message:
                    '${rejected.vehicle.name} was rejected: ${rejected.rejectionReason}',
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );

  }

  Future<void> _toggleFlag(UserModel user) async {
    final userService = context.read<UserService>();
    final governance = userService.governanceForUser(user.id);
    if (governance.isFlagged) {
      await userService.setUserFlagged(user.id, false);
      return;
    }

    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Flag User'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Flag reason'),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Required' : null,
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
              await userService.setUserFlagged(
                user.id,
                true,
                reason: reasonController.text.trim(),
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Flag'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadUserPdf(UserModel user) async {
    final path = await context.read<UserService>().generateUserDetailsPdf(user);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User details exported: $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final dividerColor =
        isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final successColor =
        isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
    final errorColor = isDark ? AppColors.darkError : AppColors.lightError;

    final userService = context.watch<UserService>();
    final vehicleService = context.watch<VehicleService>();
    final adminService = context.watch<AdminService>();
    final notificationService = context.watch<NotificationService>();
    final currentAdmin = userService.currentUser;
    final unreadCount = currentAdmin == null
        ? 0
        : notificationService.unreadCountForUser(currentAdmin.id);

    final users = userService.users
        .where((entry) => entry.role != UserRole.admin)
        .where(
          (entry) => _matchesSearch([
            entry.name,
            entry.email,
            entry.role.name,
          ]),
        )
        .toList();

    final reports = [...adminService.reports]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final filteredReports = reports
        .where(
          (entry) => _matchesSearch([
            entry.targetLabel,
            entry.reason,
            entry.authorityName,
            entry.reportedByName,
            entry.type.name,
          ]),
        )
        .toList();
    final vehicleReports = filteredReports
        .where((entry) => entry.type == AdminReportType.vehicleByUser)
        .toList();
    final userReports = filteredReports
        .where((entry) => entry.type == AdminReportType.userByOwner)
        .toList();

    final pendingSubmissions = vehicleService.pendingSubmissions
        .where(
          (entry) => _matchesSearch([
            entry.vehicle.name,
            entry.vehicle.location,
            entry.vehicle.category,
          ]),
        )
        .toList();

    final flaggedUsers = users
        .where((entry) => userService.governanceForUser(entry.id).isFlagged)
        .length;

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
                  border: Border(bottom: BorderSide(color: dividerColor)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Admin Control Center',
                                style: context.textStyles.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Dynamic governance and operational controls',
                                style: context.textStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              tooltip: 'Notifications',
                              onPressed: _openAdminNotifications,
                              icon: const Icon(Icons.notifications_none_rounded),
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: errorColor,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.full,
                                    ),
                                  ),
                                  constraints:
                                      const BoxConstraints(minWidth: 16),
                                  child: Text(
                                    unreadCount > 9 ? '9+' : '$unreadCount',
                                    textAlign: TextAlign.center,
                                    style:
                                        context.textStyles.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        IconButton(
                          tooltip: 'Emergency Notification',
                          onPressed: _sendEmergencyNotification,
                          icon: Icon(
                            Icons.notification_important_rounded,
                            color: errorColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/admin-profile'),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: primaryColor,
                            child: Text(
                              (currentAdmin?.name ?? 'A')
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: context.textStyles.bodyMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search reports, users, approvals...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _sections
                            .map(
                              (section) => Padding(
                                padding: const EdgeInsets.only(
                                  right: AppSpacing.sm,
                                ),
                                child: ChoiceChip(
                                  label: Text(section),
                                  selected: _activeSection == section,
                                  onSelected: (_) {
                                    setState(() => _activeSection = section);
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_showSection('Overview')) ...[
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              icon: Icons.group_rounded,
                              label: 'Users',
                              value: '${users.length}',
                              trend: '$flaggedUsers flagged',
                              isPositive: flaggedUsers == 0,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: MetricCard(
                              icon: Icons.directions_car_rounded,
                              label: 'Active Fleet',
                              value: '${vehicleService.vehicles.length}',
                              trend: '${pendingSubmissions.length} pending',
                              isPositive: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    if (_showSection('Reports')) ...[
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 560;
                          if (compact) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reported Vehicles and Users',
                                  style: context.textStyles.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: _openCreateReportDialog,
                                    icon: const Icon(Icons.add_rounded),
                                    label: const Text('Add Report'),
                                  ),
                                ),
                              ],
                            );
                          }
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Reported Vehicles and Users',
                                style: context.textStyles.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _openCreateReportDialog,
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Add Report'),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Reported Vehicles',
                        style: context.textStyles.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      if (vehicleReports.isEmpty)
                        const _AdminEmptyState(
                          title: 'No vehicle reports',
                          subtitle: 'Vehicle reports filed by users appear here.',
                        )
                      else
                        ...vehicleReports.map(
                          (report) => _ReportCard(
                            report: report,
                            onChangeStatus: (status) => context
                                .read<AdminService>()
                                .setReportStatus(report.id, status),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Reported Users',
                        style: context.textStyles.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      if (userReports.isEmpty)
                        const _AdminEmptyState(
                          title: 'No user reports',
                          subtitle: 'Damage and user case reports appear here.',
                        )
                      else
                        ...userReports.map(
                          (report) => _ReportCard(
                            report: report,
                            onChangeStatus: (status) => context
                                .read<AdminService>()
                                .setReportStatus(report.id, status),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    if (_showSection('Approvals')) ...[
                      Text(
                        'Pending Approvals',
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (pendingSubmissions.isEmpty)
                        const _AdminEmptyState(
                          title: 'No pending submissions',
                          subtitle:
                              'Owner vehicle submissions will appear here.',
                        )
                      else
                        ...pendingSubmissions.map(
                          (submission) => _ApprovalCard(
                            submission: submission,
                            ownerName: userService
                                    .getUserById(submission.ownerId)
                                    ?.name ??
                                'Owner',
                            onApprove: () => _approveSubmission(submission),
                            onReject: () => _rejectSubmission(submission),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    if (_showSection('Governance')) ...[
                      Text(
                        'User Governance',
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (users.isEmpty)
                        const _AdminEmptyState(
                          title: 'No users found',
                          subtitle:
                              'User governance controls will appear here.',
                        )
                      else
                        ...users.map(
                          (user) => _GovernanceCard(
                            user: user,
                            governance: userService.governanceForUser(user.id),
                            onFlagToggle: () => _toggleFlag(user),
                            onSuspendChanged: (value) => context
                                .read<UserService>()
                                .setUserSuspended(user.id, value),
                            onBlockChanged: (value) => context
                                .read<UserService>()
                                .setUserBlocked(user.id, value),
                            onDownloadPdf: () => _downloadUserPdf(user),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    if (_showSection('Commands')) ...[
                      Text(
                        'System Commands',
                        style: context.textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                          childAspectRatio: 1.3,
                        ),
                        itemCount: adminService.systemCommands.length,
                        itemBuilder: (context, index) {
                          final command = adminService.systemCommands[index];
                          return _CommandCard(
                            icon: _iconForCommand(command.iconKey),
                            label: command.label,
                            description: command.description,
                            stateLabel: command.state.name.toUpperCase(),
                            onTap: () => context
                                .read<AdminService>()
                                .runSystemCommand(command.id),
                            stateColor: switch (command.state) {
                              SystemCommandState.completed => successColor,
                              SystemCommandState.running => primaryColor,
                              SystemCommandState.failed => errorColor,
                              SystemCommandState.idle => null,
                            },
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openBroadcastDialog,
        icon: const Icon(Icons.campaign_rounded),
        label: const Text('Broadcast Notice'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _AdminEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _AdminEmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_rounded, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: context.textStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BroadcastNotificationSheet extends StatefulWidget {
  final List<String> recipientUserIds;

  const _BroadcastNotificationSheet({required this.recipientUserIds});

  @override
  State<_BroadcastNotificationSheet> createState() =>
      _BroadcastNotificationSheetState();
}

class _BroadcastNotificationSheetState
    extends State<_BroadcastNotificationSheet> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendBroadcast() async {
    if (_isSending) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);
    final notificationService = context.read<NotificationService>();
    await notificationService.sendBroadcast(
      userIds: widget.recipientUserIds,
      title: _titleController.text.trim(),
      message: _messageController.text.trim(),
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
                    'Broadcast Notification',
                    style: context.textStyles.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Send updates to all users and owners.',
                    style: context.textStyles.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _titleController,
                    maxLength: 80,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Required'
                            : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _messageController,
                    maxLines: 4,
                    minLines: 3,
                    maxLength: 300,
                    decoration: const InputDecoration(labelText: 'Message'),
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
                          onPressed: _isSending
                              ? null
                              : () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSending ? null : _sendBroadcast,
                          icon: _isSending
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.campaign_rounded),
                          label: Text(_isSending ? 'Sending...' : 'Send'),
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

class _ReportCard extends StatelessWidget {
  final AdminReportModel report;
  final ValueChanged<AdminReportStatus> onChangeStatus;

  const _ReportCard({required this.report, required this.onChangeStatus});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor =
        isDark ? AppColors.darkDivider : AppColors.lightDivider;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report.targetLabel,
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: PopupMenuButton<AdminReportStatus>(
              onSelected: onChangeStatus,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: AdminReportStatus.open,
                  child: Text('Set Open'),
                ),
                PopupMenuItem(
                  value: AdminReportStatus.investigating,
                  child: Text('Set Investigating'),
                ),
                PopupMenuItem(
                  value: AdminReportStatus.resolved,
                  child: Text('Set Resolved'),
                ),
              ],
              child: Chip(
                label: Text(report.status.name.toUpperCase()),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            report.type == AdminReportType.vehicleByUser
                ? 'Type: User reporting vehicle'
                : 'Type: Owner reporting user (damage case)',
            style: context.textStyles.bodySmall,
          ),
          const SizedBox(height: 4),
          Text('Reason: ${report.reason}', style: context.textStyles.bodySmall),
          Text(
            'Authority: ${report.authorityName} (${report.authorityContact})',
            style: context.textStyles.bodySmall,
          ),
          if (report.documents.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: report.documents
                  .map((doc) => Chip(
                      label: Text(doc), visualDensity: VisualDensity.compact))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final VehicleSubmissionModel submission;
  final String ownerName;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApprovalCard({
    required this.submission,
    required this.ownerName,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor =
        isDark ? AppColors.darkDivider : AppColors.lightDivider;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image(
                  image: imageProviderWithFallback(submission.vehicle.imageUrl),
                  width: 72,
                  height: 52,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.vehicle.name,
                      style: context.textStyles.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Owner: $ownerName',
                      style: context.textStyles.bodySmall,
                    ),
                    Text(
                      '${submission.vehicle.category} - ${submission.vehicle.location}',
                      style: context.textStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (submission.documents.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: submission.documents
                  .map((doc) => Chip(
                      label: Text(doc), visualDensity: VisualDensity.compact))
                  .toList(),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Reject'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GovernanceCard extends StatelessWidget {
  final UserModel user;
  final UserGovernanceModel governance;
  final VoidCallback onFlagToggle;
  final ValueChanged<bool> onSuspendChanged;
  final ValueChanged<bool> onBlockChanged;
  final VoidCallback onDownloadPdf;

  const _GovernanceCard({
    required this.user,
    required this.governance,
    required this.onFlagToggle,
    required this.onSuspendChanged,
    required this.onBlockChanged,
    required this.onDownloadPdf,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor =
        isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final warningColor = isDark ? AppColors.darkError : AppColors.lightError;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                child: Text(user.name.substring(0, 1).toUpperCase()),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: context.textStyles.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('${user.email} - ${user.role.name.toUpperCase()}'),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onFlagToggle,
                icon: Icon(
                  governance.isFlagged
                      ? Icons.flag_rounded
                      : Icons.outlined_flag_rounded,
                  color: governance.isFlagged ? warningColor : null,
                ),
                label: Text(governance.isFlagged ? 'Unflag' : 'Flag'),
              ),
            ],
          ),
          if (governance.isFlagged && governance.flagReason != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                'Flag reason: ${governance.flagReason}',
                style: context.textStyles.bodySmall,
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  value: governance.isSuspended,
                  title: const Text('Suspend User'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onChanged: onSuspendChanged,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SwitchListTile(
                  value: governance.isBlocked,
                  title: const Text('Block Profile'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onChanged: onBlockChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: onDownloadPdf,
            icon: const Icon(Icons.picture_as_pdf_rounded),
            label: const Text('Download User Details as PDF'),
          ),
        ],
      ),
    );
  }
}

class _CommandCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final String stateLabel;
  final Color? stateColor;
  final VoidCallback onTap;

  const _CommandCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.stateLabel,
    required this.onTap,
    this.stateColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor =
        isDark ? AppColors.darkDivider : AppColors.lightDivider;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: context.textStyles.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodySmall,
            ),
            const Spacer(),
            Text(
              stateLabel,
              style: context.textStyles.labelSmall?.copyWith(
                color: stateColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
