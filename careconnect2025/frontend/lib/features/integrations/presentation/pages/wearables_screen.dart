import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:health/health.dart';
import 'package:fitbitter/fitbitter.dart';

import 'add_devices_screen.dart';

class ConnectedDevice {
  final String id;
  final String platform;
  final String name;
  final DateTime connectedAt;
  final List<String> permissions;
  final bool isActive;

  ConnectedDevice({
    required this.id,
    required this.platform,
    required this.name,
    required this.connectedAt,
    required this.permissions,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'platform': platform,
    'name': name,
    'connectedAt': connectedAt.toIso8601String(),
    'permissions': permissions,
    'isActive': isActive,
  };

  factory ConnectedDevice.fromJson(Map<String, dynamic> json) => ConnectedDevice(
    id: json['id'],
    platform: json['platform'],
    name: json['name'],
    connectedAt: DateTime.parse(json['connectedAt']),
    permissions: List<String>.from(json['permissions']),
    isActive: json['isActive'] ?? true,
  );
}

class HealthData {
  final String type;
  final double value;
  final String unit;
  final DateTime date;
  final String source; // Add source field to track where data came from

  HealthData({
    required this.type,
    required this.value,
    required this.unit,
    required this.date,
    required this.source,
  });
}

class WearablesScreen extends StatefulWidget {
  const WearablesScreen({super.key});

  @override
  State<WearablesScreen> createState() => _WearablesScreenState();
}

class _WearablesScreenState extends State<WearablesScreen> {
  List<ConnectedDevice> connectedDevices = [];
  Map<String, HealthData> latestHealthData = {};
  bool isLoadingData = false;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Fitbit configuration
  static const String fitbitClientId = '23QG9C';
  static const String fitbitClientSecret = 'c77f0a7a3839a9307674b893fae14934';

  @override
  void initState() {
    super.initState();
    _loadConnectedDevices();
    _fetchLatestHealthData();
  }

  Future<void> _loadConnectedDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final devicesString = prefs.getString('connected_devices');

