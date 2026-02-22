import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentmyride/service/user_service.dart';
import 'package:rentmyride/service/vehicle_service.dart';
import 'package:rentmyride/service/booking_service.dart';
import 'theme.dart';
import 'nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final userService = UserService();
  final vehicleService = VehicleService();
  final bookingService = BookingService();
  
  await Future.wait([
    userService.initialize(),
    vehicleService.initialize(),
    bookingService.initialize(),
  ]);
  
  runApp(MyApp(
    userService: userService,
    vehicleService: vehicleService,
    bookingService: bookingService,
  ));
}

class MyApp extends StatelessWidget {
  final UserService userService;
  final VehicleService vehicleService;
  final BookingService bookingService;

  const MyApp({
    super.key,
    required this.userService,
    required this.vehicleService,
    required this.bookingService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userService),
        ChangeNotifierProvider.value(value: vehicleService),
        ChangeNotifierProvider.value(value: bookingService),
      ],
      child: MaterialApp.router(
        title: 'RentMyRide',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}