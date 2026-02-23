import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rentmyride/service/user_service.dart';
import 'package:rentmyride/theme.dart';

class OwnerProfileScreen extends StatelessWidget {
  const OwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
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
              final controller = TextEditingController(
                text: userService.ownerBankAccount(owner.id),
              );
              await showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Update Bank Account'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Account / UPI / IBAN',
                    ),
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
            },
            icon: const Icon(Icons.add_card_rounded),
            label: const Text('Add / Update Bank Account'),
          ),
        ],
      ),
    );
  }
}