      if (devicesString != null) {
        final List<dynamic> devicesJson = jsonDecode(devicesString);
        setState(() {
          connectedDevices = devicesJson
              .map((json) => ConnectedDevice.fromJson(json))
              .where((device) => device.isActive)
              .toList();
        });
        print('✓ Loaded ${connectedDevices.length} connected devices');
      }
    } catch (e) {
      print('✗ Failed to load devices: $e');
    }
  }

  Future<void> _fetchLatestHealthData() async {
    if (connectedDevices.isEmpty) return;

    setState(() {
      isLoadingData = true;
    });

    try {
      DateTime now = DateTime.now();
      DateTime yesterday = now.subtract(const Duration(days: 1));

      // Fetch Fitbit data
      await _fetchFitbitData(yesterday, now);

      // Fetch Google Health/Apple Health data
      await _fetchGoogleAppleHealthData(yesterday, now);

      print('✓ Fetched health data: ${latestHealthData.length} metrics');
    } catch (e) {
      print('✗ Error fetching health data: $e');
    } finally {
      setState(() {
        isLoadingData = false;
      });
    }
  }

  Future<void> _fetchFitbitData(DateTime startTime, DateTime endTime) async {
    // Check if we have any Fitbit devices
    bool hasFitbitDevice = connectedDevices.any((device) => device.platform == 'fitbit');

    if (!hasFitbitDevice) return;

    try {
      // Get Fitbit access token and userID
      String? accessToken = await _secureStorage.read(key: 'fitbit_access_token');
      String? userID = await _secureStorage.read(key: 'fitbit_user_id');

      if (accessToken == null) {
        _setDefaultFitbitData();
        return;
      }

      if (userID == null) {
        userID = '-'; // Fallback to current user
      }

      // Create Fitbit credentials object
      FitbitCredentials fitbitCredentials = FitbitCredentials(
        userID: userID,
        fitbitAccessToken: accessToken,
        fitbitRefreshToken: '',
      );

      // Create data managers
      FitbitActivityTimeseriesDataManager stepsManager = FitbitActivityTimeseriesDataManager(
        clientID: fitbitClientId,
        clientSecret: fitbitClientSecret,
      );

      FitbitActivityTimeseriesDataManager caloriesManager = FitbitActivityTimeseriesDataManager(
        clientID: fitbitClientId,
        clientSecret: fitbitClientSecret,
      );

      DateTime today = DateTime.now();

      // Fetch steps data
      try {
        final stepsData = await stepsManager.fetch(
            FitbitActivityTimeseriesAPIURL.dayWithResource(
              date: today,
              resource: Resource.steps,
              fitbitCredentials: fitbitCredentials,
            )
        );

        if (stepsData != null) {
          List<dynamic> dataList = stepsData is List ? stepsData : [stepsData];

          if (dataList.isNotEmpty) {
            var latestData = dataList.last;
            dynamic stepsValue = 0;
            DateTime dataDate = DateTime.now();

            if (latestData is FitbitActivityTimeseriesData) {
              stepsValue = latestData.value;
              dataDate = latestData.dateOfMonitoring ?? DateTime.now();
            } else if (latestData is Map) {
              stepsValue = latestData['value'] ?? 0;
              if (latestData['dateTime'] != null) {
                try {
                  dataDate = DateTime.parse(latestData['dateTime']);
                } catch (e) {
                  dataDate = DateTime.now();
                }
              }
            }

            double finalStepsValue = 0;
            try {
              if (stepsValue is String) {
                finalStepsValue = double.parse(stepsValue);
              } else if (stepsValue is num) {
                finalStepsValue = stepsValue.toDouble();
              }
            } catch (e) {
              finalStepsValue = 0;
            }

            setState(() {
              latestHealthData['steps'] = HealthData(
                type: 'Steps',
                value: finalStepsValue,
                unit: 'steps',
                date: dataDate,
                source: 'Fitbit',
              );
            });
          } else {
            _setDefaultStepsData();
          }
        } else {
          _setDefaultStepsData();
        }
      } catch (e) {
        _setDefaultStepsData();
      }

      // Fetch calories data
      try {
        final caloriesData = await caloriesManager.fetch(
            FitbitActivityTimeseriesAPIURL.dayWithResource(
              date: today,
              resource: Resource.calories,
              fitbitCredentials: fitbitCredentials,
            )
        );

        if (caloriesData != null) {
          List<dynamic> dataList = caloriesData is List ? caloriesData : [caloriesData];

          if (dataList.isNotEmpty) {
            var latestData = dataList.last;
            dynamic caloriesValue = 0;
            DateTime dataDate = DateTime.now();

            if (latestData is FitbitActivityTimeseriesData) {
              caloriesValue = latestData.value;
              dataDate = latestData.dateOfMonitoring ?? DateTime.now();
            } else if (latestData is Map) {
              caloriesValue = latestData['value'] ?? 0;
              if (latestData['dateTime'] != null) {
                try {
                  dataDate = DateTime.parse(latestData['dateTime']);
                } catch (e) {
                  dataDate = DateTime.now();
                }
              }
            }

            double finalCaloriesValue = 0;
            try {
              if (caloriesValue is String) {
                finalCaloriesValue = double.parse(caloriesValue);
              } else if (caloriesValue is num) {
                finalCaloriesValue = caloriesValue.toDouble();
              }
            } catch (e) {
              finalCaloriesValue = 0;
            }

            setState(() {
              latestHealthData['calories'] = HealthData(
                type: 'Calories',
                value: finalCaloriesValue,
                unit: 'cal',
                date: dataDate,
                source: 'Fitbit',
              );
            });
          } else {
            _setDefaultCaloriesData();
          }
        } else {
          _setDefaultCaloriesData();
        }
      } catch (e) {
        _setDefaultCaloriesData();
      }

    } catch (e) {
      _setDefaultFitbitData();
    }
  }

  void _setDefaultStepsData() {
    setState(() {
      latestHealthData['steps'] = HealthData(
        type: 'Steps',
        value: 0,
        unit: 'steps',
        date: DateTime.now(),
        source: 'Fitbit',
      );
    });
  }

  void _setDefaultCaloriesData() {
    setState(() {
      latestHealthData['calories'] = HealthData(
        type: 'Calories',
        value: 0,
        unit: 'cal',
        date: DateTime.now(),
        source: 'Fitbit',
      );
    });
  }

  void _setDefaultFitbitData() {
    _setDefaultStepsData();
    _setDefaultCaloriesData();
  }

  Future<void> _fetchGoogleAppleHealthData(DateTime startTime, DateTime endTime) async {
    // Check if we have any Google Fit or Apple Health devices
    bool hasHealthDevice = connectedDevices.any((device) =>
    device.platform == 'google_fit' || device.platform == 'apple_health');

    if (!hasHealthDevice) return;

    try {
      Health health = Health();
      await health.configure();

      // Fetch steps data
      List<HealthDataPoint> stepsData = await health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: [HealthDataType.STEPS],
      );

      if (stepsData.isNotEmpty) {
        // Calculate total steps for the day
        int totalSteps = stepsData.fold(0, (sum, point) => sum + (point.value as num).toInt());

        // Determine source
        String source = 'Health Connect';
        if (connectedDevices.any((device) => device.platform == 'apple_health')) {
          source = 'Apple Health';
        }

        setState(() {
          latestHealthData['steps'] = HealthData(
            type: 'Steps',
            value: totalSteps.toDouble(),
            unit: 'steps',
            date: DateTime.now(),
            source: source,
          );
        });

        print('✓ Fetched $source steps: $totalSteps');
      } else {
        // No data available
        String source = connectedDevices.any((device) => device.platform == 'apple_health')
            ? 'Apple Health' : 'Health Connect';

        setState(() {
          latestHealthData['steps'] = HealthData(
            type: 'Steps',
            value: 0,
            unit: 'steps',
            date: DateTime.now(),
            source: source,
          );
        });
      }
    } catch (e) {
      print('⚠ Health data fetch failed: $e');
      // Still show 0 data rather than error
      String source = connectedDevices.any((device) => device.platform == 'apple_health')
          ? 'Apple Health' : 'Health Connect';

      setState(() {
        latestHealthData['steps'] = HealthData(
          type: 'Steps',
          value: 0,
          unit: 'steps',
          date: DateTime.now(),
          source: source,
        );
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadConnectedDevices();
    await _fetchLatestHealthData();
  }

  Future<void> _removeDevice(ConnectedDevice device) async {
    try {
      // Show confirmation dialog
      bool? shouldRemove = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Remove Device'),
            content: Text('Are you sure you want to remove ${device.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Remove', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );

      if (shouldRemove == true) {
        // Remove from local list
        setState(() {
          connectedDevices.removeWhere((d) => d.id == device.id);
        });

        // Remove from persistent storage
        await _saveConnectedDevicesToStorage();

        // Remove access token
        await _secureStorage.delete(key: '${device.platform}_access_token');

        // Clear health data for this device
        if (connectedDevices.isEmpty ||
            !connectedDevices.any((d) =>
            d.platform == 'google_fit' ||
                d.platform == 'apple_health' ||
                d.platform == 'fitbit')) {
          setState(() {
            latestHealthData.clear();
          });
        } else {
          // Refresh data to show data from remaining devices
          await _fetchLatestHealthData();
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${device.name} has been removed'),
              backgroundColor: Colors.green,
            ),
          );
        }

        print('✓ Removed device: ${device.name}');
      }
    } catch (e) {
      print('✗ Failed to remove device: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove device'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveConnectedDevicesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final devicesJson = connectedDevices.map((device) => device.toJson()).toList();
      await prefs.setString('connected_devices', jsonEncode(devicesJson));
      print('✓ Saved ${connectedDevices.length} connected devices');
    } catch (e) {
      print('✗ Failed to save devices: $e');
    }
  }

  // Get platform-specific supported devices
  List<Widget> get supportedDeviceWidgets {
    List<Map<String, dynamic>> devices = [
      {
        'icon': Icons.fitness_center,
        'name': 'Fitbit',
        'color': Colors.green,
      },
    ];

    if (!kIsWeb && Platform.isIOS) {
      devices.add({
        'icon': Icons.favorite,
        'name': 'Apple Health',
        'color': Colors.red,
      });
    }

    if (!kIsWeb && Platform.isAndroid) {
      devices.add({
        'icon': Icons.directions_run,
        'name': 'Google Fit',
        'color': Colors.blue,
      });
    }

    return devices.map((device) =>
        _buildSupportedDevice(
          icon: device['icon'],
          name: device['name'],
          color: device['color'],
        )
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wearables'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _navigateToAddDevice();
            },
          ),
        ],
      ),
      body: connectedDevices.isEmpty
          ? _buildEmptyState()
          : _buildConnectedDevicesView(),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.watch,
              size: 60,
              color: Colors.indigo,
            ),
          ),

          const SizedBox(height: 32),

          // Title
          const Text(
            'No Wearables Connected',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          const Text(
            'Connect wearable devices to track your patient\'s health data in real-time.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 40),

          // Add Device Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _navigateToAddDevice();
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Your First Device',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Supported Devices Info
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Supported Devices',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 20,
                    children: supportedDeviceWidgets,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportedDevice({
    required IconData icon,
    required String name,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectedDevicesView() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Connected Devices',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${connectedDevices.length} device${connectedDevices.length == 1 ? '' : 's'} connected',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _navigateToAddDevice,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Device'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Health Data Summary
            if (latestHealthData.isNotEmpty) ...[
              const Text(
                'Latest Health Data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 12),

              if (isLoadingData)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                _buildHealthDataCards(),

              const SizedBox(height: 20),
            ],

            // Connected Devices List
            const Text(
              'Your Devices',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 12),

            ...connectedDevices.map((device) => _buildDeviceCard(device)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthDataCards() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: latestHealthData.values.map((data) =>
              _buildHealthDataItem(data)
          ).toList(),
        ),
      ),
    );
  }

  Widget _buildHealthDataItem(HealthData data) {
    // Get icon and color based on data source
    IconData dataIcon;
    Color dataColor;

    switch (data.source) {
      case 'Fitbit':
        dataIcon = Icons.fitness_center;
        dataColor = Colors.green;
        break;
      case 'Apple Health':
        dataIcon = Icons.favorite;
        dataColor = Colors.red;
        break;
      case 'Health Connect':
      default:
        dataIcon = Icons.directions_walk;
        dataColor = Colors.blue;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: dataColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              dataIcon,
              color: dataColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      data.type,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: dataColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        data.source,
                        style: TextStyle(
                          fontSize: 10,
                          color: dataColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Last updated: ${_formatDate(data.date)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                data.value.toInt().toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              Text(
                data.unit,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(ConnectedDevice device) {
    IconData deviceIcon;
    Color deviceColor;

    switch (device.platform) {
      case 'google_fit':
        deviceIcon = Icons.directions_run;
        deviceColor = Colors.blue;
        break;
      case 'apple_health':
        deviceIcon = Icons.favorite;
        deviceColor = Colors.red;
        break;
      case 'fitbit':
        deviceIcon = Icons.fitness_center;
        deviceColor = Colors.green;
        break;
      default:
        deviceIcon = Icons.watch;
        deviceColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: deviceColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                deviceIcon,
                color: deviceColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Connected ${_formatDate(device.connectedAt)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${device.permissions.length} permission${device.permissions.length == 1 ? '' : 's'} granted',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Remove button
                InkWell(
                  onTap: () => _removeDevice(device),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  void _navigateToAddDevice() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddDeviceScreen(),
      ),
    );

    // Refresh data when returning from add device screen
    if (result == true) {
      await _refreshData();
    }
  }
}
