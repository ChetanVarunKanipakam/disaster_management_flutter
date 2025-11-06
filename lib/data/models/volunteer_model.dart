import './user_model.dart'; // Assuming you have a UserModel

class VolunteerProfileModel {
  final String userId;
  bool isAvailable; // Make it non-final to allow optimistic updates
  final String? skills;
  final UserModel? user; // To hold nested user details

  VolunteerProfileModel({
    required this.userId,
    required this.isAvailable,
    this.skills,
    this.user,
  });

  factory VolunteerProfileModel.fromJson(Map<String, dynamic> json) {
    return VolunteerProfileModel(
      userId: json['userId'],
      isAvailable: json['isAvailable'] ?? true,
      skills: json['skills'],
      // Safely parse the nested User object if it exists
      user: json['User'] != null ? UserModel.fromJson(json['User']) : null,
    );
  }
}