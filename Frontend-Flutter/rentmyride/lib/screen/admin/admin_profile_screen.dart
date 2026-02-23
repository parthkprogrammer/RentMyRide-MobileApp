import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rentmyride/service/admin_service.dart';
import 'package:rentmyride/service/user_service.dart';
import 'package:rentmyride/theme.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<UserService>().currentUser;
    final openReports = context
        .watch<AdminService>()
        .reports
        .where((report) => report.status.name != 'resolved')
        .length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Admin Profile'),
      ),
      body: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      child: Text(
                        (admin?.name ?? 'Admin').substring(0, 1).toUpperCase(),
                        style: context.textStyles.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      admin?.name ?? 'Admin User',
                      style: context.textStyles.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(admin?.email ?? ''),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: AppSpacing.paddingLg,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Open Cases'),
                    Text(
                      '$openReports',
                      style: context.textStyles.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
