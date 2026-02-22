import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rentmyride/model/booking_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingService extends ChangeNotifier {
  static const String _bookingsKey = 'bookings';
  
  List<BookingModel> _bookings = [];
  bool _isLoading = false;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = prefs.getString(_bookingsKey);
      
      if (bookingsJson == null || bookingsJson.isEmpty) {
        await _initializeSampleData();
      } else {
        try {
          final List<dynamic> decoded = jsonDecode(bookingsJson);
          _bookings = decoded.map((json) => BookingModel.fromJson(json)).toList();
        } catch (e) {
          debugPrint('Error loading bookings: $e');
          await _initializeSampleData();
        }
      }
    } catch (e) {
      debugPrint('Failed to initialize bookings: $e');
      await _initializeSampleData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _initializeSampleData() async {
    final now = DateTime.now();
    _bookings = [
      BookingModel(
        id: 'RM8291',
        userId: '1',
        vehicleId: '1',
        ownerId: '2',
        pickupDate: now.add(const Duration(days: 2)),
        returnDate: now.add(const Duration(days: 5)),
        pickupLocation: 'Downtown Hub',
        insurancePlan: 'Premium Protection',
        rentalFee: 255.0,
        insuranceFee: 75.0,
        serviceFee: 25.40,
        taxes: 12.10,
        totalAmount: 367.50,
        status: BookingStatus.confirmed,
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now,
      ),
    ];
    await _saveBookings();
  }

  Future<void> _saveBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = jsonEncode(_bookings.map((b) => b.toJson()).toList());
      await prefs.setString(_bookingsKey, bookingsJson);
    } catch (e) {
      debugPrint('Failed to save bookings: $e');
    }
  }

  List<BookingModel> getBookingsByUser(String userId) =>
    _bookings.where((b) => b.userId == userId).toList();

  List<BookingModel> getBookingsByOwner(String ownerId) =>
    _bookings.where((b) => b.ownerId == ownerId).toList();

  BookingModel? getBookingById(String id) {
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> createBooking(BookingModel booking) async {
    _bookings.add(booking);
    await _saveBookings();
    notifyListeners();
  }

  Future<void> updateBooking(BookingModel booking) async {
    final index = _bookings.indexWhere((b) => b.id == booking.id);
    if (index != -1) {
      _bookings[index] = booking;
      await _saveBookings();
      notifyListeners();
    }
  }

  Future<void> cancelBooking(String id) async {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: BookingStatus.cancelled,
        updatedAt: DateTime.now(),
      );
      await _saveBookings();
      notifyListeners();
    }
  }
}