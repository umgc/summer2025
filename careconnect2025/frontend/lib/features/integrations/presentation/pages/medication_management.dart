import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MedicationManagementScreen extends StatefulWidget {
  const MedicationManagementScreen({super.key});

  @override
  State<MedicationManagementScreen> createState() => _MedicationManagementScreenState();
}

class _MedicationManagementScreenState extends State<MedicationManagementScreen> {
  // Empty list - no medications added yet
  List<Map<String, dynamic>> medications = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Management'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _navigateToAddMedication();
            },
          ),
        ],
      ),
      body: medications.isEmpty
          ? _buildEmptyState()
          : _buildMedicationList(),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large medication icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medication,
              size: 60,
              color: Colors.indigo,
            ),
          ),

          const SizedBox(height: 32),

          // Title
          const Text(
            'No Medications Added',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          const Text(
            'Scan or enter medication codes to automatically retrieve drug information and set up dosage schedules for your patient.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 40),

          // Add Medication Buttons
          Column(
            children: [
              // Scan Barcode Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _scanMedicationCode();
                  },
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  label: const Text(
                    'Scan Medication Barcode',
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

              const SizedBox(height: 12),

              // Enter Code Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _enterMedicationCode();
                  },
                  icon: const Icon(Icons.keyboard, color: Colors.indigo),
                  label: const Text(
                    'Enter Drug Code Manually',
                    style: TextStyle(
                      color: Colors.indigo,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.indigo, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Medication Management Features
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
                    'Medication Management Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFeature(
                        icon: Icons.schedule,
                        name: 'Dosage\nSchedule',
                        color: Colors.blue,
                      ),
                      _buildFeature(
                        icon: Icons.notifications,
                        name: 'Medication\nReminders',
                        color: Colors.orange,
                      ),
                      _buildFeature(
                        icon: Icons.analytics,
                        name: 'Adherence\nTracking',
                        color: Colors.green,
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

  Widget _buildFeature({
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
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMedicationList() {
    // This will be used later when medications are added
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          const Text(
            'Current Medications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${medications.length} medications being managed',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),

          // Medication List (will be populated later)
          Expanded(
            child: ListView.builder(
              itemCount: medications.length,
              itemBuilder: (context, index) {
                final medication = medications[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.indigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.medication,
                        color: Colors.indigo,
                      ),
                    ),
                    title: Text(medication['brandName'] ?? 'Unknown Medication'),
                    subtitle: Text(medication['genericName'] ?? 'Unknown Generic'),
                    trailing: Text(
                      medication['strength'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _scanMedicationCode() {
    // For now, show a simple dialog
    // Later, this will open camera scanner
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Scan Medication'),
          content: const Text('This will open the camera to scan medication barcodes.\n\n(Camera scanner integration will be implemented here)'),
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
                    content: Text('Barcode scanner coming soon!'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _enterMedicationCode() {
    final TextEditingController codeController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Enter NDC Code'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Enter the NDC (National Drug Code) in product format:'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: codeController,
                    decoration: const InputDecoration(
                      labelText: 'Product NDC',
                      hintText: 'e.g., 50580-937',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Use format: XXXXX-XXX (5 digits, dash, 3 digits)',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (isLoading) ...[
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Looking up medication...'),
                      ],
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    if (codeController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter an NDC code')),
                      );
                      return;
                    }

                    setDialogState(() {
                      isLoading = true;
                    });

                    try {
                      final medicationData = await _lookupMedication(codeController.text.trim());

                      Navigator.pop(context);

                      if (medicationData != null) {
                        _showMedicationDetails(medicationData);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('NDC code not found. Please check the code and try again.'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    } catch (e) {
                      setDialogState(() {
                        isLoading = false;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error looking up medication: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                  child: Text(
                    isLoading ? 'Looking up...' : 'Lookup',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _lookupMedication(String code) async {
    // Keep the code as-is for product NDC format (XXXXX-XXX)
    final cleanCode = code.trim();

    try {
      // Search by product NDC in the correct format
      final uri = Uri.parse(
          'https://api.fda.gov/drug/ndc.json?search=product_ndc:"$cleanCode"&limit=1'
      );

      print('Looking up medication with NDC: $cleanCode');
      print('API URL: $uri');

      final response = await http.get(uri);

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          return _parseNDCResult(result, cleanCode);
        }
      } else if (response.statusCode == 404) {
        print('Medication not found in FDA database');
        return null;
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in _lookupMedication: $e');
      rethrow;
    }

    return null;
  }

  Map<String, dynamic>? _parseNDCResult(Map<String, dynamic> result, String code) {
    try {
      return {
        'ndc': code,
        'brandName': result['brand_name'] ?? result['proprietary_name'] ?? 'Unknown Brand',
        'genericName': result['generic_name'] ?? result['nonproprietary_name'] ?? 'Unknown Generic',
        'dosageForm': result['dosage_form_name'] ?? 'Unknown Form',
        'strength': result['active_ingredients']?.isNotEmpty == true
            ? '${result['active_ingredients'][0]['strength']} ${result['active_ingredients'][0]['unit']}'
            : 'Unknown Strength',
        'manufacturer': result['labeler_name'] ?? 'Unknown Manufacturer',
        'warnings': [],
        'indications': [],
        'dosageAndAdministration': [],
        'activeIngredients': result['active_ingredients'] ?? [],
      };
    } catch (e) {
      print('Error parsing NDC result: $e');
      return null;
    }
  }

  void _showMedicationDetails(Map<String, dynamic> medicationData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(medicationData['brandName']),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Generic Name:', medicationData['genericName']),
                _buildDetailRow('Dosage Form:', medicationData['dosageForm']),
                _buildDetailRow('Strength:', medicationData['strength']),
                _buildDetailRow('Manufacturer:', medicationData['manufacturer']),
                _buildDetailRow('NDC Code:', medicationData['ndc']),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _addMedicationToList(medicationData);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              child: const Text('Add Medication', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _addMedicationToList(Map<String, dynamic> medicationData) {
    setState(() {
      medications.add({
        ...medicationData,
        'addedAt': DateTime.now(),
        'dosage': '', // To be set by user later
        'frequency': '', // To be set by user later
        'nextDose': null, // To be calculated later
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${medicationData['brandName']} added successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _navigateToAddMedication() {
    // Show options to scan or enter code
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Medication',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              ListTile(
                leading: const Icon(Icons.qr_code_scanner, color: Colors.indigo),
                title: const Text('Scan Barcode'),
                subtitle: const Text('Use camera to scan medication barcode'),
                onTap: () {
                  Navigator.pop(context);
                  _scanMedicationCode();
                },
              ),

              ListTile(
                leading: const Icon(Icons.keyboard, color: Colors.indigo),
                title: const Text('Enter Code Manually'),
                subtitle: const Text('Type NDC code manually'),
                onTap: () {
                  Navigator.pop(context);
                  _enterMedicationCode();
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}