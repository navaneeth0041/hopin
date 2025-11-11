import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trip.dart';
import '../services/trip_service.dart';

class TripProvider extends ChangeNotifier {
  final TripService _tripService = TripService();

  List<Trip> _activeTrips = [];
  List<Trip> _myCreatedTrips = [];
  List<Trip> _myJoinedTrips = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<Trip> get activeTrips => _activeTrips;
  List<Trip> get myCreatedTrips => _myCreatedTrips;
  List<Trip> get myJoinedTrips => _myJoinedTrips;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<Trip?> getActiveUserTrip() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      return await _tripService.getActiveUserTrip(user.uid);
    } catch (e) {
      return null;
    }
  }

  Future<bool> checkIfUserHasActiveTrip() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      return await _tripService.hasActiveTrip(user.uid);
    } catch (e) {
      return false;
    }
  }

  Future<bool> completeTrip(String tripId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _tripService.completeTrip(tripId);
      if (success) {
        await loadUserTrips();
        loadActiveTrips();
      } else {
        _setError('Failed to complete trip');
      }
      return success;
    } catch (e) {
      _setError('Error completing trip: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> createTrip({
    required String currentLocation,
    required String destination,
    required DateTime departureTime,
    required int availableSeats,
    String? note,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final tripId = await _tripService.createTrip(
        currentLocation: currentLocation,
        destination: destination,
        departureTime: departureTime,
        availableSeats: availableSeats,
        note: note,
      );

      if (tripId != null) {
        await loadUserTrips();
        return tripId;
      } else {
        _setError('Failed to create trip');
        return null;
      }
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void loadActiveTrips() {
    _tripService.getActiveTrips().listen(
      (trips) {
        _activeTrips = trips;
        notifyListeners();
      },
      onError: (error) {
        _setError('Error loading trips: ${error.toString()}');
      },
    );
  }

  Future<void> loadUserTrips() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _tripService
        .getUserCreatedTrips(user.uid)
        .listen(
          (trips) {
            _myCreatedTrips = trips;
            notifyListeners();
          },
          onError: (error) {
            _setError('Error loading created trips: ${error.toString()}');
          },
        );

    _tripService
        .getUserJoinedTrips(user.uid)
        .listen(
          (trips) {
            _myJoinedTrips = trips;
            notifyListeners();
          },
          onError: (error) {
            _setError('Error loading joined trips: ${error.toString()}');
          },
        );
  }

  Future<Trip?> getTripById(String tripId) async {
    _setLoading(true);
    _clearError();

    try {
      return await _tripService.getTripById(tripId);
    } catch (e) {
      _setError('Error fetching trip: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateTrip(String tripId, Map<String, dynamic> updates) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _tripService.updateTrip(tripId, updates);
      if (success) {
        await loadUserTrips();
      } else {
        _setError('Failed to update trip');
      }
      return success;
    } catch (e) {
      _setError('Error updating trip: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelTrip(String tripId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _tripService.cancelTrip(tripId);
      if (success) {
        await loadUserTrips();
      } else {
        _setError('Failed to cancel trip');
      }
      return success;
    } catch (e) {
      _setError('Error cancelling trip: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> joinTrip(String tripId) async {
    _setLoading(true);
    _clearError();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _setError('User not authenticated');
        return false;
      }

      final success = await _tripService.joinTrip(tripId, user.uid);
      if (success) {
        await loadUserTrips();
        loadActiveTrips();
      } else {
        _setError('Failed to join trip');
      }
      return success;
    } catch (e) {
      _setError('Error joining trip: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> leaveTrip(String tripId) async {
    _setLoading(true);
    _clearError();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _setError('User not authenticated');
        return false;
      }

      final success = await _tripService.leaveTrip(tripId, user.uid);
      if (success) {
        await loadUserTrips();
        loadActiveTrips();
      } else {
        _setError('Failed to leave trip');
      }
      return success;
    } catch (e) {
      _setError('Error leaving trip: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteTrip(String tripId) async {
    _setLoading(true);
    _clearError();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _setError('User not authenticated');
        return false;
      }

      final success = await _tripService.deleteTrip(tripId, user.uid);
      if (success) {
        await loadUserTrips();
        loadActiveTrips();
      } else {
        _setError('Failed to delete trip');
      }
      return success;
    } catch (e) {
      _setError('Error deleting trip: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void searchTripsByDestination(String destination) {
    if (destination.isEmpty) {
      loadActiveTrips();
      return;
    }

    _tripService
        .searchTripsByDestination(destination)
        .listen(
          (trips) {
            _activeTrips = trips;
            notifyListeners();
          },
          onError: (error) {
            _setError('Error searching trips: ${error.toString()}');
          },
        );
  }

  void loadUpcomingTrips() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _tripService
        .getUpcomingTripsForUser(user.uid)
        .listen(
          (trips) {
            notifyListeners();
          },
          onError: (error) {
            _setError('Error loading upcoming trips: ${error.toString()}');
          },
        );
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

  void clearData() {
    _activeTrips = [];
    _myCreatedTrips = [];
    _myJoinedTrips = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
