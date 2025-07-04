import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_calendar/calendar.dart';

class CustomTaskSchedulingScreen extends StatefulWidget {
  const CustomTaskSchedulingScreen({super.key});

  @override
  State<CustomTaskSchedulingScreen> createState() => _CustomTaskSchedulingScreenState();
}

class _CustomTaskSchedulingScreenState extends State<CustomTaskSchedulingScreen> {
  TimeOfDay? selectedTime;
  String? selectedFrequency;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Task Scheduling'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text(
              'Create a custom task for your patient.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Expanded(
              // Implements the form for custom task scheduling
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text('Task Name', textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                          ),
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Task Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text('Description', textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                          ),
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    // Frequency selection dropdown
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text('Frequency', textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                          ),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedFrequency,
                      items: const [
                        DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                        DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                        DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                        DropdownMenuItem(value: 'Yearly', child: Text('Yearly')),
                        DropdownMenuItem(value: 'Every Week Day', child: Text('Every Week Day')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedFrequency = value;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Interval selection
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text('Interval', textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Interval (e.g., 1 day between tasks)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    // Count selection dropdown
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text('Count', textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Number of times to repeat the task',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text('Time', textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    Card(
                      // margin: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.indigo, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(selectedTime != null
                            ? selectedTime!.format(context)
                            : 'No time selected'),
                        leading: const Icon(Icons.access_time, color: Colors.indigo, size: 40),

                        onTap: () async {
                          final TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ?? TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              selectedTime = time;
                            });
                          }
                        },
                      ),
                    ),
                    // const SizedBox(height: 20),
                    // SfCalendar(
                    //   view: CalendarView.month,
                    //   initialSelectedDate: DateTime.now(),
                    //   onTap: (CalendarTapDetails details) {
                    //     if (details.targetElement == CalendarElement.calendarCell) {
                    //       // Handle calendar cell tap
                    //     }
                    //   },
                    // ),
                  ],
                ),
              ),
              
            ),
          ],
        ),
      ),
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
      ),
    );
  }
}