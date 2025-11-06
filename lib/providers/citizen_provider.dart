import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models/incident_model.dart';
import '../data/repositories/incident_repository.dart';
import '../data/services/location_service.dart';

class CitizenProvider extends ChangeNotifier {
  final IncidentRepository _incidentRepository;
  final LocationService _locationService;
  CitizenProvider(this._incidentRepository, this._locationService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<IncidentModel> _nearbyIncidents = [];
  List<IncidentModel> get nearbyIncidents => _nearbyIncidents;
  
  List<IncidentModel> _myReports = [];
  List<IncidentModel> get myReports => _myReports;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> fetchNearbyIncidents() async {
    _setLoading(true);
    try {
      final position = await _locationService.getCurrentLocation();
      print(position);
      _nearbyIncidents = await _incidentRepository.getNearbyIncidents(position.latitude, position.longitude);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }
  
  Future<void> fetchMyReports() async {
    _setLoading(true);
    try {
      _myReports = await _incidentRepository.getMyReports();
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  Future<bool> submitReport({
    required String title, required String description, required String type,
    required String severity, required XFile image
  }) async {
    _setLoading(true);
    try {
      final position = await _locationService.getCurrentLocation();
      await _incidentRepository.reportIncident(
        title: title, description: description, type: type, severity: severity,
        latitude: position.latitude, longitude: position.longitude, image: image
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
}