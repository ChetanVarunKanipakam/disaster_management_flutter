import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../providers/citizen_provider.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});
  @override
  _ReportIncidentScreenState createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _severity = 'LOW';
  String _type = 'FIRE';
  XFile? _imageFile;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select an image to upload.'),
        backgroundColor: Colors.orangeAccent,
      ));
      return;
    }

    final provider = context.read<CitizenProvider>();
    final success = await provider.submitReport(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      type: _type,
      severity: _severity,
      image: _imageFile!,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incident reported successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to report incident.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        setState(() => _imageFile = pickedFile);
      }
    } catch (e) {
      // Handle exceptions, e.g., permissions denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          'Report New Incident',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<CitizenProvider>(
        builder: (context, provider, child) {
          return provider.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: _buildInputDecoration('Title', Icons.title),
                          style: GoogleFonts.poppins(color: Colors.white),
                          validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descController,
                          decoration: _buildInputDecoration('Description', Icons.description_outlined, line: 4),
                          maxLines: 4,
                          style: GoogleFonts.poppins(color: Colors.white),
                           validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _severity,
                          decoration: _buildInputDecoration('Severity', Icons.priority_high_outlined),
                          dropdownColor: const Color(0xFF212121),
                          style: GoogleFonts.poppins(color: Colors.white),
                          items: ['LOW', 'MEDIUM', 'HIGH']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (value) => setState(() => _severity = value!),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _type,
                          decoration: _buildInputDecoration('Type', Icons.category_outlined),
                          dropdownColor: const Color(0xFF212121),
                          style: GoogleFonts.poppins(color: Colors.white),
                          items: ['FIRE', 'EARTHQUAKE', 'FLOOD', 'OTHERS']
                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (value) => setState(() => _type = value!),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: _imageFile == null
                              ? Center(
                                  child: Text(
                                    'Upload an image',
                                    style: GoogleFonts.poppins(color: Colors.white70),
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(_imageFile!.path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFFFFC107)),
                              label: Text('Camera', style: GoogleFonts.poppins(color: Colors.white)),
                              onPressed: () => _pickImage(ImageSource.camera),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.photo_library_outlined, color: Color(0xFFFFC107)),
                              label: Text('Gallery', style: GoogleFonts.poppins(color: Colors.white)),
                              onPressed: () => _pickImage(ImageSource.gallery),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _submitReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC107),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                          child: Text(
                            'Submit Report',
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
                );
        },
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData prefixIcon, {int line=1}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      alignLabelWithHint: line > 1? true : false,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      prefixIcon: Icon(prefixIcon, color: Colors.white70),
    );
  }
}