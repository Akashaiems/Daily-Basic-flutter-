import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Reminder App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  List<String> activities = [
    'Wake up',
    'Go to gym',
    'Breakfast',
    'Meetings',
    'Lunch',
    'Quick nap',
    'Go to library',
    'Dinner',
    'Go to sleep',
  ];

  String? selectedDay;
  String? selectedActivity;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      onBackgroundPermissionSet: (granted) {
        print('Background permission was granted: $granted');
      },
      onForegroundPermissionSet: (granted) {
        print('Foreground permission was granted: $granted');
      },
    );
  }

  Future<void> _scheduleNotification(
      String title, String body, TimeOfDay time, int dayIndex) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(
        Duration(
          hours: time.hour,
          minutes: time.minute,
          days: dayIndex,
        ),
      ),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel ID',
          'channel name',
          channelDescription: 'channel description',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedDay,
              hint: Text('Select a day'),
              items: daysOfWeek.map((day) {
                return DropdownMenuItem(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDay = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            DropdownButton<String>(
              value: selectedActivity,
              hint: Text('Select an activity'),
              items: activities.map((activity) {
                return DropdownMenuItem(
                  value: activity,
                  child: Text(activity),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedActivity = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                ).then((value) {
                  setState(() {
                    selectedTime = value;
                  });
                });
              },
              child: Text('Select time'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: selectedDay != null &&
                      selectedActivity != null &&
                      selectedTime != null
                  ? () {
                      int dayIndex = daysOfWeek.indexOf(selectedDay!);
                      _scheduleNotification(
                        selectedActivity!,
                        'Reminder for $selectedActivity',
                        selectedTime!,
                        dayIndex,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Reminder scheduled!'),
                        ),
                      );
                    }
                  : null,
              child: Text('Set Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}