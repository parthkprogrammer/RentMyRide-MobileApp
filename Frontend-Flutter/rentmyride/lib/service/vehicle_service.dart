import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rentmyride/model/review_model.dart';
import 'package:rentmyride/model/vehicle_model.dart';
import 'package:rentmyride/model/vehicle_submission_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VehicleService extends ChangeNotifier {
  static const String _vehiclesKey = 'vehicles';
  static const String _reviewsKey = 'vehicle_reviews';
  static const String _vehicleSubmissionsKey = 'vehicle_submissions';

  List<VehicleModel> _vehicles = [];
  Map<String, List<ReviewModel>> _reviewsByVehicle = {};
  List<VehicleSubmissionModel> _vehicleSubmissions = [];
  bool _isLoading = false;

  List<VehicleModel> get vehicles => _vehicles;
  List<VehicleSubmissionModel> get pendingSubmissions => _vehicleSubmissions
      .where((entry) => entry.status == VehicleSubmissionStatus.pending)
      .toList();
  List<VehicleSubmissionModel> get reviewedSubmissions => _vehicleSubmissions
      .where((entry) => entry.status != VehicleSubmissionStatus.pending)
      .toList();
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final vehiclesJson = prefs.getString(_vehiclesKey);

      if (vehiclesJson == null || vehiclesJson.isEmpty) {
        await _initializeSampleData();
      } else {
        try {
          final List<dynamic> decoded = jsonDecode(vehiclesJson);
          _vehicles =
              decoded.map((json) => VehicleModel.fromJson(json)).toList();
        } catch (e) {
          debugPrint('Error loading vehicles: $e');
          await _initializeSampleData();
        }
      }

      _loadReviews(prefs);
      _loadSubmissions(prefs);
      await _ensureBikeSeedData();
      _ensureSeedReviews();
      _ensureSeedSubmissions();
      await Future.wait([
        _saveReviews(),
        _saveSubmissions(),
      ]);
    } catch (e) {
      debugPrint('Failed to initialize vehicles: $e');
      await _initializeSampleData();
      _ensureSeedReviews();
      _ensureSeedSubmissions();
      await Future.wait([
        _saveReviews(),
        _saveSubmissions(),
      ]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _initializeSampleData() async {
    _vehicles = _buildSampleVehicles(DateTime.now());
    await _saveVehicles();
  }

  List<VehicleModel> _buildSampleVehicles(DateTime now) {
    return [
      VehicleModel(
        id: '1',
        name: 'Tesla Model 3',
        ownerId: '2',
        category: 'Electric',
        imageUrl:
            'assets/images/Tesla_Model_3_white_electric_car_null_1771667568328.jpg',
        additionalImages: const [],
        pricePerDay: 85,
        rating: 4.9,
        reviewCount: 124,
        fuelType: 'Electric',
        transmission: 'Automatic',
        seats: 5,
        range: '358 mi',
        acceleration: '3.1s',
        location: 'San Francisco, CA',
        description:
            'Experience the pinnacle of electric performance with Autopilot.',
        features: const [
          'Autopilot',
          'Premium Sound',
          'Heated Seats',
          'Glass Roof',
        ],
        securityDeposit: 500,
        createdAt: now.subtract(const Duration(days: 180)),
        updatedAt: now,
      ),
      VehicleModel(
        id: '2',
        name: 'Porsche 911 Carrera',
        ownerId: '2',
        category: 'Sports',
        imageUrl:
            'assets/images/Porsche_911_silver_sports_car_null_1771667569111.jpg',
        additionalImages: const [],
        pricePerDay: 240,
        rating: 5.0,
        reviewCount: 89,
        fuelType: 'Petrol',
        transmission: 'Automatic',
        seats: 2,
        acceleration: '3.0s',
        location: 'Los Angeles, CA',
        description: 'Iconic sports car with breathtaking performance.',
        features: const [
          'Sports Exhaust',
          'PASM',
          'Premium Interior',
          'Launch Control',
        ],
        securityDeposit: 2000,
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now,
      ),
      VehicleModel(
        id: '3',
        name: 'Range Rover Sport',
        ownerId: '2',
        category: 'SUV',
        imageUrl:
            'assets/images/Range_Rover_Sport_black_SUV_null_1771667570051.jpg',
        additionalImages: const [],
        pricePerDay: 120,
        rating: 4.8,
        reviewCount: 67,
        fuelType: 'Diesel',
        transmission: 'Automatic',
        seats: 7,
        location: 'San Francisco, CA',
        description: 'Luxury SUV with exceptional off-road capability.',
        features: const [
          '4x4',
          'Terrain Response',
          'Premium Audio',
          'Panoramic Roof',
        ],
        securityDeposit: 1000,
        createdAt: now.subtract(const Duration(days: 120)),
        updatedAt: now,
      ),
      VehicleModel(
        id: '4',
        name: 'BMW M4 Competition',
        ownerId: '2',
        category: 'Sports',
        imageUrl: 'assets/images/BMW_M4_blue_null_1771667571068.jpg',
        additionalImages: const [],
        pricePerDay: 150,
        rating: 4.9,
        reviewCount: 43,
        fuelType: 'Petrol',
        transmission: 'Automatic',
        seats: 4,
        acceleration: '3.8s',
        location: 'San Diego, CA',
        description: 'M Performance at its finest with thrilling dynamics.',
        features: const [
          'M Sport Exhaust',
          'Carbon Fiber',
          'Adaptive Suspension',
          'Harman Kardon',
        ],
        securityDeposit: 1500,
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now,
      ),
      VehicleModel(
        id: '5',
        name: 'Tesla Model Y Performance',
        ownerId: '2',
        category: 'Electric',
        imageUrl:
            'assets/images/Tesla_Model_Y_Performance_silver_null_1771667571785.jpg',
        additionalImages: const [],
        pricePerDay: 95,
        rating: 4.9,
        reviewCount: 156,
        fuelType: 'Electric',
        transmission: 'Automatic',
        seats: 5,
        range: '303 mi',
        acceleration: '3.5s',
        location: 'Los Angeles, CA',
        description: 'Electric SUV with impressive performance and space.',
        features: const [
          'Autopilot',
          'Premium Audio',
          'Heated Seats',
          'Panoramic Roof',
        ],
        securityDeposit: 750,
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now,
      ),
      ..._buildBikeSamples(now),
    ];
  }

  List<VehicleModel> _buildBikeSamples(DateTime now) {
    return [
      VehicleModel(
        id: 'bike-seed-1',
        name: 'Royal Enfield Meteor 350',
        ownerId: '2',
        category: 'Bikes',
        imageUrl:
            'assets/images/modern_blue_sedan_car_side_view_null_1771667575645.jpg',
        additionalImages: const [],
        pricePerDay: 45,
        rating: 4.7,
        reviewCount: 52,
        fuelType: 'Petrol',
        transmission: 'Manual',
        seats: 2,
        location: 'San Francisco, CA',
        description: 'Comfort cruiser bike for city rides and weekend trips.',
        features: const [
          'ABS',
          'Bluetooth Navigation',
          'USB Charger',
        ],
        securityDeposit: 250,
        createdAt: now.subtract(const Duration(days: 35)),
        updatedAt: now,
      ),
      VehicleModel(
        id: 'bike-seed-2',
        name: 'Ather 450X',
        ownerId: '2',
        category: 'Bikes',
        imageUrl: 'assets/images/black_luxury_BMW_SUV_null_1771667576545.jpg',
        additionalImages: const [],
        pricePerDay: 40,
        rating: 4.8,
        reviewCount: 39,
        fuelType: 'Electric',
        transmission: 'Automatic',
        seats: 2,
        range: '90 mi',
        location: 'Los Angeles, CA',
        description:
            'Smart electric scooter with quick acceleration and app controls.',
        features: const [
          'Fast Charging',
          'Touch Dashboard',
          'Regenerative Braking',
        ],
        securityDeposit: 220,
        createdAt: now.subtract(const Duration(days: 18)),
        updatedAt: now,
      ),
    ];
  }

  bool _isBikeCategory(String category) {
    final normalized = category.toLowerCase();
    return normalized.contains('bike') ||
        normalized.contains('motorcycle') ||
        normalized.contains('scooter');
  }

  Future<void> _ensureBikeSeedData() async {
    final hasBikeVehicles =
        _vehicles.any((vehicle) => _isBikeCategory(vehicle.category));
    if (hasBikeVehicles) return;

    final now = DateTime.now();
    final existingIds = _vehicles.map((vehicle) => vehicle.id).toSet();

    final bikesToAdd = _buildBikeSamples(now).map((bike) {
      if (!existingIds.contains(bike.id)) {
        existingIds.add(bike.id);
        return bike;
      }

      final uniqueId =
          '${bike.id}-${now.microsecondsSinceEpoch}-${existingIds.length}';
      existingIds.add(uniqueId);
      return bike.copyWith(id: uniqueId);
    }).toList();

    _vehicles = [..._vehicles, ...bikesToAdd];
    await _saveVehicles();
  }

  Future<void> _saveVehicles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vehiclesJson =
          jsonEncode(_vehicles.map((v) => v.toJson()).toList());
      await prefs.setString(_vehiclesKey, vehiclesJson);
    } catch (e) {
      debugPrint('Failed to save vehicles: $e');
    }
  }

  void _loadReviews(SharedPreferences prefs) {
    try {
      final raw = prefs.getString(_reviewsKey);
      if (raw == null || raw.isEmpty) {
        _reviewsByVehicle = {};
        return;
      }
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _reviewsByVehicle = decoded.map((vehicleId, entries) {
        final reviews = (entries as List<dynamic>)
            .map((entry) => ReviewModel.fromJson(entry))
            .toList();
        return MapEntry(vehicleId, reviews);
      });
    } catch (e) {
      debugPrint('Failed to load vehicle reviews: $e');
      _reviewsByVehicle = {};
    }
  }

  void _loadSubmissions(SharedPreferences prefs) {
    try {
      final raw = prefs.getString(_vehicleSubmissionsKey);
      if (raw == null || raw.isEmpty) {
        _vehicleSubmissions = [];
        return;
      }
      final decoded = jsonDecode(raw) as List<dynamic>;
      _vehicleSubmissions = decoded
          .map((entry) => VehicleSubmissionModel.fromJson(entry))
          .toList();
    } catch (e) {
      debugPrint('Failed to load vehicle submissions: $e');
      _vehicleSubmissions = [];
    }
  }

  void _ensureSeedReviews() {
    final now = DateTime.now();
    void ensureReview(
      String vehicleId,
      List<ReviewModel> seedReviews,
    ) {
      _reviewsByVehicle.putIfAbsent(vehicleId, () => seedReviews);
    }

    ensureReview(
      '1',
      [
        ReviewModel(
          id: 'r-1-1',
          vehicleId: '1',
          reviewerName: 'Jordan',
          rating: 4.9,
          comment: 'Smooth pickup and super clean interior.',
          createdAt: now.subtract(const Duration(days: 3)),
        ),
        ReviewModel(
          id: 'r-1-2',
          vehicleId: '1',
          reviewerName: 'Priya',
          rating: 4.8,
          comment: 'Great battery range and easy handover.',
          createdAt: now.subtract(const Duration(days: 7)),
        ),
      ],
    );
    ensureReview(
      '2',
      [
        ReviewModel(
          id: 'r-2-1',
          vehicleId: '2',
          reviewerName: 'Liam',
          rating: 5.0,
          comment: 'Incredible drive experience, exactly as listed.',
          createdAt: now.subtract(const Duration(days: 4)),
        ),
      ],
    );
  }

  void _ensureSeedSubmissions() {
    if (_vehicleSubmissions.isNotEmpty) return;
    final now = DateTime.now();
    _vehicleSubmissions = [
      VehicleSubmissionModel(
        id: 'sub-seed-1',
        ownerId: '2',
        vehicle: VehicleModel(
          id: 'pending-1',
          name: 'Audi Q5 Premium',
          ownerId: '2',
          category: 'SUV',
          imageUrl: 'assets/images/black_luxury_BMW_SUV_null_1771667576545.jpg',
          additionalImages: const [],
          pricePerDay: 132,
          rating: 0,
          reviewCount: 0,
          fuelType: 'Petrol',
          transmission: 'Automatic',
          seats: 5,
          location: 'Los Angeles, CA',
          description: 'Owner-submitted premium SUV awaiting admin approval.',
          features: const ['Sunroof', 'ABS', 'Cruise Control'],
          securityDeposit: 850,
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
        documents: const ['RC.pdf', 'Insurance.pdf'],
        status: VehicleSubmissionStatus.pending,
        submittedAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  Future<void> _saveReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = _reviewsByVehicle.map(
        (vehicleId, reviews) => MapEntry(
            vehicleId, reviews.map((entry) => entry.toJson()).toList()),
      );
      await prefs.setString(_reviewsKey, jsonEncode(encoded));
    } catch (e) {
      debugPrint('Failed to save vehicle reviews: $e');
    }
  }

  Future<void> _saveSubmissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
          _vehicleSubmissions.map((entry) => entry.toJson()).toList());
      await prefs.setString(_vehicleSubmissionsKey, encoded);
    } catch (e) {
      debugPrint('Failed to save vehicle submissions: $e');
    }
  }

  List<VehicleModel> getVehiclesByCategory(String category) {
    final normalized = category.trim().toLowerCase();

    if (normalized == 'all') return _vehicles;

    if (normalized == 'bikes' || normalized == 'bike') {
      return _vehicles.where((v) => _isBikeCategory(v.category)).toList();
    }

    if (normalized == 'suvs' || normalized == 'suv') {
      return _vehicles
          .where((v) =>
              v.category.toLowerCase() == 'suv' ||
              v.category.toLowerCase() == 'suvs')
          .toList();
    }

    if (normalized == 'cars' || normalized == 'car') {
      return _vehicles.where((v) {
        final value = v.category.toLowerCase();
        return value == 'car' ||
            value == 'cars' ||
            value == 'sedan' ||
            value == 'hatchback' ||
            value == 'coupe';
      }).toList();
    }

    return _vehicles
        .where((v) => v.category.toLowerCase() == normalized)
        .toList();
  }

  VehicleModel? getVehicleById(String id) {
    try {
      return _vehicles.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  List<VehicleModel> getVehiclesByOwner(String ownerId) =>
      _vehicles.where((v) => v.ownerId == ownerId).toList();

  Future<void> addVehicle(VehicleModel vehicle) async {
    _vehicles.add(vehicle);
    await _saveVehicles();
    notifyListeners();
  }

  Future<void> updateVehicle(VehicleModel vehicle) async {
    final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) {
      _vehicles[index] = vehicle;
      await _saveVehicles();
      notifyListeners();
    }
  }

  Future<void> deleteVehicle(String id) async {
    _vehicles.removeWhere((v) => v.id == id);
    await _saveVehicles();
    notifyListeners();
  }

  List<ReviewModel> getReviewsForVehicle(String vehicleId) {
    final reviews = _reviewsByVehicle[vehicleId] ?? const <ReviewModel>[];
    final sorted = [...reviews];
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  List<ReviewModel> getReviewsForOwner(String ownerId) {
    final ownerVehicleIds = _vehicles
        .where((vehicle) => vehicle.ownerId == ownerId)
        .map((vehicle) => vehicle.id)
        .toSet();

    final collected = <ReviewModel>[];
    for (final vehicleId in ownerVehicleIds) {
      collected.addAll(_reviewsByVehicle[vehicleId] ?? const <ReviewModel>[]);
    }
    collected.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return collected;
  }

  Future<void> addReview(ReviewModel review) async {
    final reviews = [
      ...(_reviewsByVehicle[review.vehicleId] ?? const <ReviewModel>[]),
    ];
    reviews.add(review);
    _reviewsByVehicle[review.vehicleId] = reviews;
    await _saveReviews();
    notifyListeners();
  }

  Future<void> submitVehicleForApproval({
    required VehicleModel vehicle,
    required String ownerId,
    required List<String> documents,
  }) async {
    final now = DateTime.now();
    final submission = VehicleSubmissionModel(
      id: 'sub-${now.microsecondsSinceEpoch}',
      vehicle: vehicle,
      ownerId: ownerId,
      documents: documents,
      status: VehicleSubmissionStatus.pending,
      submittedAt: now,
      updatedAt: now,
    );
    _vehicleSubmissions = [submission, ..._vehicleSubmissions];
    await _saveSubmissions();
    notifyListeners();
  }

  Future<VehicleSubmissionModel?> approveVehicleSubmission(
      String submissionId) async {
    final index =
        _vehicleSubmissions.indexWhere((entry) => entry.id == submissionId);
    if (index == -1) return null;
    final submission = _vehicleSubmissions[index];
    if (submission.status != VehicleSubmissionStatus.pending) return null;

    final now = DateTime.now();
    final approvedSubmission = submission.copyWith(
      status: VehicleSubmissionStatus.approved,
      updatedAt: now,
      vehicle: submission.vehicle.copyWith(updatedAt: now),
    );
    _vehicleSubmissions[index] = approvedSubmission;

    if (!_vehicles.any((vehicle) => vehicle.id == submission.vehicle.id)) {
      _vehicles = [..._vehicles, approvedSubmission.vehicle];
    }

    await Future.wait([
      _saveVehicles(),
      _saveSubmissions(),
    ]);
    notifyListeners();
    return approvedSubmission;
  }

  Future<VehicleSubmissionModel?> rejectVehicleSubmission(
    String submissionId, {
    required String reason,
  }) async {
    final index =
        _vehicleSubmissions.indexWhere((entry) => entry.id == submissionId);
    if (index == -1) return null;
    final submission = _vehicleSubmissions[index];
    if (submission.status != VehicleSubmissionStatus.pending) return null;

    final rejected = submission.copyWith(
      status: VehicleSubmissionStatus.rejected,
      rejectionReason: reason,
      updatedAt: DateTime.now(),
    );
    _vehicleSubmissions[index] = rejected;
    await _saveSubmissions();
    notifyListeners();
    return rejected;
  }
}
