import 'package:flutter/material.dart';

class SettingWidgets extends StatefulWidget {
  const SettingWidgets({Key? key}) : super(key: key);

  @override
  State<SettingWidgets> createState() => _SettingWidgetsState();
}

class _SettingWidgetsState extends State<SettingWidgets> {
  // Example settings (replace with your actual settings)
  bool _darkMode = false; // Example: Dark mode toggle
  double _fontSize = 16.0; // Example: Font size

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // A light background
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView( // Use ListView for scrollable settings
        padding: const EdgeInsets.all(10),
        children: [
          // Dark Mode Setting
          Card(
            color: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: SwitchListTile(
              activeColor: Colors.black,
              inactiveThumbColor: Colors.grey,
              title: const Text('Dark Mode'),
              value: _darkMode,
              onChanged: (bool value) {
                setState(() {
                  _darkMode = value;
                  // TODO: Implement actual dark mode logic here
                });
              },
              secondary: const Icon(Icons.dark_mode,color: Colors.blueAccent,),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),

          // Font Size Setting
          Card(
            color: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Font Size',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _fontSize,
                    min: 12.0,
                    max: 24.0,
                    divisions: 4,
                    label: _fontSize.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _fontSize = value;
                        // TODO: Implement actual font size change logic here
                      });
                    },
                  ),
                  Text(
                    'Current Font Size: ${_fontSize.toStringAsFixed(1)}',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // Add more settings here (e.g., notification settings, theme color, etc.)
          Card(
            color: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: const Icon(Icons.notifications,color: Colors.blueAccent),
              title: const Text('Notification Settings'),
              onTap: () {
                // TODO: Implement navigation to notification settings screen
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),

          Card(
            color: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: const Icon(Icons.info_outline,color: Colors.blueAccent),
              title: const Text('About'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: Text('About',style: TextStyle(color: Colors.blueAccent),),
                      content: Text(
                        "Manage your daily tasks efficiently with this simple and powerful To-Do List app.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Ok', style: TextStyle(color: Colors.green)), //  Correct child syntax
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}