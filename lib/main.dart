// Flutter run key commands.
// r Hot reload.
// R Hot restart.
// h List all available interactive commands.
// d Detach (terminate "flutter run" but leave application running).
// c Clear the screen
// q Quit (terminate the application on the device)z

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text("ScreenTime Tracker"),
          backgroundColor: const Color(0xFF4A47A3),
          leading: const Icon(Icons.menu),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.refresh)),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              buildCard("YouTube", "2h 15m", Icons.ondemand_video, Colors.red),
              buildCard("Facebook", "1h 30m", Icons.facebook, Colors.blue),
              buildCard("Instagram", "3h 05m", Icons.camera_alt, Colors.purple),
              buildCard("LinkedIn", "45m", Icons.business, Colors.blueGrey),
              buildCard(
                "Twitter",
                "1h 10m",
                Icons.alternate_email,
                Colors.lightBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard(String app, String time, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(app),
        subtitle: Text("Screen Time: $time"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
