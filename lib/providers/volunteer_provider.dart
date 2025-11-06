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
  VolunteerProvider(this._incidentRepository, this._volunteerRepository,this._locationService){
    fetchVolunteerProfile();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  bool _isAvailable = true;
  bool get isAvailable => _isAvailable;

  List<IncidentModel> _assignedIncidents = [];
  List<IncidentModel> get assignedIncidents => _assignedIncidents;

  VolunteerProfileModel? _volunteerProfile;
  VolunteerProfileModel? get volunteerProfile => _volunteerProfile;

  bool _isProfileLoading = false;
  bool get isProfileLoading => _isProfileLoading;

  String? _profileError;
  String? get profileError => _profileError;


  // New method to fetch the profile
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
  
  Future<void> toggleAvailability(String userId, bool available) async {
    _isAvailable = available;
    notifyListeners();
    try {

      final position = await _locationService.getCurrentLocation();
      await _volunteerRepository.updateAvailability(userId,   position.latitude,  position.longitude,_isAvailable);
    } catch (e) {
      // Revert state on error
      _isAvailable = !_isAvailable;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  Future<bool> updateIncidentStatus(String incidentId, String status) async {
    try {
      await _incidentRepository.updateIncidentStatus(incidentId, status);
      // Refresh list after updating
      final index = _assignedIncidents.indexWhere((inc) => inc.id == incidentId);
      if(status == 'RESOLVED') {
        _assignedIncidents.removeAt(index);
      } else {
         final updatedIncident = await _incidentRepository.getIncidentDetails(incidentId);
         _assignedIncidents[index] = updatedIncident;
      }
      notifyListeners();
      return true;
    } catch(e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}