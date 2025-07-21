import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'package:care_connect_app/services/auth_token_manager.dart';
import 'package:care_connect_app/providers/user_provider.dart';
import 'package:care_connect_app/widgets/app_bar_helper.dart';
import 'package:care_connect_app/widgets/common_drawer.dart';
import 'package:care_connect_app/config/theme/app_theme.dart';
import '../../models/profile_model.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({Key? key}) : super(key: key);

  @override
  _ProfileSettingsPageState createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  dynamic _userProfile;
  bool _isPatient = false;
  bool _isCaregiver = false;

  final _formKey = GlobalKey<FormState>();

  // Common text controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();

  // Caregiver specific controllers
  final _specializationController = TextEditingController();
  final _organizationController = TextEditingController();
  final _licenseController = TextEditingController();

  // Patient specific controllers
  final _dateOfBirthController = TextEditingController();
  final _genderController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();

    _specializationController.dispose();
    _organizationController.dispose();
    _licenseController.dispose();

    _dateOfBirthController.dispose();
    _genderController.dispose();
    _emergencyContactController.dispose();
    _medicalConditionsController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();

    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userSession = await AuthTokenManager.getUserSession();
      if (userSession == null || userSession['id'] == null) {
        throw Exception('User session not found');
      }

      final userRole = userSession['role'] as String? ?? '';

      setState(() {
        _isPatient = userRole.toUpperCase() == 'PATIENT';
        _isCaregiver =
            userRole.toUpperCase() == 'CAREGIVER' ||
            userRole.toUpperCase() == 'FAMILY_LINK' ||
            userRole.toUpperCase() == 'ADMIN';
      });

      // First, retrieve the user's profile using the appropriate ID from the session
      if (_isCaregiver) {
        // Use the caregiver-specific ID from the session, not the user ID
        final caregiverId = userSession['caregiverId'] as int?;
        if (caregiverId == null) {
          throw Exception('Caregiver ID not found in user session');
        }

        final response = await ApiService.getCaregiverProfile(caregiverId);
        if (response.statusCode == 200) {
          final data = await _parseResponse(response);
          setState(() {
            _userProfile = CaregiverProfile.fromJson(data);
          });
          _populateCaregiverFields();
        } else {
          throw Exception(
            'Failed to load caregiver profile: ${response.statusCode}',
          );
        }
      } else if (_isPatient) {
        // Use the patient-specific ID from the session, not the user ID
        final patientId = userSession['patientId'] as int?;
        if (patientId == null) {
          throw Exception('Patient ID not found in user session');
        }

        final response = await ApiService.getPatientProfile(patientId);
        if (response.statusCode == 200) {
          final data = await _parseResponse(response);
          setState(() {
            _userProfile = PatientProfile.fromJson(data);
          });
          _populatePatientFields();
        } else {
          throw Exception(
            'Failed to load patient profile: ${response.statusCode}',
          );
        }
      } else {
        throw Exception('Unknown user role: $userRole');
      }

      // The profile picture URL should already be included in the user data from the API
      // We don't need to make a separate API call for this
      // If the API response includes profileImageUrl, we should use it directly in the parseResponse method
    } catch (e) {
      setState(() {
        _error = 'Failed to load profile: $e';
      });
      print('Error in _loadUserProfile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper to parse the API response
  dynamic _parseResponse(response) {
    try {
      if (response.body.isEmpty) {
        return {};
      }

      final rawData = json.decode(response.body);

      // Transform the API response structure to match our model expectations
      if (_isCaregiver) {
        // Check for profile picture URL in the user object
        String? profilePictureUrl;
        if (rawData['user'] != null &&
            rawData['user']['profileImageUrl'] != null) {
          profilePictureUrl = rawData['user']['profileImageUrl'];
        } else {
          profilePictureUrl = _userProfile?.profilePictureUrl;
        }

        return {
          'id': rawData['id'] ?? 0,
          'name': '${rawData['firstName'] ?? ''} ${rawData['lastName'] ?? ''}'
              .trim(),
          'email': rawData['email'] ?? '',
          'phoneNumber': rawData['phone'] ?? '',
          'address': rawData['address']?['line1'] ?? '',
          'city': rawData['address']?['city'] ?? '',
          'state': rawData['address']?['state'] ?? '',
          'zipCode': rawData['address']?['zip'] ?? '',
          'country': '', // Default to empty as it's not in the response
          'specialization': rawData['professional'] ?? '',
          'organization': '', // Default to empty as it's not in the response
          'license': '', // Default to empty as it's not in the response
          'profilePictureUrl': profilePictureUrl,
        };
      } else if (_isPatient) {
        // Check for profile picture URL in the user object
        String? profilePictureUrl;
        if (rawData['user'] != null &&
            rawData['user']['profileImageUrl'] != null) {
          profilePictureUrl = rawData['user']['profileImageUrl'];
        } else {
          profilePictureUrl = _userProfile?.profilePictureUrl;
        }

        return {
          'id': rawData['id'] ?? 0,
          'name': '${rawData['firstName'] ?? ''} ${rawData['lastName'] ?? ''}'
              .trim(),
          'email': rawData['email'] ?? '',
          'phoneNumber': rawData['phone'] ?? '',
          'address': rawData['address']?['line1'] ?? '',
          'city': rawData['address']?['city'] ?? '',
          'state': rawData['address']?['state'] ?? '',
          'zipCode': rawData['address']?['zip'] ?? '',
          'country': '', // Default to empty as it's not in the response
          'dateOfBirth': rawData['dob'] ?? '',
          'gender': rawData['gender'] ?? '',
          'emergencyContact': rawData['emergencyContact'] ?? '',
          'medicalConditions': rawData['medicalConditions'] ?? '',
          'allergies': rawData['allergies'] ?? '',
          'medications': rawData['medications'] ?? '',
          'profilePictureUrl': profilePictureUrl,
        };
      }

      return rawData;
    } catch (e) {
      print('Error parsing response: $e');
      return {};
    }
  }

  void _populateCaregiverFields() {
    if (_userProfile == null) return;

    final profile = _userProfile as CaregiverProfile;
    _nameController.text = profile.name;
    _emailController.text = profile.email ?? '';
    _phoneController.text = profile.phoneNumber ?? '';
    _addressController.text = profile.address ?? '';
    _cityController.text = profile.city ?? '';
    _stateController.text = profile.state ?? '';
    _zipCodeController.text = profile.zipCode ?? '';
    _countryController.text = profile.country ?? '';

    _specializationController.text = profile.specialization ?? '';
    _organizationController.text = profile.organization ?? '';
    _licenseController.text = profile.license ?? '';
  }

  void _populatePatientFields() {
    if (_userProfile == null) return;

    final profile = _userProfile as PatientProfile;
    _nameController.text = profile.name;
    _emailController.text = profile.email ?? '';
    _phoneController.text = profile.phoneNumber ?? '';
    _addressController.text = profile.address ?? '';
    _cityController.text = profile.city ?? '';
    _stateController.text = profile.state ?? '';
    _zipCodeController.text = profile.zipCode ?? '';
    _countryController.text = profile.country ?? '';

    _dateOfBirthController.text = profile.dateOfBirth ?? '';
    _genderController.text = profile.gender ?? '';
    _emergencyContactController.text = profile.emergencyContact ?? '';
    _medicalConditionsController.text = profile.medicalConditions ?? '';
    _allergiesController.text = profile.allergies ?? '';
    _medicationsController.text = profile.medications ?? '';
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Upload the image immediately
      _uploadProfilePicture();
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_imageFile == null || _userProfile == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Get the user session to retrieve the correct ID based on role
      final userSession = await AuthTokenManager.getUserSession();
      int? profileId;

      if (_isPatient) {
        profileId = userSession?['patientId'] as int?;
      } else if (_isCaregiver) {
        profileId = userSession?['caregiverId'] as int?;
      }

      if (profileId == null) {
        throw Exception("Profile ID not found for the current user role");
      }

      // Send the correct profile ID and role for the file upload
      final response = await ApiService.uploadUserFile(
        userId: profileId,
        file: _imageFile!,
        category: 'profilePicture',
        role: _isPatient ? 'PATIENT' : 'CAREGIVER',
      );

      if (response.statusCode == 200) {
        // Parse the response directly to get the file URL
        final responseData = json.decode(response.body);
        if (responseData != null && responseData.containsKey('fileUrl')) {
          final newUrl = responseData['fileUrl'] as String;

          // Update the profile picture URL in the state
          setState(() {
            if (_isCaregiver) {
              _userProfile = (_userProfile as CaregiverProfile).copyWith(
                profilePictureUrl: newUrl,
              );
            } else if (_isPatient) {
              _userProfile = (_userProfile as PatientProfile).copyWith(
                profilePictureUrl: newUrl,
              );
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Get the user session to retrieve the correct ID based on role
      final userSession = await AuthTokenManager.getUserSession();

      // Add role-specific fields
      if (_isCaregiver) {
        // Build caregiver profile data based on the expected backend structure
        final Map<String, dynamic> profileData = {
          'firstName': _nameController.text.split(' ').first,
          'lastName': _nameController.text.contains(' ')
              ? _nameController.text.split(' ').last
              : '',
          'dob': _dateOfBirthController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          // Professional info
          'professional': {
            'licenseNumber': _licenseController.text,
            'issuingState':
                _stateController.text, // Using state as issuing state
            'yearsExperience':
                int.tryParse(_specializationController.text) ??
                1, // Using specialization field for years of experience
          },
          // Address info
          'address': {
            'line1': _addressController.text,
            'line2': '', // No separate field for line2 in the form
            'city': _cityController.text,
            'state': _stateController.text,
            'zip': _zipCodeController.text,
            'phone': _phoneController.text,
          },
          // Organization can be included as caregiverType
          'caregiverType': _organizationController.text,
          // Add credentials for update operation
          'credentials': {
            'email': _emailController.text,
            // No password needed for update
          },
        };

        final caregiverId = userSession?['caregiverId'] as int?;
        if (caregiverId == null) {
          throw Exception('Caregiver ID not found in user session');
        }

        // Debug the request payload
        print('🔍 Caregiver update payload: ${jsonEncode(profileData)}');

        final response = await ApiService.updateCaregiverProfile(
          caregiverId,
          profileData,
        );

        if (response.statusCode == 200) {
          final data = await _parseResponse(response);
          setState(() {
            _userProfile = CaregiverProfile.fromJson(data);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );

          // Update name in user provider
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          userProvider.updateUserName(_nameController.text);
        } else {
          print('❌ Caregiver profile update failed: ${response.statusCode}');
          print('❌ Error response: ${response.body}');
          throw Exception(
            'Failed to update caregiver profile: ${response.statusCode} - ${response.body}',
          );
        }
      } else if (_isPatient) {
        // Build patient profile data based on the expected backend structure
        final Map<String, dynamic> patientData = {
          'firstName': _nameController.text.split(' ').first,
          'lastName': _nameController.text.contains(' ')
              ? _nameController.text.split(' ').last
              : '',
          'dob': _dateOfBirthController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'gender': _genderController.text,
          'emergencyContact': _emergencyContactController.text,
          // Medical information
          'medicalInfo': {
            'conditions': _medicalConditionsController.text,
            'allergies': _allergiesController.text,
            'medications': _medicationsController.text,
          },
          // Address info
          'address': {
            'line1': _addressController.text,
            'line2': '', // No separate field for line2 in the form
            'city': _cityController.text,
            'state': _stateController.text,
            'zip': _zipCodeController.text,
            'phone': _phoneController.text,
          },
          // Add credentials for update operation
          'credentials': {
            'email': _emailController.text,
            // No password needed for update
          },
        };

        final patientId = userSession?['patientId'] as int?;
        if (patientId == null) {
          throw Exception('Patient ID not found in user session');
        }

        // Debug the request payload
        print('🔍 Patient update payload: ${jsonEncode(patientData)}');

        final response = await ApiService.updatePatientProfile(
          patientId,
          patientData,
        );

        if (response.statusCode == 200) {
          final data = await _parseResponse(response);
          setState(() {
            _userProfile = PatientProfile.fromJson(data);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );

          // Update name in user provider
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          userProvider.updateUserName(_nameController.text);
        } else {
          print('❌ Patient profile update failed: ${response.statusCode}');
          print('❌ Error response: ${response.body}');
          throw Exception(
            'Failed to update patient profile: ${response.statusCode} - ${response.body}',
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHelper.createAppBar(
        context,
        title: 'Profile Settings',
        centerTitle: true,
      ),
      drawer: const CommonDrawer(currentRoute: '/profile-settings'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget()
          : _buildProfileForm(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.error),
            const SizedBox(height: 16),
            Text(
              'Error Loading Profile',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadUserProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfilePictureSection(),
                const SizedBox(height: 24),

                // Common fields
                _buildSectionHeader('Personal Information'),
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 16),
                _buildSectionHeader('Address Information'),
                _buildTextField(
                  controller: _addressController,
                  label: 'Address',
                  prefixIcon: Icons.location_on,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _cityController,
                        label: 'City',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _stateController,
                        label: 'State/Province',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _zipCodeController,
                        label: 'ZIP/Postal Code',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _countryController,
                        label: 'Country',
                      ),
                    ),
                  ],
                ),

                // Role-specific fields
                if (_isCaregiver) ...[
                  const SizedBox(height: 16),
                  _buildSectionHeader('Professional Information'),
                  _buildTextField(
                    controller: _specializationController,
                    label: 'Specialization',
                    prefixIcon: Icons.medical_services,
                  ),
                  _buildTextField(
                    controller: _organizationController,
                    label: 'Organization',
                    prefixIcon: Icons.business,
                  ),
                  _buildTextField(
                    controller: _licenseController,
                    label: 'License Number',
                    prefixIcon: Icons.card_membership,
                  ),
                ],

                if (_isPatient) ...[
                  const SizedBox(height: 16),
                  _buildSectionHeader('Medical Information'),
                  _buildTextField(
                    controller: _dateOfBirthController,
                    label: 'Date of Birth',
                    prefixIcon: Icons.cake,
                    hintText: 'YYYY-MM-DD',
                  ),
                  _buildTextField(
                    controller: _genderController,
                    label: 'Gender',
                    prefixIcon: Icons.person_outline,
                  ),
                  _buildTextField(
                    controller: _emergencyContactController,
                    label: 'Emergency Contact',
                    prefixIcon: Icons.contacts,
                  ),
                  _buildTextField(
                    controller: _medicalConditionsController,
                    label: 'Medical Conditions',
                    prefixIcon: Icons.medical_information,
                    maxLines: 3,
                  ),
                  _buildTextField(
                    controller: _allergiesController,
                    label: 'Allergies',
                    prefixIcon: Icons.error_outline,
                    maxLines: 2,
                  ),
                  _buildTextField(
                    controller: _medicationsController,
                    label: 'Current Medications',
                    prefixIcon: Icons.medication,
                    maxLines: 3,
                  ),
                ],

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator()
                        : const Text(
                            'SAVE CHANGES',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showImagePickerOptions(),
            child: Builder(
              builder: (BuildContext context) => Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppTheme.backgroundSecondary,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!) as ImageProvider
                        : _userProfile?.profilePictureUrl != null
                        ? _getNetworkImageSafely(_userProfile.profilePictureUrl)
                        : null,
                    // Only provide onBackgroundImageError when we have a backgroundImage
                    onBackgroundImageError:
                        _imageFile != null ||
                            _userProfile?.profilePictureUrl != null
                        ? (exception, stackTrace) {
                            // Silently handle network image loading errors
                            print('Error loading profile picture: $exception');
                            // No setState needed as we'll show the fallback icon
                          }
                        : null,
                    child:
                        _userProfile?.profilePictureUrl == null &&
                            _imageFile == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: AppTheme.textSecondary,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: AppTheme.textLight,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to change profile picture',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_userProfile?.profilePictureUrl != null)
              ListTile(
                leading: Icon(Icons.delete, color: AppTheme.error),
                title: const Text('Remove current photo'),
                onTap: () {
                  Navigator.pop(context);
                  // Logic to remove profile photo would go here
                  // This would require a backend endpoint to remove the profile picture
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        const Divider(),
        const SizedBox(height: 8),
      ],
    );
  }

  // Helper method to safely create a NetworkImage or return null if URL is invalid
  ImageProvider? _getNetworkImageSafely(String? url) {
    if (url == null || url.isEmpty) return null;

    try {
      return NetworkImage(url) as ImageProvider;
    } catch (e) {
      print('Invalid image URL: $url, Error: $e');
      return null;
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
      ),
    );
  }
}
