import 'package:flutter/material.dart';
import 'package:care_connect_app/widgets/common_drawer.dart';
import 'package:care_connect_app/widgets/app_bar_helper.dart';
import 'add_devices_screen.dart';

class WearablesScreen extends StatefulWidget {
  const WearablesScreen({super.key});

  @override
  State<WearablesScreen> createState() => _WearablesScreenState();
}

class _WearablesScreenState extends State<WearablesScreen> {
  // Empty list - no devices connected yet
  List<Map<String, dynamic>> connectedDevices = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CommonDrawer(currentRoute: '/wearables'),
      appBar: AppBarHelper.createAppBar(
        context,
        title: 'Wearables',
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
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.watch,
              size: 60,
              color: Theme.of(context).primaryColor,
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            'No Wearables Connected',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          const Text(
            'Connect wearable devices to track your patient\'s health data in real-time.',
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSupportedDevice(
                        icon: Icons.fitness_center,
                        name: 'Fitbit',
                        color: Colors.green,
                      ),
                      _buildSupportedDevice(
                        icon: Icons.favorite,
                        name: 'Apple Health',
                        color: Colors.red,
                      ),
                      _buildSupportedDevice(
                        icon: Icons.directions_run,
                        name: 'Google Fit',
                        color: Colors.blue,
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
          Text(
            'Connected Devices',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
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
                return const Card(child: ListTile(title: Text('Device')));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddDevice() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddDeviceScreen()),
    );
  }
}
