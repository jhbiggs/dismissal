import 'package:flutter/material.dart';
import 'package:flutter_bus/src/main/flutter_objects/bus.dart';
import 'package:flutter_bus/src/main/views/emoji_translator.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  final _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:80/notification-stream'));

  void loadBuses() async {
    items = await fetchBuses();

    setState(() {
      _selected = List<bool>.from(items.map((e) => e.arrived));
    });
  }

  @override
  void initState() {
    super.initState();
    loadBuses();
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
          initialData: items,
          builder: (context, snapshot) {
            print(snapshot.data);
            ;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                    tileColor: _selected[index] ? Colors.blue : Colors.white,
                    title: Text('Bus ${items[index].name}'),
                    leading: CircleAvatar(
                      // Display the Flutter Logo image asset.
                      backgroundColor: const Color.fromARGB(153, 133, 128, 128),
                      // Display the Flutter Logo image asset.
                      child: Text(
                        items[index].animal.toEnum().emoji,
                        style: const TextStyle(fontSize: 35),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        items[index].arrived = !items[index].arrived;
                        updateBus(items[index]).then((value) {
                          loadBuses();
                          _selected[index] = !_selected[index];
                        });
                      });
                      // Save the state of the list item.
                      // SharedPreferences.getInstance().then((prefs) {
                      //   prefs.setBool('Bus$index', _selected[index]);
                      // });
                    });
              },
            );
          }),
    );
  }
}
