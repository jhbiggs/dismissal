import 'package:flutter/material.dart';
import 'package:flutter_bus/src/main/flutter_db_service/flutter_db_service.dart';

import '../flutter_objects/teacher.dart';

class TeacherListView extends StatefulWidget {
  static const routeName = '/teacher_list_view';

  const TeacherListView({super.key});

  @override
  State<TeacherListView> createState() => _TeacherListViewState();
}

class _TeacherListViewState extends State<TeacherListView> {
  // create a blank list of teachers and a list of selected items
  List<Teacher> items = [];
  List<bool> _selected = [];

  void loadTeachers() async {
    items = await fetchTeachers();

    setState(() {
      _selected = List<bool>.from(items.map((e) => e.arrived));
    });
  }

  @override
  void initState() {
    super.initState();
    loadTeachers();
  }

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
                  item.arrived = !item.arrived;
                  updateTeacher(item).then((value) {
                    loadTeachers();
                    _selected[index] = !_selected[index];
                  });
                });
              });
        },
      ),
    );
  }
}
