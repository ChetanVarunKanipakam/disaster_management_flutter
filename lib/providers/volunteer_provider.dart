import 'package:flutter/material.dart';
import '../data/models/incident_model.dart';
import '../data/repositories/incident_repository.dart';
import '../data/repositories/volunteer_repository.dart';
import '../data/models/volunteer_model.dart';
import '../data/services/location_service.dart';

class VolunteerProvider extends ChangeNotifier {
  final IncidentRepository _incidentRepository;
  final VolunteerRepository _volunteerRepository;
  final LocationService _locationService;

  VolunteerProvider(this._incidentRepository, this._volunteerRepository, this._locationService) {
    // You might not need to call this here if the dashboard screen calls it.
    fetchVolunteerProfile();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- REMOVED ---
  // This variable was causing the state confusion.
  // bool _isAvailable = true;
  // bool get isAvailable => _isAvailable;

  List<IncidentModel> _assignedIncidents = [];
  List<IncidentModel> get assignedIncidents => _assignedIncidents;



  VolunteerProfileModel? _volunteerProfile;
  VolunteerProfileModel? get volunteerProfile => _volunteerProfile;

  bool _isProfileLoading = false;
  bool get isProfileLoading => _isProfileLoading;

  String? _profileError;
  String? get profileError => _profileError;

  Future<void> fetchVolunteerProfile() async {
    _isProfileLoading = true;
    _profileError = null;
    notifyListeners();
    try {
      _volunteerProfile = await _volunteerRepository.getVolunteerProfile();
    } catch (e) {
      _profileError = e.toString();
    } finally {
      _isProfileLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAssignedIncidents(String volunteerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _assignedIncidents = await _incidentRepository.getAssignedIncidents(volunteerId);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
  
  // *** CORRECTED FUNCTION ***
  Future<void> toggleAvailability(String userId, bool newAvailability) async {
    // Do nothing if the profile hasn't been loaded yet.
    if (_volunteerProfile == null) return;

    // Store the original value in case we need to revert on error.
    final originalAvailability = _volunteerProfile!.isAvailable;
    
    // 1. Optimistic UI Update: Change the property that the UI is actually watching.
    _volunteerProfile!.isAvailable = newAvailability;
    notifyListeners(); // This will now update the switch correctly.

    try {
      // 2. Make the API call with the new value.
      final position = await _locationService.getCurrentLocation();
      await _volunteerRepository.updateAvailability(
        userId,
        position.latitude,
        position.longitude,
        newAvailability, // Pass the new value directly
      );
      // No need to call notifyListeners() again on success.
    } catch (e) {
      // 3. Revert state on error and notify the UI again.
      _volunteerProfile!.isAvailable = originalAvailability;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updateIncidentStatus(String incidentId, String status) async {
    try {
      await _incidentRepository.updateIncidentStatus(incidentId, status);
      final index = _assignedIncidents.indexWhere((inc) => inc.id == incidentId);
      if (index != -1) { // Check if the incident exists in the list
        if (status == 'RESOLVED') {
          _assignedIncidents.removeAt(index);
        } else {
          final updatedIncident = await _incidentRepository.getIncidentDetails(incidentId);
          _assignedIncidents[index] = updatedIncident;
        }
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}