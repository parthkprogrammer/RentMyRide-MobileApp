import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rentmyride/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = const [
      (
        title: 'Data We Collect',
        body:
            'We collect account details, booking activity, and transaction metadata required to provide rental services.'
      ),
      (
        title: 'How We Use Data',
        body:
            'Your data is used for booking confirmation, user safety checks, payment processing, and support communication.'
      ),
      (
        title: 'Data Sharing',
        body:
            'We only share necessary details with vehicle owners, payment processors, and legal authorities when required.'
      ),
      (
        title: 'Retention',
        body:
            'Booking and compliance records are retained for audit and dispute management according to applicable regulations.'
      ),
      (
        title: 'Your Controls',
        body:
            'You can request account updates, download your legal profile details, and contact support for data concerns.'
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Privacy Policy'),
      ),
      body: ListView(
        padding: AppSpacing.paddingLg,
        children: [
          Text(
            'Last updated: February 23, 2026',
            style: context.textStyles.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: context.textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    section.body,
                    style: context.textStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
