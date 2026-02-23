import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rentmyride/model/booking_model.dart';
import 'package:rentmyride/service/booking_service.dart';
import 'package:rentmyride/service/user_service.dart';
import 'package:rentmyride/service/vehicle_service.dart';
import 'package:rentmyride/theme.dart';
import 'package:rentmyride/utils/image_source_resolver.dart';

class OwnerBookingsScreen extends StatelessWidget {
  const OwnerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final owner = context.watch<UserService>().currentUser;
    if (owner == null) {
      return const Scaffold(body: Center(child: Text('No owner found')));
    }

    final bookings = context
        .watch<BookingService>()
        .getBookingsByOwner(owner.id)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final vehicleService = context.watch<VehicleService>();

    Color colorForStatus(BookingStatus status, bool isDark) {
      switch (status) {
        case BookingStatus.confirmed:
          return isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
        case BookingStatus.active:
          return isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
        case BookingStatus.cancelled:
          return isDark ? AppColors.darkError : AppColors.lightError;
        case BookingStatus.completed:
          return const Color(0xFF8B5CF6);
        case BookingStatus.pending:
          return const Color(0xFFF59E0B);
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('All Bookings'),
      ),
      body: bookings.isEmpty
          ? const Center(child: Text('No bookings found'))
          : ListView.builder(
              padding: AppSpacing.paddingLg,
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final vehicle =
                    vehicleService.getVehicleById(booking.vehicleId);
                final statusColor = colorForStatus(booking.status, isDark);
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkDivider
                          : AppColors.lightDivider,
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Image(
                          image: imageProviderWithFallback(vehicle?.imageUrl),
                          width: 78,
                          height: 58,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle?.name ?? 'Vehicle',
                              style: context.textStyles.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${DateFormat('dd MMM').format(booking.pickupDate)} - ${DateFormat('dd MMM yyyy').format(booking.returnDate)}',
                              style: context.textStyles.bodySmall,
                            ),
                            Text(
                              booking.id,
                              style: context.textStyles.labelSmall,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${booking.totalAmount.toStringAsFixed(2)}',
                            style: context.textStyles.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            booking.status.name.toUpperCase(),
                            style: context.textStyles.labelSmall?.copyWith(
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
