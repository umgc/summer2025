import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import '../../models/patient_model.dart';
import 'package:provider/provider.dart';
import 'package:care_connect_app/providers/user_provider.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'package:care_connect_app/services/auth_token_manager.dart';
import 'package:http/http.dart' as http;
import '../../../../widgets/ai_chat_improved.dart';
import '../../../../widgets/responsive_page_wrapper.dart';
import '../../../../utils/responsive_utils.dart';
import 'package:care_connect_app/config/theme/app_theme.dart';

class CaregiverDashboard extends StatefulWidget {
  final String userRole;
  final int? patientId;
  final int caregiverId;

  const CaregiverDashboard({
    super.key,
    this.userRole = 'CAREGIVER',
    this.patientId,
    this.caregiverId = 1,
  });

  @override
  State<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {
  List<Patient> patients = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to avoid calling setState during build
    Future.microtask(() => fetchPatients());
  }

  @override
  void didUpdateWidget(CaregiverDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only refresh if the caregiverId changed
    if (oldWidget.caregiverId != widget.caregiverId) {
      fetchPatients();
    }
  }

  Future<void> fetchPatients() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final caregiverId = userProvider.user?.caregiverId ?? widget.caregiverId;

      // Get auth headers
      final headers = await AuthTokenManager.getAuthHeaders();

      // Use ApiConstants for the URL
      final baseUrl = ApiConstants.baseUrl;
      final url = Uri.parse('${baseUrl}caregivers/$caregiverId/patients');
      print('🔍 Fetching patients from: $url');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('🔍 Received patient data: $data');

        // Safely parse each patient, skipping any that cause errors
        List<Patient> parsedPatients = [];
        for (var json in data) {
          try {
            // Check if we have a nested structure
            if (json.containsKey('patient') &&
                json['patient'] is Map<String, dynamic>) {
              print('🔍 Found nested patient data structure');

              // Extract link info if available
              if (json.containsKey('link') &&
                  json['link'] is Map<String, dynamic>) {
                final link = json['link'] as Map<String, dynamic>;
                if (link.containsKey('id')) {
                  json['linkId'] = link['id'];
                  json['linkStatus'] = link['status'] ?? 'ACTIVE';
                  print(
                    '🔍 Extracted link info: ID=${link['id']}, status=${link['status']}',
                  );
                }
              }
            }

            final patient = Patient.fromJson(json);
            if (patient.id <= 0) {
              print(
                '⚠️ Warning: Parsed patient has invalid ID (${patient.id}): $json',
              );
            } else {
              print(
                '✅ Successfully parsed patient with ID: ${patient.id}, name: ${patient.firstName} ${patient.lastName}',
              );
              parsedPatients.add(patient);
            }
          } catch (e) {
            print('❌ Error parsing patient: $e, data: $json');
          }
        }

