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
import '../../../../services/subscription_service.dart';
import '../../../../widgets/responsive_page_wrapper.dart';
import '../../../../utils/responsive_utils.dart';
import 'package:care_connect_app/config/theme/app_theme.dart';
import '../../../../services/video_call_service.dart';
import '../../../../services/messaging_service.dart';
import '../../../../services/call_notification_service.dart';
import '../../../../widgets/messaging_widget.dart';
import '../../../../widgets/video_call_widget.dart';
import '../../../../widgets/call_notification_status_indicator.dart';
import 'patient_medical_notes_page.dart';

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
  String? caregiverName;

  // Real-time call notification state
  bool _callNotificationInitialized = false;

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to avoid calling setState during build
    Future.microtask(() => fetchPatients());
    _loadCaregiverName();
    _initializeServices();
    _initializeCallNotifications();
  }

  Future<void> _initializeServices() async {
    try {
      await VideoCallService.initializeService();
      await MessagingService.initialize();
    } catch (e) {
      print('Error initializing services: $e');
    }
  }

  /// Initialize real-time call notification service
  Future<void> _initializeCallNotifications() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final caregiverId = userProvider.user?.caregiverId ?? widget.caregiverId;

      print('🔔 Initializing call notifications for caregiver: $caregiverId');

      final success = await CallNotificationService.initialize(
        userId: caregiverId.toString(),
        userRole: userProvider.user?.role.toUpperCase() ?? 'CAREGIVER',
        context: context,
      );

      setState(() {
        _callNotificationInitialized = success;
      });

      if (success) {
        print('✅ Call notification service initialized successfully');

        // Listen to incoming call stream for additional handling if needed
        CallNotificationService.incomingCallStream.listen((callData) {
          print('📞 Caregiver dashboard received call notification: $callData');
          // You can add additional logic here if needed
        });
      } else {
        print('❌ Failed to initialize call notification service');
      }
    } catch (e) {
      print('❌ Error initializing call notifications: $e');
    }
  }

  Future<void> _loadCaregiverName() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user?.name != null) {
        setState(() {
          caregiverName = userProvider.user!.name;
        });
      }
    } catch (e) {
      print('Error loading caregiver name: $e');
    }
  }

  @override
  void didUpdateWidget(CaregiverDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only refresh if the caregiverId changed
    if (oldWidget.caregiverId != widget.caregiverId) {
      fetchPatients();
    }
  }

  @override
  void dispose() {
    // Clean up call notification service
    CallNotificationService.dispose();
    super.dispose();
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

              // Add mock vital conditions for demonstration if not present
              if (patient.vitalConditions == null ||
                  patient.gender == null ||
                  patient.allergies == null) {
                // Create a modified patient with mock data
                final patientWithData = Patient(
                  id: patient.id,
                  firstName: patient.firstName,
                  lastName: patient.lastName,
                  email: patient.email,
                  phone: patient.phone,
                  dob: patient.dob,
                  relationship: patient.relationship,
                  profileImageUrl: patient.profileImageUrl,
                  address: patient.address,
                  linkId: patient.linkId,
                  linkStatus: patient.linkStatus,
                  gender:
                      patient.gender ??
                      (patient.id % 2 == 0 ? 'Female' : 'Male'),
                  allergies:
                      patient.allergies ??
                      <String>[], // Use empty list instead of mock data
                  vitalConditions:
                      patient.vitalConditions ??
                      {
                        'heartRate': (60 + (patient.id * 7) % 40)
                            .toString(), // Mock HR between 60-100
                        'bloodPressure':
                            '${120 + (patient.id * 3) % 20}/${80 + (patient.id * 2) % 10}', // Mock BP
                        'temperature': (98.6 + (patient.id % 3 - 1) * 0.5)
                            .toStringAsFixed(1), // Mock temp
                        'oxygenSaturation': (95 + (patient.id * 2) % 5)
                            .toString(), // Mock O2 sat
                      },
                );
                parsedPatients.add(patientWithData);
              } else {
                parsedPatients.add(patient);
              }
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

  // Helper method to format vital conditions summary
  String _getVitalConditionsSummary(Patient patient) {
    if (patient.vitalConditions == null || patient.vitalConditions!.isEmpty) {
      return 'No vital data available';
    }

    final vitals = patient.vitalConditions!;
    List<String> summaryItems = [];

    // Check for heart rate
    if (vitals.containsKey('heartRate')) {
      final hr = vitals['heartRate'];
      if (hr != null) {
        final status = _getVitalStatus(hr, 'heartRate');
        summaryItems.add('HR: $hr bpm $status');
      }
    }

    // Check for blood pressure
    if (vitals.containsKey('bloodPressure')) {
      final bp = vitals['bloodPressure'];
      if (bp != null) {
        final status = _getVitalStatus(bp, 'bloodPressure');
        summaryItems.add('BP: $bp $status');
      }
    }

    // Check for temperature
    if (vitals.containsKey('temperature')) {
      final temp = vitals['temperature'];
      if (temp != null) {
        final status = _getVitalStatus(temp, 'temperature');
        summaryItems.add('Temp: $temp°F $status');
      }
    }

    // Check for oxygen saturation
    if (vitals.containsKey('oxygenSaturation')) {
      final o2 = vitals['oxygenSaturation'];
      if (o2 != null) {
        final status = _getVitalStatus(o2, 'oxygenSaturation');
        summaryItems.add('O2: $o2% $status');
      }
    }

    return summaryItems.isNotEmpty
        ? summaryItems
              .take(2)
              .join(', ') // Show max 2 vitals to avoid overcrowding
        : 'Vitals monitoring active';
  }

  // Helper method to determine vital status (normal, high, low)
  String _getVitalStatus(dynamic value, String type) {
    if (value == null) return '';

    try {
      final numValue = double.tryParse(value.toString()) ?? 0.0;

      switch (type) {
        case 'heartRate':
          if (numValue >= 60 && numValue <= 100) return '✓';
          if (numValue > 100) return '⚠️';
          if (numValue < 60) return '⚠️';
          break;
        case 'temperature':
          if (numValue >= 97.0 && numValue <= 99.5) return '✓';
          if (numValue > 99.5) return '🔥';
          if (numValue < 97.0) return '❄️';
          break;
        case 'oxygenSaturation':
          if (numValue >= 95) return '✓';
          if (numValue < 95) return '⚠️';
          break;
        case 'bloodPressure':
          // For blood pressure, we'll just show checkmark for now
          // As it's typically in format "120/80"
          return '✓';
      }
    } catch (e) {
      // If parsing fails, just return empty
      return '';
    }

    return '';
  }

  // Initiate video/audio call with patient
  Future<void> _initiateCall(Patient patient, bool isVideoCall) async {
    try {
      // Check subscription access for caregivers before initiating call
      final canUseVideoCalls =
          await SubscriptionService.checkPremiumAccessWithDialog(
            context,
            isVideoCall ? 'Video Calls' : 'Voice Calls',
          );

      if (!canUseVideoCalls) {
        return; // User doesn't have premium access, dialog was shown
      }

      // Check if patient is available for call
      final isAvailable = await VideoCallService.checkUserAvailability(
        patient.id.toString(),
      );
      if (!isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${patient.firstName} is currently unavailable'),
          ),
        );
        return;
      }

      // Generate unique call ID
      final callId = 'call_${DateTime.now().millisecondsSinceEpoch}';

      // Send real-time call notification to patient
      final notificationSent = await CallNotificationService.sendCallInvitation(
        recipientId: patient.id.toString(),
        recipientRole: 'PATIENT',
        callId: callId,
        isVideoCall: isVideoCall,
      );

      if (!notificationSent) {
        print(
          '⚠️ Failed to send real-time notification, falling back to standard method',
        );
      }

      // Also use the existing video call service for backward compatibility
      final callData = await VideoCallService.initiateCall(
        callId: callId,
        callerId: widget.caregiverId.toString(),
        recipientId: patient.id.toString(),
        isVideoCall: isVideoCall,
      );

      if (callData['success'] == true) {
        // Navigate to video call screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VideoCallWidget(
              callId: callData['callId'],
              currentUserId: widget.caregiverId.toString(),
              currentUserName: caregiverName ?? 'Caregiver',
              otherUserId: patient.id.toString(),
              otherUserName: '${patient.firstName} ${patient.lastName}',
              isVideoCall: isVideoCall,
              isIncoming: false,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to initiate call. Please try again.'),
          ),
        );
      }
    } catch (e) {
      print('Error initiating call: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error initiating call. Please check your connection.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get user provider for context

    // Use the responsive utilities for screen size detection
    final isLargeScreen = context.isLargeDesktop;

    return ResponsiveScaffold(
      title: caregiverName != null
          ? 'Welcome, $caregiverName'
          : 'Caregiver Dashboard',
      // Optionally add responsive elements to app bar for large screens
      appBarActions: isLargeScreen
          ? [
              // Call notification status indicator
              CallNotificationStatusIndicator(
                isInitialized: _callNotificationInitialized,
              ),
              const SizedBox(width: 12),
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
          : [
              // For smaller screens, show status indicator in actions
              CallNotificationStatusIndicator(
                isInitialized: _callNotificationInitialized,
              ),
              const SizedBox(width: 8),
            ],
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
              onPressed: () async {
                // Check subscription for caregivers before showing AI chat
                final hasAccess =
                    await SubscriptionService.checkPremiumAccessWithDialog(
                      context,
                      'AI Assistant is only available with premium subscriptions.',
                    );
                if (!hasAccess) return;

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
              const Text(
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
                style: AppTheme.primaryButtonStyle.copyWith(
                  // Ensure proper button sizing for touch
                  minimumSize: WidgetStateProperty.all(const Size(150, 48)),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                icon: const Icon(Icons.person_add),
                label: const Text('Add Patient'),
                onPressed: () {
                  print(
                    '🔍 Add Patient (empty state) button pressed',
                  ); // Debug print
                  try {
                    context.go('/add-patient');
                  } catch (e) {
                    print('🔍 Navigation error: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Navigation error. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Your Patients', style: AppTheme.headingSmall),
                    ElevatedButton.icon(
                      onPressed: () {
                        print('🔍 Add Patient button pressed'); // Debug print
                        try {
                          Navigator.pushNamed(context, '/add-patient').then((
                            _,
                          ) {
                            print('🔍 Returned from add patient screen');
                            // Refresh patient list when returning from add patient screen
                            fetchPatients();
                          });
                        } catch (e) {
                          print('🔍 Navigation error: $e');
                          // Fallback to context.go if pushNamed fails
                          try {
                            context.go('/add-patient');
                          } catch (e2) {
                            print('🔍 Secondary navigation error: $e2');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Navigation error. Please try again.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add Patient'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        // Ensure proper button sizing for touch
                        minimumSize: const Size(120, 40),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
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

    // Ensure we have at least 1 column and limit to 2 columns max for wider patient cards
    if (crossAxisCount > 2) {
      crossAxisCount =
          2; // Limit to 2 columns max for patient cards to make them wider
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, 16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.85, // Make cards taller and more readable
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
      mobile: 35.0,
      desktop: 45.0,
    );

    return Card(
      margin: isGridView ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(20),
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
                  fontSize: isGridView ? 28 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              "${patient.firstName} ${patient.lastName}",
              style: AppTheme.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
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
                          ? 'Age ${_calculateAgeFromDob(patient.dob)}'
                          : 'Age not specified',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      patient.gender?.isNotEmpty == true
                          ? patient.gender!
                          : 'Gender not specified',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
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
                      Icons.warning_amber,
                      size: 16,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        patient.allergies?.isNotEmpty == true
                            ? 'Allergies: ${patient.allergies!.join(', ')}'
                            : 'No allergies listed',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Theme.of(context).hintColor,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Vital conditions summary
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _getVitalConditionsSummary(patient),
                        style: AppTheme.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Check if we need scrollable layout for mobile
                final isMobile = constraints.maxWidth < 500;

                if (isMobile) {
                  // Use horizontal scrolling for mobile
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildActionButton(
                          icon: Icons.videocam,
                          label: 'Call',
                          onPressed: () async {
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

                            // Show call type selection
                            final callType = await showDialog<String>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Choose Call Type'),
                                content: const Text(
                                  'Would you like to make a video call or audio call?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop('audio'),
                                    child: const Text('Audio Call'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop('video'),
                                    child: const Text('Video Call'),
                                  ),
                                ],
                              ),
                            );

                            if (callType != null) {
                              await _initiateCall(patient, callType == 'video');
                            }
                          },
                        ),
                        const SizedBox(
                          width: 16,
                        ), // Add spacing between buttons
                        _buildActionButton(
                          icon: Icons.message,
                          label: 'Message',
                          onPressed: () async {
                            // Open messaging widget
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MessagingWidget(
                                  currentUserId: widget.caregiverId.toString(),
                                  currentUserName: caregiverName ?? 'Caregiver',
                                  recipientId: patient.id.toString(),
                                  recipientName:
                                      '${patient.firstName} ${patient.lastName}',
                                ),
                              ),
                            );

                            // Handle result if user triggered a call from messaging
                            if (result == 'video_call') {
                              await _initiateCall(patient, true);
                            } else if (result == 'audio_call') {
                              await _initiateCall(patient, false);
                            }
                          },
                        ),
                        const SizedBox(width: 16),
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
                        const SizedBox(width: 16),
                        _buildActionButton(
                          icon: Icons.medical_information,
                          label: 'Medical Notes',
                          onPressed: () {
                            // Navigate to medical notes page
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PatientMedicalNotesPage(
                                  patientId: patient.id,
                                  patientName:
                                      '${patient.firstName} ${patient.lastName}',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  // Use traditional row layout for larger screens
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(
                        icon: Icons.videocam,
                        label: 'Call',
                        onPressed: () async {
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

                          final callType = await showDialog<String>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Choose Call Type'),
                              content: const Text(
                                'Would you like to make a video call or audio call?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop('audio'),
                                  child: const Text('Audio Call'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop('video'),
                                  child: const Text('Video Call'),
                                ),
                              ],
                            ),
                          );

                          if (callType != null) {
                            await _initiateCall(patient, callType == 'video');
                          }
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.message,
                        label: 'Message',
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MessagingWidget(
                                currentUserId: widget.caregiverId.toString(),
                                currentUserName: caregiverName ?? 'Caregiver',
                                recipientId: patient.id.toString(),
                                recipientName:
                                    '${patient.firstName} ${patient.lastName}',
                              ),
                            ),
                          );

                          if (result == 'video_call') {
                            await _initiateCall(patient, true);
                          } else if (result == 'audio_call') {
                            await _initiateCall(patient, false);
                          }
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.analytics,
                        label: 'Analytics',
                        onPressed: () {
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
                      _buildActionButton(
                        icon: Icons.medical_information,
                        label: 'Medical Notes',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PatientMedicalNotesPage(
                                patientId: patient.id,
                                patientName:
                                    '${patient.firstName} ${patient.lastName}',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
              },
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = MediaQuery.of(context).size.width < 500;

        return InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 8 : 12,
              horizontal: isMobile ? 12 : 16,
            ),
            constraints: BoxConstraints(
              minWidth: isMobile ? 70 : 80,
              maxWidth: isMobile ? 85 : 120,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: isMobile ? 20 : 24,
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  label,
                  style: AppTheme.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 11 : 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
