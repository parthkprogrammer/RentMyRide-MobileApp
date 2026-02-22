part of '../../screen/owner/add_vehicle_screen.dart';

class FormLabel extends StatelessWidget {
  final String label;

  const FormLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: context.textStyles.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class StepIndicator extends StatelessWidget {
  final String number;
  final bool isActive;
  final bool isCompleted;

  const StepIndicator({
    super.key,
    required this.number,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.lightDivider;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color:
                isCompleted
                    ? primaryColor
                    : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
            shape: BoxShape.circle,
            border: Border.all(color: isCompleted ? primaryColor : dividerColor),
          ),
          child: Center(
            child: Text(
              number,
              style: context.textStyles.bodySmall?.copyWith(
                color:
                    isCompleted
                        ? Colors.white
                        : (isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightSecondaryText),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 2,
            color: isCompleted ? primaryColor : dividerColor,
          ),
        ),
      ],
    );
  }
}

class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: Icon(
        Icons.add_a_photo_rounded,
        color:
            isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
        size: 24,
      ),
    );
  }
}

class SpecDropdown extends StatelessWidget {
  final String label;
  final String hint;

  const SpecDropdown({super.key, required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormLabel(label: label),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(hintText: hint),
          items: const [],
          onChanged: (v) {},
        ),
      ],
    );
  }
}
