import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bus/src/main/flutter_db_service/flutter_db_service.dart';
import 'package:flutter_bus/src/main/flutter_objects/event.dart';
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
  final _channel = WebSocketChannel.connect(Uri.parse("ws://$baseUrl:80/ws"));
  
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

      // Send the updated teacher data to the server
      final message = jsonEncode(teacher.toJson());
      _channel.sink.add(jsonEncode(Event("teacher-change", teacher.toJson())));
      // Consider reloading teacher data if necessary
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  Widget _buildTeacherList(AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.none ||
        snapshot.connectionState == ConnectionState.waiting ||
        snapshot.connectionState == ConnectionState.active) {
      final parsed = jsonDecode(snapshot.data.toString());
      print("Parsed in teacher list view is: ${parsed}");
      try {
        if (parsed != null) {
          final event = Event.fromJson(jsonDecode(snapshot.data.toString()));

          if (event.messageType == 'teacher-change') {
            print("message type is teacher-change");
            final teacher = Teacher.fromJson(event.message);
            print("Teacher is: ${teacher}");
            // Update the items with the new arrival status
            items.firstWhere((element) => element.id == teacher.id).arrived =
                teacher.arrived;
          }
        }
      } on FormatException catch (e) {
        // TODO
        print('Error parsing JSON data: $e');
      } on TypeError catch (e) {
        // TODO
        print('Type Error parsing JSON data: $e');
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
      },
    ));
  }
}
