import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_routes.dart';
import '../../utils/constants.dart'; // Ensure you have AppConstants for baseUrl

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    // CORRECT: Use context.read for a one-time read in initState
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    // Initialize controllers with user data.
    // The build method will handle the edge case where user is null.
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 80, maxWidth: 800);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F1F1F),
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Colors.white70),
              title: Text('Gallery', style: GoogleFonts.poppins(color: Colors.white)),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: Colors.white70),
              title: Text('Camera', style: GoogleFonts.poppins(color: Colors.white)),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        imageFile: _imageFile,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop();
        } else {
          // IMPROVEMENT: Use the specific error message from the provider
          final errorMessage = authProvider.updateErrorMessage ?? 'Failed to update profile.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // CORRECT: Use watch here to react to state changes (like user updates or logout)
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    // CORRECT: Handle null user case safely in the build method
    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("User not found.", style: GoogleFonts.poppins(color: Colors.white70)),
              TextButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false),
                child: const Text("Go to Login"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text('Edit Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white24,
                      // IMPROVEMENT: Display existing network image or new local file
                      backgroundImage: _imageFile != null
                          ? FileImage(File(_imageFile!.path)) as ImageProvider
                          : (user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty)
                              ? NetworkImage(AppConstants.baseUrl.substring(0, AppConstants.baseUrl.length - 3) + user.profilePictureUrl!)
                              : null,
                      child: (_imageFile == null && (user.profilePictureUrl == null || user.profilePictureUrl!.isEmpty))
                          ? const Icon(Icons.person_outline, size: 60, color: Colors.white70)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImagePickerOptions,
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFFFFC107),
                          child: Icon(Icons.edit, size: 20, color: Color(0xFF121212)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration('Full Name', Icons.person_outline),
                style: GoogleFonts.poppins(color: Colors.white),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: _buildInputDecoration('Phone Number', Icons.phone_outlined),
                keyboardType: TextInputType.phone,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              const SizedBox(height: 16),
              // CORRECT: Use the user object from the provider
              _buildReadOnlyField('Email', user.email, Icons.email_outlined),
              const SizedBox(height: 16),
              _buildReadOnlyField('Role', user.role, Icons.shield_outlined),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: authProvider.status == AuthStatus.Updating ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                ),
                child: authProvider.status == AuthStatus.Updating
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Color(0xFF121212), strokeWidth: 3),
                      )
                    : Text(
                        'Save Changes',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF121212),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData prefixIcon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      prefixIcon: Icon(prefixIcon, color: Colors.white70),
    );
  }
}