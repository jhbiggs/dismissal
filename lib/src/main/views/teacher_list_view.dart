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
      Uri.parse("ws://localhost:8080/notification-stream"));
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

  Widget _buildTeacherList(AsyncSnapshot snapshot, Teacher testTeacher) {
            print("try in snapshot activated && snapshot.hasData= ${snapshot.hasData} ");

    // Check for connection state and data availability first
    if (snapshot.connectionState == ConnectionState.active &&
        snapshot.hasData) {
      try {
        final parsed = jsonDecode(snapshot.data.toString());
        testTeacher = Teacher.fromJson(parsed['data']);
        // Update the items with the new arrival status
        items.firstWhere((element) => element.id == testTeacher.id).arrived =
            testTeacher.arrived;
      } on FormatException catch (e) {
        print('Invalid JSON: $e');
        return const Text('Invalid JSON');
      }
    }

    // Render ListView if data are available or
    // connection state is none/waiting/active
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final teacher = items[index];
        return ListTile(
          title: Text('Teacher ${teacher.name}'),
          leading: const CircleAvatar(
            backgroundColor: Color.fromARGB(153, 133, 128, 128),
            child: Icon(Icons.person),
          ),
          tileColor: teacher.arrived ? Colors.blue : Colors.white,
          onTap: () => _toggleTeacherArrival(teacher),
        );
      },
    );
  }
  final TextEditingController _controller = TextEditingController();
  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _channel.sink.add(_controller.text);
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Teacher testTeacher = Teacher(0, 'no teacher', 'no grade', false);
    return Scaffold(
        // To work with lists that may contain a large number of items, it’s best
        // to use the ListView.builder constructor.
        //
        // In contrast to the default ListView constructor, which requires
        // building all Widgets up front, the ListView.builder constructor lazily
        // builds Widgets as they’re scrolled into view.
        body: 
        Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              child: TextFormField(
                controller: _controller,
                decoration: const InputDecoration(labelText: 'Send a message'),
              ),
            ),
            const SizedBox(height: 24),
            StreamBuilder(
              stream: _channel.stream,
              builder: (context, snapshot) {
                return Text(snapshot.hasData ? '${snapshot.data}' : '');
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Send message',
        child: const Icon(Icons.send),
      )); // This trail);
  }
}
