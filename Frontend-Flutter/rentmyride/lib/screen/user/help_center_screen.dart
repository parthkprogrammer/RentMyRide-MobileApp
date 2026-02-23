import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rentmyride/theme.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = const [
      (
        title: 'How do I modify a booking?',
        body:
            'Open Booking History from Profile and select the booking. You can reschedule if the owner allows date changes.'
      ),
      (
        title: 'When do I get my refund?',
        body:
            'Refunds for cancellations are processed according to the selected insurance and cancellation window.'
      ),
      (
        title: 'How do I contact the owner?',
        body:
            'Open vehicle details and use the Chat action. You can also reach out from the booking confirmation chat thread.'
      ),
      (
        title: 'How do I report an issue?',
        body:
            'Use the Report option from car details or contact support from this page for urgent incidents.'
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Help Center'),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need help with your ride?',
                  style: context.textStyles.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Browse common questions or contact support.',
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...faqs.map(
            (faq) => Card(
              child: ExpansionTile(
                tilePadding: AppSpacing.horizontalMd,
                childrenPadding: AppSpacing.paddingMd,
                title: Text(
                  faq.title,
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      faq.body,
                      style: context.textStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Support ticket created (mock).')),
              );
            },
            icon: const Icon(Icons.support_agent_rounded),
            label: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }
}
