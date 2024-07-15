import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bus/src/main/flutter_objects/bus.dart';
import 'package:flutter_bus/src/main/flutter_objects/event.dart';
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
    List<bool> _selected = [];


  // final _channel = WebSocketChannel.connect(
  //     Uri.parse('ws://dismissalapp.org:8080/notification-stream'));
  //  final _channel = WebSocketChannel.connect(
  //     Uri.parse("ws://localhost:8080/notification-stream"));
  final _channel = WebSocketChannel.connect(Uri.parse("ws://$baseUrl:80/ws"));

  void loadBuses() async {
    items = await fetchBuses();

    setState(() {
            _selected = List<bool>.from(items.map((e) => e.arrived));

    });
  }

  void initLoadBuses() async {
    items = await fetchBuses();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initLoadBuses();
  }

  void _toggleBusArrival(Bus bus) {
    setState(() {
      bus.arrived = !bus.arrived;

      // Send the updated bus data to the server
      final message = jsonEncode(bus.toJson());
      _channel.sink.add(jsonEncode(Event("bus-change", bus.toJson())));

      // Consider reloading bus data if necessary
    });
  }

  Widget _buildBusList(AsyncSnapshot snapshot) {
    // Check for connection state and data availability first
    if (snapshot.connectionState == ConnectionState.none ||
        snapshot.connectionState == ConnectionState.waiting ||
        snapshot.connectionState == ConnectionState.active) {
      final parsed = jsonDecode(snapshot.data.toString());
              print("Parsed in bus list view is: $parsed");

      try {
        // if the parsed data is not null, then create an event object
        // parsed value will be null on first load because there is no
        // change event to trigger the data load.
        if (parsed != null) {
          final event = Event.fromJson(parsed);
          if (event.messageType == 'bus-change') {
            final testBus = Bus.fromJson(event.message);
            print("bus is: ${testBus}");

            items.firstWhere((element) => element.id == testBus.id).arrived =
                testBus.arrived;
          }
        }
      } on FormatException catch (e) {
        // Handle JSON format exception
        print('Error parsing JSON data: $e');
        return Text('Error parsing data');
      } on TypeError catch (e) {
        // TODO
        print('Type Error parsing JSON data: $e');
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
            child: Text(bus.animal.toEnum().emoji,
                style: const TextStyle(fontSize: 35)),
          ),
          tileColor: bus.arrived ? Colors.blue : Colors.white,
          onTap: () => _toggleBusArrival(bus),
        );
      },
    );
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
            return _buildBusList(snapshot);
          }),
    );
  }
}
