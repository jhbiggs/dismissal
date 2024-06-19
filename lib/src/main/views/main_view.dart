import 'package:flutter/material.dart';
import 'package:flutter_bus/src/main/views/bus_list_view.dart';
import 'package:flutter_bus/src/main/views/teacher_list_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../settings/settings_view.dart';

class MainView extends StatefulWidget {
  static const routeName = '/';

  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;

  final tabs = [
    const TeacherListView(),
    const BusListView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          items:  const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person),
                label: 'Teachers',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.bus_alert,
                ),
              label: 'Buses',
            ),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          }),

      appBar: AppBar(
        title: const Text('Dismissal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
          IconButton(
            icon: const Text("Clear"),
            onPressed: () {
              SharedPreferences.getInstance().then((prefs) {
                prefs.clear();
              });
              setState(() {
                _currentIndex = _currentIndex;
              });
            },
          ),
        ],
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
    );
  }
}
