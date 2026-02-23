import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rentmyride/service/theme_service.dart';
import 'package:rentmyride/service/user_service.dart';
import 'package:rentmyride/theme.dart';

class OwnerProfileScreen extends StatelessWidget {
  const OwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    final themeService = context.watch<ThemeService>();
    final owner = userService.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    if (owner == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Owner Profile')),
        body: const Center(child: Text('No owner profile found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Owner Profile'),
      ),
      body: ListView(
        padding: AppSpacing.paddingLg,
        children: [
          Container(
            padding: AppSpacing.paddingLg,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    owner.name.substring(0, 1).toUpperCase(),
                    style: context.textStyles.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        owner.name,
                        style: context.textStyles.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        owner.email,
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Payout Account',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_rounded, color: primaryColor),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    userService.ownerBankAccount(owner.id).isEmpty
                        ? 'No bank account added'
                        : userService.ownerBankAccount(owner.id),
                    style: context.textStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () async {
              final accountValue = await showDialog<String>(
                context: context,
                builder: (_) => _OwnerBankAccountDialog(
                  initialValue: userService.ownerBankAccount(owner.id),
                ),
              );
              if (!context.mounted || accountValue == null) return;
              await context
                  .read<UserService>()
                  .setOwnerBankAccount(owner.id, accountValue);
            },
            icon: const Icon(Icons.add_card_rounded),
            label: const Text('Add / Update Bank Account'),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Settings',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.dark_mode_rounded, color: primaryColor),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Dark Mode (Owner)',
                    style: context.textStyles.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch(
                  value: themeService.isDarkModeForRole('owner'),
                  onChanged: (enabled) => context
                      .read<ThemeService>()
                      .toggleDarkModeForRole('owner', enabled),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () async {
              await context.read<UserService>().logout();
              if (!context.mounted) return;
              context.go('/');
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkError : AppColors.lightError,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerBankAccountDialog extends StatefulWidget {
  final String initialValue;

  const _OwnerBankAccountDialog({required this.initialValue});

  @override
  State<_OwnerBankAccountDialog> createState() => _OwnerBankAccountDialogState();
}

class _OwnerBankAccountDialogState extends State<_OwnerBankAccountDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Bank Account'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(labelText: 'Account / UPI / IBAN'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
