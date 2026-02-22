part of '../../screen/user/chat_screen.dart';

class ChatBubble extends StatelessWidget {
  final bool isMe;
  final String message;
  final String time;

  const ChatBubble({
    super.key,
    required this.isMe,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final hintColor = isDark ? AppColors.darkHint : AppColors.lightHint;

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: AppSpacing.paddingMd,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: isMe ? primaryColor : surfaceColor,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color:
                      isMe
                          ? Colors.transparent
                          : (isDark
                              ? AppColors.darkDivider
                              : AppColors.lightDivider),
                ),
              ),
              child: Text(
                message,
                style: context.textStyles.bodyMedium?.copyWith(
                  color: isMe ? Colors.white : null,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: context.textStyles.labelSmall?.copyWith(color: hintColor),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color:
                        isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class QuickReplyChip extends StatelessWidget {
  final String label;

  const QuickReplyChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: primaryColor),
      ),
      child: Text(
        label,
        style: context.textStyles.labelMedium?.copyWith(
          color: primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