        setState(() {
          patients = parsedPatients;
          loading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load patients. Status: ${response.statusCode}';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        loading = false;
      });
    }
  }

  // Calculate age from date of birth
  int _calculateAgeFromDob(String dob) {
    if (dob.isEmpty) {
      return 0;
    }

    try {
      // Parse MM/DD/YYYY format
      final parts = dob.split('/');
      if (parts.length != 3) {
        print('🔍 Invalid DOB format: $dob');
        return 0;
      }

      final month = int.tryParse(parts[0]);
      final day = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);

      if (month == null || day == null || year == null) {
        print('🔍 Could not parse date parts from DOB: $dob');
        return 0;
      }

      final birthDate = DateTime(year, month, day);
      final today = DateTime.now();

      int age = today.year - birthDate.year;

      // Adjust age if birthday hasn't occurred yet this year
      final birthMonth = birthDate.month;
      final birthDay = birthDate.day;
      final currentMonth = today.month;
      final currentDay = today.day;

      if (currentMonth < birthMonth ||
          (currentMonth == birthMonth && currentDay < birthDay)) {
        age--;
      }

      // Sanity check - ages should be reasonable
      if (age < 0 || age > 120) {
        print('🔍 Unusual age calculated: $age from DOB: $dob');
        return 0;
      }

      return age;
    } catch (e) {
      // Log the error for debugging
      print('🔍 Error calculating age from DOB: $dob, error: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get user provider for context

    // Use the responsive utilities for screen size detection
    final isLargeScreen = context.isLargeDesktop;

    return ResponsiveScaffold(
      title: 'Caregiver Dashboard',
      // Optionally add responsive elements to app bar for large screens
      appBarActions: isLargeScreen
          ? [
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () {
                  // Show help dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Help documentation coming soon'),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ]
          : null,
      currentRoute: '/dashboard',
      body: Stack(
        children: [
          // The ResponsiveScaffold already handles content centering and constraints
          _buildMainContent(),

          // Always show AI Chat button at the bottom right
          // Using responsive utils for positioning
          Positioned(
            right: context.responsiveValue(
              mobile: 16.0,
              tablet: 24.0,
              desktop: 32.0,
            ),
            bottom: context.responsiveValue(
              mobile: 16.0,
              tablet: 24.0,
              desktop: 32.0,
            ),
            child: FloatingActionButton(
              heroTag: 'chatButton',
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.chat,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                // Use responsive height for the sheet based on screen size
                double sheetHeight = context.responsiveValue(
                  mobile: MediaQuery.of(context).size.height * 0.75,
                  desktop: MediaQuery.of(context).size.height * 0.8,
                );

                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width,
                  ),
                  builder: (context) => SizedBox(
                    height: sheetHeight,
                    child: const AIChat(role: 'caregiver', isModal: true),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Removed "Add Patient" floating action button as requested
    );
  }

  // Extract main content to a separate method for better organization
  Widget _buildMainContent() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error Loading Patients',
                style: AppTheme.headingSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: fetchPatients,
                style: AppTheme.primaryButtonStyle,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    } else if (patients.isEmpty) {
      return _buildEmptyState();
    } else {
      return _buildPatientList();
    }
  }

  Widget _buildEmptyState() {
    // Use responsive utils for width calculation
    final isMobile = context.isMobile;

    // Create a container with responsive width
    return Center(
      child: Container(
        width: context.responsiveValue(
          mobile: MediaQuery.of(context).size.width * 0.85,
          tablet: 400.0,
        ),
        padding: const EdgeInsets.all(24),
        decoration: !isMobile
            ? BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_search,
              size: context.responsiveValue(mobile: 80.0, tablet: 96.0),
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 24),
            Text(
              'No patients yet',
              style: AppTheme.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Add patients to begin monitoring',
              style: AppTheme.bodyLarge.copyWith(
                color: Theme.of(context).hintColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: context.responsiveValue(
                mobile: double.infinity,
                tablet: 200.0,
              ),
              child: ElevatedButton.icon(
                style: AppTheme.primaryButtonStyle,
                icon: const Icon(Icons.person_add),
                label: const Text('Add Patient'),
                onPressed: () => context.go('/add-patient'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientList() {
    // Use responsive utils for margins
    final horizontalMargin = context.horizontalMargin;

    return RefreshIndicator(
      onRefresh: fetchPatients,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontalMargin,
              16.0,
              horizontalMargin,
              8.0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text('Your Patients', style: AppTheme.headingSmall),
                const SizedBox(height: 8),
                Text(
                  'Showing ${patients.length} patients',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),
          // Use responsive grid for larger screens or list for smaller screens
          context.isDesktopOrLarger
              ? _buildResponsivePatientGrid(horizontalMargin)
              : SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalMargin,
                    0,
                    horizontalMargin,
                    16,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final patient = patients[index];
                      return _buildPatientCard(patient);
                    }, childCount: patients.length),
                  ),
                ),
        ],
      ),
    );
  }

  // New method to create a responsive grid for larger screens
  Widget _buildResponsivePatientGrid(double horizontalMargin) {
    // Use responsive utils to get the grid column count
    int crossAxisCount = context.gridColumns;

    // Ensure we have at least 1 column
    if (crossAxisCount > 3) {
      crossAxisCount = 3; // Limit to 3 columns max for patient cards
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, 16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.1,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final patient = patients[index];
          return _buildPatientCard(patient);
        }, childCount: patients.length),
      ),
    );
  }

  Widget _buildPatientCard(Patient patient) {
    // Use responsive utils for device type detection
    final bool isGridView = context.isDesktopOrLarger;

    // Use responsive values for avatar sizes
    final double avatarSize = context.responsiveValue(
      mobile: 30.0,
      desktop: 40.0,
    );

    return Card(
      margin: isGridView ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: avatarSize,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.2),
              child: Text(
                patient.firstName.isNotEmpty
                    ? patient.firstName.substring(0, 1).toUpperCase()
                    : patient.lastName.isNotEmpty
                    ? patient.lastName.substring(0, 1).toUpperCase()
                    : '?',
                style: AppTheme.headingSmall.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: isGridView ? 24 : 20,
                ),
              ),
            ),
            title: Text(
              "${patient.firstName} ${patient.lastName}",
              style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.cake,
                      size: 16,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      patient.dob.isNotEmpty
                          ? '${_calculateAgeFromDob(patient.dob)} years old'
                          : 'N/A',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.family_restroom,
                      size: 16,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      patient.relationship.isNotEmpty
                          ? patient.relationship
                          : 'Patient',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.healing,
                      size: 16,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'No conditions listed',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onSelected: (value) async {
                // Verify we have a valid patient ID and linkId before taking action
                if (patient.id <= 0) {
                  print('⚠️ Warning: Invalid patient ID: ${patient.id}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error: Invalid patient ID')),
                  );
                  return;
                }

                if (value == 'view') {
                  print('✅ Navigating to patient profile: ${patient.id}');
                  context.go('/patient/${patient.id}');
                } else if (value == 'suspend') {
                  // Show confirmation dialog
                  final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Suspend Relationship'),
                      content: Text(
                        'Are you sure you want to suspend your relationship with ${patient.firstName} ${patient.lastName}?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('SUSPEND'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    try {
                      final linkId = patient.linkId;
                      if (linkId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error: Missing link ID'),
                          ),
                        );
                        return;
                      }

                      final response =
                          await ApiService.suspendCaregiverPatientLink(linkId);
                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Relationship with ${patient.firstName} suspended',
                            ),
                          ),
                        );
                        fetchPatients(); // Refresh the patient list
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to suspend relationship: ${response.statusCode}',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                } else if (value == 'reactivate') {
                  // Show confirmation dialog
                  final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Reactivate Relationship'),
                      content: Text(
                        'Do you want to reactivate your relationship with ${patient.firstName} ${patient.lastName}?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('REACTIVATE'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    try {
                      final linkId = patient.linkId;
                      if (linkId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error: Missing link ID'),
                          ),
                        );
                        return;
                      }

                      final response =
                          await ApiService.reactivateCaregiverPatientLink(
                            linkId,
                          );
                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Relationship with ${patient.firstName} reactivated',
                            ),
                          ),
                        );
                        fetchPatients(); // Refresh the patient list
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to reactivate relationship: ${response.statusCode}',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text('View Profile'),
                    ],
                  ),
                ),
                if (patient.linkStatus.toUpperCase() == 'ACTIVE')
                  PopupMenuItem<String>(
                    value: 'suspend',
                    child: Row(
                      children: [
                        Icon(
                          Icons.pause_circle_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        const Text('Suspend Relationship'),
                      ],
                    ),
                  ),
                if (patient.linkStatus.toUpperCase() == 'SUSPENDED')
                  PopupMenuItem<String>(
                    value: 'reactivate',
                    child: Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        const Text('Reactivate Relationship'),
                      ],
                    ),
                  ),
              ],
            ),
            onTap: () {
              // Verify we have a valid patient ID before navigating
              if (patient.id <= 0) {
                print(
                  '⚠️ Warning: Attempted to navigate to patient profile with invalid ID: ${patient.id}',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error: Invalid patient ID')),
                );
                return;
              }

              print('✅ Navigating to patient profile: ${patient.id}');
              context.go('/patient/${patient.id}');
            },
          ),
          // Status indicators removed as per design update
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Only showing patient link status
                Row(
                  children: [
                    Icon(
                      patient.linkStatus == 'ACTIVE'
                          ? Icons.check_circle
                          : Icons.pause_circle_filled,
                      color: patient.linkStatus == 'ACTIVE'
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).disabledColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      patient.linkStatus == 'ACTIVE'
                          ? 'Active'
                          : patient.linkStatus,
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: patient.linkStatus == 'ACTIVE'
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).disabledColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.videocam,
                  label: 'Call',
                  onPressed: () {
                    // Verify we have a valid patient ID before navigating
                    if (patient.id <= 0) {
                      print(
                        '⚠️ Warning: Attempted to initiate video call with invalid patient ID: ${patient.id}',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error: Invalid patient ID'),
                        ),
                      );
                      return;
                    }

                    print(
                      '✅ Initiating video call with patient: ${patient.id}',
                    );
                    context.go(
                      '/video-call?patientId=${patient.id}&patientName=${Uri.encodeComponent("${patient.firstName} ${patient.lastName}")}',
                    );
                  },
                ),
                _buildActionButton(
                  icon: Icons.message,
                  label: 'Message',
                  onPressed: () {
                    // To be implemented - messaging feature
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Messaging feature coming soon!'),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  icon: Icons.analytics,
                  label: 'Analytics',
                  onPressed: () {
                    // Verify we have a valid patient ID before navigating
                    if (patient.id <= 0) {
                      print(
                        '⚠️ Warning: Attempted to navigate to analytics with invalid patient ID: ${patient.id}',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error: Invalid patient ID'),
                        ),
                      );
                      return;
                    }

                    print(
                      '✅ Navigating to analytics for patient: ${patient.id}',
                    );
                    context.go('/analytics?patientId=${patient.id}');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // _buildStatusIndicator method removed as per design update
  /* 
  Widget _buildStatusIndicator({
    required String title,
    required String status,
  }) {
    // Implementation removed
  }
  */

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
