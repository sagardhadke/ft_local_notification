import 'package:flutter/material.dart';
import 'package:ft_local_notification/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

class MyDetails extends StatefulWidget {
  const MyDetails({super.key});

  @override
  State<MyDetails> createState() => _MyDetailsState();
}

class _MyDetailsState extends State<MyDetails> {
  @override
  void initState() {
    super.initState();
    NotificationService().initNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Details Screen")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amberAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                NotificationService().instantNotification(
                  id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
                  title: "Test Instant Notification",
                  body: "Flutter Local Notification",
                );
              },
              child: Text("Instant Notification"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final scheduledDate = tz.TZDateTime.now(
                  tz.local,
                ).add(Duration(seconds: 10));
                NotificationService().scheduleReminder(
                  id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
                  title: "Scheduled Notification",
                  body: "This notification was scheduled 10 seconds ago",
                  scheduledDate: scheduledDate,
                );
              },
              child: Text("Scheduled Notification"),
            ),
          ],
        ),
      ),
    );
  }
}
