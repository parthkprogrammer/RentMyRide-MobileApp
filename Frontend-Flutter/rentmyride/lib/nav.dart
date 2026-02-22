import 'package:go_router/go_router.dart';
import 'package:rentmyride/screen/login_screen.dart';
import 'package:rentmyride/screen/user/user_dashboard.dart';
import 'package:rentmyride/screen/user/vehicle_details_screen.dart';
import 'package:rentmyride/screen/user/booking_screen.dart';
import 'package:rentmyride/screen/user/payment_screen.dart';
import 'package:rentmyride/screen/user/chat_screen.dart';
import 'package:rentmyride/screen/user/profile_screen.dart';
import 'package:rentmyride/screen/owner/owner_dashboard.dart';
import 'package:rentmyride/screen/owner/add_vehicle_screen.dart';
import 'package:rentmyride/screen/admin/admin_dashboard.dart';

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
        path: AppRoutes.adminDashboard,
        name: 'admin-dashboard',
        pageBuilder: (context, state) => NoTransitionPage(child: const AdminDashboard()),
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
  static const String ownerDashboard = '/owner-dashboard';
  static const String addVehicle = '/add-vehicle';
  static const String adminDashboard = '/admin-dashboard';
}