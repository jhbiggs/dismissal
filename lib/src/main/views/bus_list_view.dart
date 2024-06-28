import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bus/src/main/flutter_objects/bus.dart';
import 'package:flutter_bus/src/main/views/emoji_translator.dart';
import 'package:flutter_bus/src/main/flutter_db_service/flutter_db_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class BusListView extends StatefulWidget {
  static const routeName = '/bus_list';

  const BusListView({super.key});

  @override
  State<BusListView> createState() => _BusListViewState();
}

class _BusListViewState extends State<BusListView> {
  // create a blank list of buses and a list of selected items
  List<Bus> items = [];

  final _channel = WebSocketChannel.connect(
      Uri.parse('ws://172.16.56.23:80/notification-stream'));

  void loadBuses() async {
    // items = await fetchBuses();

    setState(() {
    });
  }

  void initLoadBuses() async {
    items = await fetchBuses();
    setState(() {
    });
  }

  @override
  void initState() {
    super.initState();
    initLoadBuses();
  }

  void _toggleBusArrival(Bus bus) {
    setState(() {
      bus.arrived = !bus.arrived;
      updateBus(bus);
      // Consider reloading bus data if necessary
    });
  }

  Widget _buildBusList(AsyncSnapshot snapshot, Bus testBus) {
  // Check for connection state and data availability first
  if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
    try {
      final parsed = jsonDecode(snapshot.data.toString());
      testBus = Bus.fromJson(parsed['data']);
      // Update the items with the new arrival status
      items.firstWhere((element) => element.id == testBus.id).arrived = testBus.arrived;
    } on FormatException catch (e) {
      // Handle JSON format exception
      print('Error parsing JSON data: $e');
      return Text('Error parsing data');
    }
  } 

  // Render ListView if data is available or connection state is none/waiting/active
  return ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) {
      final bus = items[index];
      return ListTile(
        title: Text('Bus ${bus.busNumber}'),
        leading: CircleAvatar(
          backgroundColor: const Color.fromARGB(153, 133, 128, 128),
          child: Text(bus.animal.toEnum().emoji, style: const TextStyle(fontSize: 35)),
        ),
        tileColor: bus.arrived ? Colors.blue : Colors.white,
        onTap: () => _toggleBusArrival(bus),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    Bus testBus = Bus(0, '', '', false);
    return Scaffold(
      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: StreamBuilder(
          stream: _channel.stream,
          initialData: items,
          builder: (context, snapshot) {
            return _buildBusList(snapshot, testBus);
          }),
    );
  }
}

