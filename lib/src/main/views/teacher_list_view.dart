import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bus/src/main/flutter_db_service/flutter_db_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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

  // final _channel = WebSocketChannel.connect(
  //     Uri.parse('ws://dismissalapp.org:8080/notification-stream'));
  final _channel = WebSocketChannel.connect(
      Uri.parse("ws://$baseUrl:8080/notification-stream"));
  // Uri.parse('wss://echo.websocket.events'));
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

  void _toggleTeacherArrival(Teacher teacher) {
    setState(() {
      teacher.arrived = !teacher.arrived;
      // Consider reloading teacher data if necessary
    });
  }

  Widget _buildTeacherList(AsyncSnapshot snapshot) {
    // try {
    //   final parsed = jsonDecode(snapshot.data.toString());
    //   print(parsed['data']);
    //   testTeacher = Teacher.fromJson(parsed['data']);
    //   // Update the items with the new arrival status
    //   items.firstWhere((element) => element.id == testTeacher.id).arrived =
    //       testTeacher.arrived;
    // } on FormatException catch (e) {
    //   print('Invalid JSON: $e');
    //   return const Text('Invalid JSON');
    // }
    if (snapshot.connectionState == ConnectionState.none ||
        snapshot.connectionState == ConnectionState.waiting ||
        snapshot.connectionState == ConnectionState.active) {
final parsed = jsonDecode(snapshot.data.toString());
//     final teacher1 = Teacher.fromJson(parsed['data']);
        print(parsed);
        if (parsed != null) {
          final teacher = Teacher.fromJson(parsed['data']);
          // Update the items with the new arrival status
          items.firstWhere((element) => element.id == teacher.id).arrived =
              teacher.arrived;
        }

      return ListView(padding: const EdgeInsets.all(16), children: [
        for (var index = 0; index < items.length; index++)
          ListTile(
            title: Text('Teacher ${items[index].name}'),
            leading: const CircleAvatar(
              backgroundColor: Color.fromARGB(153, 133, 128, 128),
              child: Icon(Icons.person),
            ),
            tileColor: items[index].arrived ? Colors.blue : Colors.white,
            onTap: () => _toggleTeacherArrival(items[index]),
          )
      ]);
    }
    return const Text('No data');
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
        body: StreamBuilder(
      stream: _channel.stream,
      builder: (context, snapshot) {
        return _buildTeacherList(snapshot);
        // return Text(snapshot.hasData ? '${snapshot.data}' : '');
      },
    ));
  }
}
