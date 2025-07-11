import 'package:flutter/material.dart';
import 'package:fitbitter/fitbitter.dart';
import 'package:health/health.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  int currentStep = 0;
  String? selectedPlatform;
  bool isConnecting = false;
  bool isConnected = false;
  String? errorMessage;

  // Fitbit configuration - you'll need to get these from Fitbit Dev Console
  static const String fitbitClientId = '23QG9C';
  static const String fitbitClientSecret = 'c77f0a7a3839a9307674b893fae14934';
  static const String redirectUri = 'care-connect://fitbit-auth';

  final List<Map<String, dynamic>> healthPlatforms = [
    {
      'id': 'fitbit',
      'name': 'Fitbit',
      'description': 'Connect your Fitbit device to track steps, heart rate, sleep, and more',
      'icon': Icons.fitness_center,
      'color': Colors.green,
      'features': ['Steps', 'Heart Rate', 'Sleep', 'Calories', 'Distance'],
    },
    {
      'id': 'apple_health',
      'name': 'Apple Health',
      'description': 'Sync data from Apple Health app and connected devices',
      'icon': Icons.favorite,
      'color': Colors.red,
      'features': ['All Health Metrics', 'Medical Records', 'Medications', 'Workouts'],
    },
    {
      'id': 'google_fit',
      'name': 'Google Fit',
      'description': 'Connect Google Fit to track activities and health data',
      'icon': Icons.directions_run,
      'color': Colors.blue,
      'features': ['Activities', 'Weight', 'Nutrition', 'Heart Points'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Health Platform'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildStepIndicator(0, 'Select', currentStep >= 0),
                _buildStepLine(currentStep >= 1),
                _buildStepIndicator(1, 'Connect', currentStep >= 1),
                _buildStepLine(currentStep >= 2),
                _buildStepIndicator(2, 'Complete', currentStep >= 2),
              ],
            ),
          ),

          // Content Area
          Expanded(
            child: _buildStepContent(),
          ),

          // Bottom Action Button
          if (currentStep < 2) _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.indigo : Colors.grey[300],
            border: Border.all(
              color: isActive ? Colors.indigo : Colors.grey[400]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.indigo : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 30),
        color: isActive ? Colors.indigo : Colors.grey[300],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return _buildSelectPlatformStep();
      case 1:
        return _buildConnectStep();
      case 2:
        return _buildCompleteStep();
      default:
        return _buildSelectPlatformStep();
    }
  }

  Widget _buildSelectPlatformStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Health Platform',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select which health platform you\'d like to connect to track patient data.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: healthPlatforms.map((platform) {
                  final isSelected = selectedPlatform == platform['id'];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: isSelected ? 6 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? Colors.indigo : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedPlatform = platform['id'];
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: platform['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                platform['icon'],
                                color: platform['color'],
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    platform['name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    platform['description'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isSelected)
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Colors.indigo,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectStep() {
    final selectedPlatformData = healthPlatforms.firstWhere(
          (platform) => platform['id'] == selectedPlatform,
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Connect to Platform',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 24),

          // Platform Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: selectedPlatformData['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      selectedPlatformData['icon'],
                      color: selectedPlatformData['color'],
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    selectedPlatformData['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedPlatformData['description'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Connection Status
          if (isConnecting)
            Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Connecting to ${selectedPlatformData['name']}...',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please complete authorization in your browser',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            )
          else if (isConnected)
            Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Connected to ${selectedPlatformData['name']}!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Data sync will begin automatically',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            )
          else if (errorMessage != null)
              Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Connection Failed',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        errorMessage = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                    child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ready to Connect',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                              Text(
                                'You\'ll be redirected to ${selectedPlatformData['name']} to authorize access.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildCompleteStep() {
    final selectedPlatformData = healthPlatforms.firstWhere(
          (platform) => platform['id'] == selectedPlatform,
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Spacer(),

          // Success Animation
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'Successfully Connected!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            '${selectedPlatformData['name']} has been connected to your patient\'s profile.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 32),

          // Data Sync Info
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.sync,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Data Sync Started',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Health data will appear in the dashboard within 24 hours',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Action Buttons
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Back to Dashboard',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    // Reset and add another device
                    setState(() {
                      currentStep = 0;
                      selectedPlatform = null;
                      isConnecting = false;
                      isConnected = false;
                    });
                  },
                  child: const Text(
                    'Add Another Platform',
                    style: TextStyle(
                      color: Colors.indigo,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _getButtonAction(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            _getButtonText(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  String _getButtonText() {
    switch (currentStep) {
      case 0:
        return selectedPlatform != null ? 'Continue' : 'Select a Platform';
      case 1:
        if (isConnecting) return 'Connecting...';
        if (isConnected) return 'Continue';
        return 'Connect Now';
      default:
        return 'Continue';
    }
  }

  VoidCallback? _getButtonAction() {
    switch (currentStep) {
      case 0:
        return selectedPlatform != null
            ? () {
          setState(() {
            currentStep = 1;
          });
        }
            : null;
      case 1:
        if (isConnecting) return null;
        if (isConnected) {
          return () {
            setState(() {
              currentStep = 2;
            });
          };
        }
        return () {
          setState(() {
            isConnecting = true;
            errorMessage = null;
          });

          // Handle different platforms
          if (selectedPlatform == 'fitbit') {
            _connectToFitbit();
          } else if (selectedPlatform == 'apple_health') {
            _connectToAppleHealth();
          } else if (selectedPlatform == 'google_fit') {
            _connectToGoogleFit();
          }
        };
      default:
        return null;
    }
  }

  // Fitbit Connection Methods
  Future<void> _connectToFitbit() async {
    try {
      print('Starting Fitbit connection...');

      // For now, simulate the Fitbit OAuth flow
      // TODO: Replace with actual fitbitter implementation
      await _connectToFitbitReal();

    } catch (e) {
      print('Fitbit connection error: $e');
      setState(() {
        isConnecting = false;
        errorMessage = 'Failed to connect to Fitbit. Please try again.';
      });
    }
  }

  Future<void> _simulateFitbitAuth() async {
    // Simulate OAuth flow
    await Future.delayed(const Duration(seconds: 2));

    // Simulate successful authorization
    setState(() {
      isConnecting = false;
      isConnected = true;
    });

    print('Fitbit connection successful (simulated)');
  }

  // Real Fitbit implementation (uncomment when you add fitbitter package)

  Future<void> _connectToFitbitReal() async {
    try {
      // Initialize Fitbitter

      FitbitCredentials? fitbitCredentials =
      await FitbitConnector.authorize(
          clientID: fitbitClientId,
          clientSecret: fitbitClientSecret,
          redirectUri: redirectUri,
          callbackUrlScheme: 'care-connect',
      );

      if (fitbitCredentials != null) {
        // Get access token
        String accessToken = fitbitCredentials.fitbitAccessToken;

        if (accessToken != null) {
          // Store the access token securely
          await _storeAccessToken('fitbit', accessToken);

          setState(() {
            isConnecting = false;
            isConnected = true;
          });

          print('Fitbit connected successfully');
        } else {
          throw Exception('Failed to get access token');
        }
      } else {
        throw Exception('Authorization was cancelled');
      }
    } catch (e) {
      print('Fitbit connection error: $e');
      setState(() {
        isConnecting = false;
        errorMessage = 'Failed to connect to Fitbit: ${e.toString()}';
      });
    }
  }


  Future<void> _connectToAppleHealth() async {
    try {
      print('Starting Apple Health connection...');

      // Simulate Apple Health connection
      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        isConnecting = false;
        isConnected = true;
      });

      print('Apple Health connection successful (simulated)');

    } catch (e) {
      setState(() {
        isConnecting = false;
        errorMessage = 'Failed to connect to Apple Health. Please try again.';
      });
    }
  }

  Future<void> _connectToAppleHealthReal() async {
    try {
      print('Starting Apple Health connection...');

      setState(() {
        isConnecting = true;
        errorMessage = null;
      });

      // Define the types of health data we want to access
      List<HealthDataType> types = [
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
        HealthDataType.SLEEP_IN_BED,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.DISTANCE_WALKING_RUNNING,
        HealthDataType.BODY_MASS_INDEX,
        HealthDataType.WEIGHT,
      ];

      // Request authorization for the specified data types
      bool requested = await Health().requestAuthorization(
        types,
        permissions: [
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
        ],
      );

      if (requested) {
        // Check if we actually have permissions
        bool hasPermissions = await Health().hasPermissions(types) ?? false;

        if (hasPermissions) {
          // Store successful connection info
          await _storeAccessToken('apple_health', 'apple_health_authorized');

          setState(() {
            isConnecting = false;
            isConnected = true;
          });

          print('Apple Health connected successfully');
        } else {
          throw Exception('Apple Health permissions were denied');
        }
      } else {
        throw Exception('Failed to request Apple Health permissions');
      }

    } catch (e) {
      print('Apple Health connection error: $e');
      setState(() {
        isConnecting = false;
        // errorMessage = _getHealthErrorMessage(e, 'Apple Health');
      });
    }
  }

  Future<void> _connectToGoogleFit() async {
    try {
      print('Starting Google Fit connection...');

      // Simulate Google Fit connection
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        isConnecting = false;
        isConnected = true;
      });

      print('Google Fit connection successful (simulated)');

    } catch (e) {
      setState(() {
        isConnecting = false;
        errorMessage = 'Failed to connect to Google Fit. Please try again.';
      });
    }
  }

  Future<void> _connectToGoogleFitReal() async {
    try {
      print('Starting Google Fit connection...');

      setState(() {
        isConnecting = true;
        errorMessage = null;
      });

      // Define the types of health data we want to access
      List<HealthDataType> types = [
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
        HealthDataType.SLEEP_IN_BED,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.DISTANCE_WALKING_RUNNING,
        HealthDataType.WEIGHT,
      ];

      // Request authorization for the specified data types
      bool requested = await Health().requestAuthorization(
        types,
        permissions: [
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
        ],
      );

      if (requested) {
        // Check if we actually have permissions
        bool hasPermissions = await Health().hasPermissions(types) ?? false;

        if (hasPermissions) {
          // Store successful connection info
          await _storeAccessToken('google_fit', 'google_fit_authorized');

          setState(() {
            isConnecting = false;
            isConnected = true;
          });

          print('Google Fit connected successfully');
        } else {
          throw Exception('Google Fit permissions were denied');
        }
      } else {
        throw Exception('Failed to request Google Fit permissions');
      }

    } catch (e) {
      print('Google Fit connection error: $e');
      setState(() {
        isConnecting = false;
        // errorMessage = _getHealthErrorMessage(e, 'Google Fit');
      });
    }
  }

  Future<void> _storeAccessToken(String platform, String token) async {
    // TODO: Store the access token securely using flutter_secure_storage
    print('Storing $platform access token: ${token.substring(0, 10)}...');
  }
}

