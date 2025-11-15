import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportProvider extends ChangeNotifier {
  final ReportService _reportService = ReportService();

  List<Report> _reports = [];
  List<SupportTicket> _supportTickets = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Report> get reports => _reports;
  List<SupportTicket> get supportTickets => _supportTickets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Report> getReportsByStatus(ReportStatus status) {
    return _reports.where((report) => report.status == status).toList();
  }

  List<Report> get activeReports {
    return _reports
        .where(
          (report) =>
              report.status == ReportStatus.submitted ||
              report.status == ReportStatus.underReview,
        )
        .toList();
  }

  List<Report> get resolvedReports {
    return _reports
        .where(
          (report) =>
              report.status == ReportStatus.resolved ||
              report.status == ReportStatus.closed,
        )
        .toList();
  }

  Future<void> loadUserReports() async {
    _setLoading(true);
    _clearError();

    try {
      _reports = await _reportService.getUserReports();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load reports: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadSupportTickets() async {
    _setLoading(true);
    _clearError();

    try {
      _supportTickets = await _reportService.getUserSupportTickets();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load support tickets: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> submitReport({
    required String category,
    required String description,
    String? tripId,
    String? driverId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _reportService.submitReport(
        category: category,
        description: description,
        tripId: tripId,
        driverId: driverId,
      );

      if (result['success'] == true) {
        await loadUserReports();
      } else {
        _setError(result['error'] ?? 'Failed to submit report');
      }

      return result;
    } catch (e) {
      _setError('Error submitting report: ${e.toString()}');
      return {'success': false, 'error': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> submitSupportTicket({
    required String email,
    required String description,
    String subject = 'General Support',
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _reportService.submitSupportTicket(
        email: email,
        description: description,
        subject: subject,
      );

      if (result['success'] == true) {
        await loadSupportTickets();
      } else {
        _setError(result['error'] ?? 'Failed to submit support ticket');
      }

      return result;
    } catch (e) {
      _setError('Error submitting support ticket: ${e.toString()}');
      return {'success': false, 'error': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteReport(String reportId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _reportService.deleteReport(reportId);

      if (success) {
        _reports.removeWhere((report) => report.id == reportId);
        notifyListeners();
      } else {
        _setError('Cannot delete report that is under review or resolved');
      }

      return success;
    } catch (e) {
      _setError('Error deleting report: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<Report?> getReportById(String reportId) async {
    try {
      return await _reportService.getReportById(reportId);
    } catch (e) {
      _setError('Error fetching report: ${e.toString()}');
      return null;
    }
  }

  Future<Map<String, int>> getReportsStatistics() async {
    try {
      return await _reportService.getReportsCountByStatus();
    } catch (e) {
      _setError('Error fetching statistics: ${e.toString()}');
      return {};
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearAll() {
    _reports = [];
    _supportTickets = [];
    _errorMessage = null;
    notifyListeners();
  }
}
