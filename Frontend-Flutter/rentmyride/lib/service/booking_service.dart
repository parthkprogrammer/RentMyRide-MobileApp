import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rentmyride/model/booking_draft_model.dart';
import 'package:rentmyride/model/booking_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingService extends ChangeNotifier {
  static const String _bookingsKey = 'bookings';
  static const String _bookingDraftsKey = 'booking_drafts';
  
  List<BookingModel> _bookings = [];
  List<BookingDraftModel> _drafts = [];
  bool _isLoading = false;

  List<BookingModel> get bookings => _bookings;
  List<BookingDraftModel> get drafts => _drafts;
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

      final draftsJson = prefs.getString(_bookingDraftsKey);
      if (draftsJson != null && draftsJson.isNotEmpty) {
        try {
          final List<dynamic> decoded = jsonDecode(draftsJson);
          _drafts = decoded.map((json) => BookingDraftModel.fromJson(json)).toList();
        } catch (e) {
          debugPrint('Error loading booking drafts: $e');
          _drafts = [];
        }
      } else {
        _drafts = [];
      }
    } catch (e) {
      debugPrint('Failed to initialize bookings: $e');
      await _initializeSampleData();
      _drafts = [];
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

  Future<void> _saveDrafts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftsJson = jsonEncode(_drafts.map((d) => d.toJson()).toList());
      await prefs.setString(_bookingDraftsKey, draftsJson);
    } catch (e) {
      debugPrint('Failed to save booking drafts: $e');
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

  BookingDraftModel? getDraft({
    required String userId,
    required String vehicleId,
  }) {
    try {
      return _drafts.lastWhere(
        (draft) => draft.userId == userId && draft.vehicleId == vehicleId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> upsertDraft(BookingDraftModel draft) async {
    final index = _drafts.indexWhere(
      (entry) => entry.userId == draft.userId && entry.vehicleId == draft.vehicleId,
    );
    if (index == -1) {
      _drafts = [..._drafts, draft];
    } else {
      _drafts[index] = draft;
    }
    await _saveDrafts();
    notifyListeners();
  }

  Future<BookingModel?> confirmDraft({
    required String userId,
    required String vehicleId,
  }) async {
    final draft = getDraft(userId: userId, vehicleId: vehicleId);
    if (draft == null) return null;

    final now = DateTime.now();
    final booking = BookingModel(
      id: 'RM${now.microsecondsSinceEpoch.toString().substring(7)}',
      userId: draft.userId,
      vehicleId: draft.vehicleId,
      ownerId: draft.ownerId,
      pickupDate: draft.pickupDate,
      returnDate: draft.returnDate,
      pickupLocation: draft.pickupLocation,
      insurancePlan: draft.insurancePlan,
      rentalFee: draft.rentalFee,
      insuranceFee: draft.insuranceFee,
      serviceFee: draft.serviceFee,
      taxes: draft.taxes,
      totalAmount: draft.totalAmount,
      status: BookingStatus.confirmed,
      createdAt: now,
      updatedAt: now,
    );

    _bookings = [..._bookings, booking];
    _drafts.removeWhere(
      (entry) => entry.userId == userId && entry.vehicleId == vehicleId,
    );
    await Future.wait([
      _saveBookings(),
      _saveDrafts(),
    ]);
    notifyListeners();
    return booking;
  }
}
