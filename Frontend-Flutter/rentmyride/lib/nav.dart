import 'package:go_router/go_router.dart';
import 'package:rentmyride/screen/login_screen.dart';
import 'package:rentmyride/screen/user/user_dashboard.dart';
import 'package:rentmyride/screen/user/vehicle_details_screen.dart';
import 'package:rentmyride/screen/user/booking_screen.dart';
import 'package:rentmyride/screen/user/payment_screen.dart';
import 'package:rentmyride/screen/user/chat_screen.dart';
import 'package:rentmyride/screen/user/profile_screen.dart';
import 'package:rentmyride/screen/user/help_center_screen.dart';
import 'package:rentmyride/screen/user/privacy_policy_screen.dart';
import 'package:rentmyride/screen/owner/owner_dashboard.dart';
import 'package:rentmyride/screen/owner/add_vehicle_screen.dart';
import 'package:rentmyride/screen/owner/owner_profile_screen.dart';
import 'package:rentmyride/screen/owner/owner_bookings_screen.dart';
import 'package:rentmyride/screen/admin/admin_dashboard.dart';
import 'package:rentmyride/screen/admin/admin_profile_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => NoTransitionPage(child: const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.userDashboard,
        name: 'user-dashboard',
        pageBuilder: (context, state) => NoTransitionPage(child: const UserDashboard()),
      ),
      GoRoute(
        path: AppRoutes.vehicleDetails,
        name: 'vehicle-details',
        pageBuilder: (context, state) {
          final vehicleId = state.pathParameters['id']!;
          return NoTransitionPage(child: VehicleDetailsScreen(vehicleId: vehicleId));
        },
      ),
      GoRoute(
        path: AppRoutes.booking,
        name: 'booking',
        pageBuilder: (context, state) {
          final vehicleId = state.pathParameters['id']!;
          return NoTransitionPage(child: BookingScreen(vehicleId: vehicleId));
        },
      ),
      GoRoute(
        path: AppRoutes.payment,
        name: 'payment',
        pageBuilder: (context, state) {
          final vehicleId = state.pathParameters['id']!;
          return NoTransitionPage(child: PaymentScreen(vehicleId: vehicleId));
        },
      ),
      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        pageBuilder: (context, state) {
          final bookingId = state.pathParameters['id']!;
          return NoTransitionPage(child: ChatScreen(bookingId: bookingId));
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        pageBuilder: (context, state) => NoTransitionPage(child: const ProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.helpCenter,
        name: 'help-center',
        pageBuilder: (context, state) => NoTransitionPage(child: const HelpCenterScreen()),
      ),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        name: 'privacy-policy',
        pageBuilder: (context, state) => NoTransitionPage(child: const PrivacyPolicyScreen()),
      ),
      GoRoute(
        path: AppRoutes.ownerDashboard,
        name: 'owner-dashboard',
        pageBuilder: (context, state) => NoTransitionPage(child: const OwnerDashboard()),
      ),
      GoRoute(
        path: AppRoutes.addVehicle,
        name: 'add-vehicle',
        pageBuilder: (context, state) => NoTransitionPage(child: const AddVehicleScreen()),
      ),
      GoRoute(
        path: AppRoutes.ownerProfile,
        name: 'owner-profile',
        pageBuilder: (context, state) => NoTransitionPage(child: const OwnerProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.ownerBookings,
        name: 'owner-bookings',
        pageBuilder: (context, state) => NoTransitionPage(child: const OwnerBookingsScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        name: 'admin-dashboard',
        pageBuilder: (context, state) => NoTransitionPage(child: const AdminDashboard()),
      ),
      GoRoute(
        path: AppRoutes.adminProfile,
        name: 'admin-profile',
        pageBuilder: (context, state) => NoTransitionPage(child: const AdminProfileScreen()),
      ),
    ],
  );
}

class AppRoutes {
  static const String login = '/';
  static const String userDashboard = '/user-dashboard';
  static const String vehicleDetails = '/vehicle/:id';
  static const String booking = '/booking/:id';
  static const String payment = '/payment/:id';
  static const String chat = '/chat/:id';
  static const String profile = '/profile';
  static const String helpCenter = '/help-center';
  static const String privacyPolicy = '/privacy-policy';
  static const String ownerDashboard = '/owner-dashboard';
  static const String addVehicle = '/add-vehicle';
  static const String ownerProfile = '/owner-profile';
  static const String ownerBookings = '/owner-bookings';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminProfile = '/admin-profile';
}
