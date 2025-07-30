import 'package:flutter/material.dart';

class CaregiverShiftSchedulingScreen extends StatefulWidget {
  // This screen allows caregivers to input their scheduled shifts to make them
  // visible to other caregivers and patients. It includes fields for recurring shifts,
  // Start Time, End Time, and Days of the Week.
  const CaregiverShiftSchedulingScreen({super.key});

  @override
  State<CaregiverShiftSchedulingScreen> createState() => _CaregiverShiftSchedulingScreenState();
}

class _CaregiverShiftSchedulingScreenState extends State<CaregiverShiftSchedulingScreen> {
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  var isRecurring = false; // Toggle for recurring shifts

  // Add state for selected days
  final List<String> days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  final Set<int> selectedDayIndexes = {};


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Shift Scheduling'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // toggle for if the shift is Recurring
                    SwitchListTile(
                      title: const Text('Recurring Shift', 
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      value: isRecurring,
                      onChanged: (value) {
                        setState(() {
                          isRecurring = value;
                        });
                      },
                    ),
                    // Shift Start Time
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text('Start Time', textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    Card(
                      // margin: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.indigo, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(selectedStartTime != null
                            ? selectedStartTime!.format(context)
                            : 'No time selected'),
                        leading: const Icon(Icons.access_time, color: Colors.indigo, size: 40),

                        onTap: () async {
                          final TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: selectedStartTime ?? TimeOfDay(hour: 9, minute: 0), // Default to 9 AM
                          );
                          if (time != null) {
                            setState(() {
                              selectedStartTime = time;
                            });
                          }
                        },
                      ),
                    ),
                    // Shift End Time
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text('End Time', textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    Card(
                      // margin: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.indigo, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(selectedEndTime != null
                            ? selectedEndTime!.format(context)
                            : 'No time selected'),
                        leading: const Icon(Icons.access_time, color: Colors.indigo, size: 40),

                        onTap: () async {
                          final TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: selectedEndTime ?? TimeOfDay(hour: 17, minute: 0), // Default to 6 PM
                          );
                          if (time != null) {
                            setState(() {
                              selectedEndTime = time;
                            });
                          }
                        },
                      ),
                    ),
                    // Days of the Week Selection
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text('Days', textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    Wrap(
                      spacing: 4.0,
                      runSpacing: 2.0,
                      children: [
                        for (var i = 0; i < days.length; i++)
                          ChoiceChip(
                            label: Text(days[i], 
                            style: const TextStyle(fontSize: 16)),
                            selectedColor: Colors.indigo,
                            showCheckmark: false,
                            selected: selectedDayIndexes.contains(i),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedDayIndexes.add(i);
                                } else {
                                  selectedDayIndexes.remove(i);
                                }
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ]
          ),
        ),
        // Save Button at the bottom
        bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            // TODO: Logic to save the custom task
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          child: const Text('Save', style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      )
    );
  }
}