import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../flutter_objects/teacher.dart';
import 'package:flutter_bus/src/main/flutter_objects/constants.dart';

class TeacherListView extends StatefulWidget {
  static const routeName = '/teacher_list_view';

  const TeacherListView({super.key});

  @override
  State<TeacherListView> createState() => _TeacherListViewState();
}

class _TeacherListViewState extends State<TeacherListView> {
  @override
  void initState() {
    super.initState();
    _loadListState();
  }

  void _loadListState() async {
    // Load the initial state of the list with either checked or unchecked
    // items.
    final prefs =  await SharedPreferences.getInstance();
    for (int i = 0; i < teachers.length; i++) {
      _selected[i] = prefs.getBool('Teacher$i') ?? false;
    }
    setState(() {
      // Rebuild the list view with the saved state.
      
    });
  }

  final List<Teacher> items = teachers;
  final List<bool> _selected = List<bool>.filled(teachers.length, false);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: ListView.builder(
        // Providing a restorationId allows the ListView to restore the
        // scroll position when a user leaves and returns to the app after it
        // has been killed while running in the background.
        restorationId: 'teacherListView',
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];

          return ListTile(
              tileColor: _selected[index] ? Colors.blue : Colors.white,
              title: Text('Teacher ${item.name}'),
              leading: const CircleAvatar(
                // Display the Flutter Logo image asset.
                foregroundImage: AssetImage('assets/images/flutter_logo.png'),
              ),
              onTap: () {
                setState(() {
                  _selected[index] = !_selected[index];
                  // Save the state of the list item.
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.setBool('Teacher$index', _selected[index]);
                  });
                });
              });
        },
      ),
    );
  }
}
