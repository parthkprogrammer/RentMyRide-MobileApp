import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentmyride/service/admin_service.dart';
import 'package:rentmyride/service/user_service.dart';
import 'package:rentmyride/service/vehicle_service.dart';
import 'package:rentmyride/service/booking_service.dart';
import 'package:rentmyride/service/theme_service.dart';
import 'package:rentmyride/service/notification_service.dart';
import 'theme.dart';
import 'nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final userService = UserService();
  final vehicleService = VehicleService();
  final bookingService = BookingService();
  final themeService = ThemeService();
  final notificationService = NotificationService();
  final adminService = AdminService();
  
  await Future.wait([
    userService.initialize(),
    vehicleService.initialize(),
    bookingService.initialize(),
    themeService.initialize(),
    notificationService.initialize(),
    adminService.initialize(),
  ]);
  
  runApp(MyApp(
    userService: userService,
    vehicleService: vehicleService,
    bookingService: bookingService,
    themeService: themeService,
    notificationService: notificationService,
    adminService: adminService,
  ));
}

class MyApp extends StatelessWidget {
  final UserService userService;
  final VehicleService vehicleService;
  final BookingService bookingService;
  final ThemeService themeService;
  final NotificationService notificationService;
  final AdminService adminService;

  const MyApp({
    super.key,
    required this.userService,
    required this.vehicleService,
    required this.bookingService,
    required this.themeService,
    required this.notificationService,
    required this.adminService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userService),
        ChangeNotifierProvider.value(value: vehicleService),
        ChangeNotifierProvider.value(value: bookingService),
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: notificationService),
        ChangeNotifierProvider.value(value: adminService),
      ],
      child: Consumer2<ThemeService, UserService>(
        builder: (context, themeService, userService, _) {
          final roleKey = userService.currentUser?.role.name ?? 'user';
          themeService.setActiveRole(roleKey);
          return MaterialApp.router(
            title: 'RentMyRide',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeService.themeModeForRole(roleKey),
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
