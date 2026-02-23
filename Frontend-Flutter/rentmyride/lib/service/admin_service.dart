import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rentmyride/model/admin_report_model.dart';
import 'package:rentmyride/model/system_command_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminService extends ChangeNotifier {
  static const String _reportsKey = 'admin_reports';
  static const String _commandsKey = 'system_commands';

  List<AdminReportModel> _reports = [];
  List<SystemCommandModel> _systemCommands = [];
  bool _isLoading = false;

  List<AdminReportModel> get reports => _reports;
  List<SystemCommandModel> get systemCommands => _systemCommands;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();

      final reportsRaw = prefs.getString(_reportsKey);
      if (reportsRaw == null || reportsRaw.isEmpty) {
        _reports = _seedReports(DateTime.now());
      } else {
        final decoded = jsonDecode(reportsRaw) as List<dynamic>;
        _reports =
            decoded.map((entry) => AdminReportModel.fromJson(entry)).toList();
      }

      final commandsRaw = prefs.getString(_commandsKey);
      if (commandsRaw == null || commandsRaw.isEmpty) {
        _systemCommands = _seedCommands();
      } else {
        final decoded = jsonDecode(commandsRaw) as List<dynamic>;
        _systemCommands = decoded
            .map((entry) => SystemCommandModel.fromJson(entry))
            .toList();
      }

      await _saveReports();
      await _saveCommands();
    } catch (e) {
      debugPrint('Failed to initialize admin service: $e');
      _reports = _seedReports(DateTime.now());
      _systemCommands = _seedCommands();
      await _saveReports();
      await _saveCommands();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<AdminReportModel> _seedReports(DateTime now) {
    return [
      AdminReportModel(
        id: 'report-1',
        type: AdminReportType.vehicleByUser,
        reportedById: '1',
        reportedByName: 'Alex Rivers',
        targetId: '1',
        targetLabel: 'Tesla Model 3',
        reason: 'Brake warning light was active during pickup.',
        authorityName: 'City Transport Authority',
        authorityContact: 'safety@citytransport.gov',
        documents: const ['Inspection Form.pdf', 'Incident Photo.jpg'],
        status: AdminReportStatus.open,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      AdminReportModel(
        id: 'report-2',
        type: AdminReportType.userByOwner,
        reportedById: '2',
        reportedByName: 'Marcus Sterling',
        targetId: '1',
        targetLabel: 'Alex Rivers',
        reason: 'Interior damage reported after return.',
        authorityName: 'Local Dispute Cell',
        authorityContact: '+1-555-219-4400',
        documents: const ['Damage Report.pdf', 'BeforeAfter.zip'],
        status: AdminReportStatus.investigating,
        createdAt: now.subtract(const Duration(hours: 18)),
        updatedAt: now.subtract(const Duration(hours: 8)),
      ),
    ];
  }

  List<SystemCommandModel> _seedCommands() {
    return [
      SystemCommandModel(
        id: 'security-audit',
        label: 'Security Audit',
        iconKey: 'shield',
        description: 'Run platform vulnerability scan.',
      ),
      SystemCommandModel(
        id: 'market-report',
        label: 'Market Reports',
        iconKey: 'graph',
        description: 'Refresh latest market intelligence.',
      ),
      SystemCommandModel(
        id: 'api-status',
        label: 'API Status',
        iconKey: 'api',
        description: 'Check internal API health matrix.',
      ),
      SystemCommandModel(
        id: 'system-config',
        label: 'System Config',
        iconKey: 'settings',
        description: 'Validate runtime configuration drift.',
      ),
    ];
  }

  Future<void> _saveReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(_reports.map((entry) => entry.toJson()).toList());
      await prefs.setString(_reportsKey, raw);
    } catch (e) {
      debugPrint('Failed to save admin reports: $e');
    }
  }

  Future<void> _saveCommands() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw =
          jsonEncode(_systemCommands.map((entry) => entry.toJson()).toList());
      await prefs.setString(_commandsKey, raw);
    } catch (e) {
      debugPrint('Failed to save system commands: $e');
    }
  }

  Future<void> addVehicleReport({
    required String reportedById,
    required String reportedByName,
    required String vehicleId,
    required String vehicleLabel,
    required String reason,
    required String authorityName,
    required String authorityContact,
    required List<String> documents,
  }) async {
    final now = DateTime.now();
    final report = AdminReportModel(
      id: 'report-${now.microsecondsSinceEpoch}',
      type: AdminReportType.vehicleByUser,
      reportedById: reportedById,
      reportedByName: reportedByName,
      targetId: vehicleId,
      targetLabel: vehicleLabel,
      reason: reason,
      authorityName: authorityName,
      authorityContact: authorityContact,
      documents: documents,
      status: AdminReportStatus.open,
      createdAt: now,
      updatedAt: now,
    );
    _reports = [report, ..._reports];
    await _saveReports();
    notifyListeners();
  }

  Future<void> addUserReport({
    required String reportedById,
    required String reportedByName,
    required String userId,
    required String userLabel,
    required String reason,
    required String authorityName,
    required String authorityContact,
    required List<String> documents,
  }) async {
    final now = DateTime.now();
    final report = AdminReportModel(
      id: 'report-${now.microsecondsSinceEpoch}',
      type: AdminReportType.userByOwner,
      reportedById: reportedById,
      reportedByName: reportedByName,
      targetId: userId,
      targetLabel: userLabel,
      reason: reason,
      authorityName: authorityName,
      authorityContact: authorityContact,
      documents: documents,
      status: AdminReportStatus.open,
      createdAt: now,
      updatedAt: now,
    );
    _reports = [report, ..._reports];
    await _saveReports();
    notifyListeners();
  }

  Future<void> setReportStatus(
    String reportId,
    AdminReportStatus status,
  ) async {
    final index = _reports.indexWhere((entry) => entry.id == reportId);
    if (index == -1) return;

    _reports[index] = _reports[index].copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    await _saveReports();
    notifyListeners();
  }

  Future<void> runSystemCommand(String commandId) async {
    final index = _systemCommands.indexWhere((entry) => entry.id == commandId);
    if (index == -1) return;

    _systemCommands[index] = _systemCommands[index].copyWith(
      state: SystemCommandState.running,
      lastRunAt: DateTime.now(),
    );
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 300));

    _systemCommands[index] = _systemCommands[index].copyWith(
      state: SystemCommandState.completed,
      lastRunAt: DateTime.now(),
    );
    await _saveCommands();
    notifyListeners();
  }
}
