import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rentmyride/theme.dart';

part '../../widget/user/chat_widgets.dart';

class ChatScreen extends StatelessWidget {
  final String bookingId;

  const ChatScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final successColor = isDark ? AppColors.darkSuccess : AppColors.lightSuccess;

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.pop(),
                  ),
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 21,
                        child: Icon(Icons.person, size: 24),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: successColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: surfaceColor, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Marcus (Owner)',
                          style: context.textStyles.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: successColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Online',
                              style: context.textStyles.labelSmall?.copyWith(
                                color: successColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.call_outlined, color: primaryColor),
                      onPressed: () {},
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color:
                          isDark
                              ? AppColors.darkSecondaryText
                              : AppColors.lightSecondaryText,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Image.asset(
                    'assets/images/Tesla_Model_3_white_electric_car_null_1771667568328.jpg',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Tesla Model 3 (2023)',
                              style: context.textStyles.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              'ID: #$bookingId',
                              style: context.textStyles.labelSmall?.copyWith(
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'Oct 24 - Oct 27',
                            style: context.textStyles.labelSmall?.copyWith(
                              color:
                                  isDark
                                      ? AppColors.darkSecondaryText
                                      : AppColors.lightSecondaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: successColor,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    'Confirmed',
                    style: context.textStyles.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingLg,
              child: Column(
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color:
                              isDark
                                  ? AppColors.darkDivider
                                  : AppColors.lightDivider,
                        ),
                      ),
                      child: Text(
                        'Today',
                        style: context.textStyles.labelSmall?.copyWith(
                          color:
                              isDark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.lightSecondaryText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ChatBubble(
                    isMe: false,
                    message:
                        'Hi there! Thanks for booking my Tesla. Will you be arriving at the airport or should I drop it at your hotel?',
                    time: '10:30 AM',
                  ),
                  ChatBubble(
                    isMe: true,
                    message:
                        'Hi Marcus! The airport would be perfect. I\'ll be landing around 2:00 PM at Terminal 2.',
                    time: '10:32 AM',
                  ),
                  ChatBubble(
                    isMe: false,
                    message:
                        'Perfect. I\'ll be waiting at the Arrivals Gate 4. I\'ll send you the exact parking spot number once I arrive.',
                    time: '10:35 AM',
                  ),
                  ChatBubble(
                    isMe: true,
                    message:
                        'Sounds great, thank you! Do I need to bring any specific documents besides my license?',
                    time: '10:36 AM',
                  ),
                  ChatBubble(
                    isMe: false,
                    message:
                        'Just your digital rental agreement from the app. See you soon!',
                    time: '10:38 AM',
                  ),
                  ChatBubble(
                    isMe: true,
                    message: 'Got it. See you at Gate 4!',
                    time: '10:40 AM',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color:
                                isDark
                                    ? AppColors.darkDivider
                                    : AppColors.lightDivider,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color:
                                    isDark
                                        ? AppColors.darkSecondary
                                        : AppColors.lightSecondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: (isDark
                                        ? AppColors.darkSecondary
                                        : AppColors.lightSecondary)
                                    .withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: (isDark
                                        ? AppColors.darkSecondary
                                        : AppColors.lightSecondary)
                                    .withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Marcus is typing...',
                        style: context.textStyles.labelSmall?.copyWith(
                          color:
                              isDark
                                  ? AppColors.darkSecondaryText
                                  : AppColors.lightSecondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: AppSpacing.horizontalLg,
                child: Row(
                  children: [
                    QuickReplyChip(label: 'On my way! ðŸš—'),
                    const SizedBox(width: AppSpacing.sm),
                    QuickReplyChip(label: 'Where are you?'),
                    const SizedBox(width: AppSpacing.sm),
                    QuickReplyChip(label: 'Thanks! ðŸ™'),
                    const SizedBox(width: AppSpacing.sm),
                    QuickReplyChip(label: 'I\'m running late'),
                  ],
                ),
              ),
              Container(
                padding: AppSpacing.paddingMd,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  border: Border(
                    top: BorderSide(
                      color:
                          isDark
                              ? AppColors.darkDivider
                              : AppColors.lightDivider,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_rounded),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Container(
                          padding: AppSpacing.horizontalLg,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Type a message...',
                              style: context.textStyles.bodyMedium?.copyWith(
                                color:
                                    isDark
                                        ? AppColors.darkHint
                                        : AppColors.lightHint,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
