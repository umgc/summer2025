import 'package:flutter/material.dart';
import 'package:care_connect_app/widgets/common_drawer.dart';
import 'package:care_connect_app/widgets/app_bar_helper.dart';

class SmartDevicesScreen extends StatefulWidget {
  const SmartDevicesScreen({super.key});

  @override
  State<SmartDevicesScreen> createState() => _SmartDevicesScreenState();
}

class _SmartDevicesScreenState extends State<SmartDevicesScreen> {
  // Empty list - no smart devices connected yet
  List<Map<String, dynamic>> connectedDevices = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CommonDrawer(currentRoute: '/smart-devices'),
      appBar: AppBarHelper.createAppBar(
        context,
        title: 'Smart Devices',
        centerTitle: true,
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddDevice,
          ),
        ],
      ),
      body: connectedDevices.isEmpty ? _buildEmptyState() : _buildDeviceList(),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large smart device icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.devices,
              size: 60,
              color: Theme.of(context).primaryColor,
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            'No Smart Devices Connected',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          const Text(
            'Connect Alexa-compatible smart devices to help monitor and assist with your patient\'s daily activities.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.4),
          ),

          const SizedBox(height: 40),

          // Add Device Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _navigateToAddDevice();
              },
              icon: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              label: Text(
                'Add Your First Device',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Supported Device Types
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
                    'Alexa-Compatible Devices',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSupportedDevice(
                        icon: Icons.lightbulb,
                        name: 'Smart Lights',
                        color: Colors.amber,
                      ),
                      _buildSupportedDevice(
                        icon: Icons.thermostat,
                        name: 'Thermostats',
                        color: Colors.orange,
                      ),
                      _buildSupportedDevice(
                        icon: Icons.lock,
                        name: 'Smart Locks',
                        color: Colors.green,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSupportedDevice(
                        icon: Icons.outlet,
                        name: 'Smart Plugs',
                        color: Colors.blue,
                      ),
                      _buildSupportedDevice(
                        icon: Icons.speaker,
                        name: 'Alexa Devices',
                        color: Colors.purple,
                      ),
                      _buildSupportedDevice(
                        icon: Icons.sensor_door,
                        name: 'Sensors',
                        color: Colors.red,
                      ),
                    ],
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
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDeviceList() {
    // This will be used later when devices are added
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          const Text(
            'Connected Devices',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${connectedDevices.length} devices connected',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Device List (will be populated later)
          Expanded(
            child: ListView.builder(
              itemCount: connectedDevices.length,
              itemBuilder: (context, index) {
                return const Card(child: ListTile(title: Text('Smart Device')));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddDevice() {
    // For now, show a simple dialog
    // Later, this will navigate to AddSmartDeviceScreen
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Smart Device'),
          content: const Text(
            'This will open the Alexa device setup screen.\n\n(Navigation to smart device setup will be implemented here)',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Smart device setup coming soon!'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
