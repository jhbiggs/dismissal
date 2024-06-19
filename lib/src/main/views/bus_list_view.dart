import 'package:flutter/material.dart';
import 'package:flutter_bus/src/main/flutter_objects/bus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bus/src/main/flutter_objects/constants.dart';
import 'package:flutter_bus/src/main/flutter_db_service/flutter_db_service.dart';

class BusListView extends StatefulWidget {
  static const routeName = '/bus_list';

  const BusListView({super.key});

  @override
  State<BusListView> createState() => _BusListViewState();
}

class _BusListViewState extends State<BusListView> {

  // load the list of buses from the global constant "buses"
  final List<Bus> items = buses;
  final List<bool> _selected =
      List.generate(buses.length, (i) => buses.elementAt(i).arrived); // Fill it with false initially

  void loadBuses() async {
    var busListFromDB = await fetchBuses();
    setState(() {
      items.clear();
      items.addAll(busListFromDB);
    });
  }  

  @override
  void initState() {
    super.initState();
    loadBuses();
    _loadListState();
  }

  void _loadListState() async {
    // // Load the initial state of the list with either checked or unchecked
    // // items.
    // final prefs = await SharedPreferences.getInstance();
    // for (int i = 0; i < items.length; i++) {
    //   _selected[i] = prefs.getBool('Bus$i') ?? false;
    // }
    // setState(() {
    //   // Rebuild the list view with the saved state.
    // });
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
        restorationId: 'busListView',
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];

          return ListTile(
              tileColor: _selected[index] ? Colors.blue : Colors.white,
              title: Text('Bus ${item.name}'),
              leading: CircleAvatar(
                // Display the Flutter Logo image asset.
                backgroundColor: const Color.fromARGB(153, 133, 128, 128),
                // Display the Flutter Logo image asset.
                child: Text(
                  item.animal,
                  style: const TextStyle(fontSize: 35),
                ),
              ),
              onTap: () {
                  
                  setState(() {
                    item.arrived = !item.arrived;
                    updateBus(item).then((value) {
                      loadBuses();
                      _selected[index] = !_selected[index];
                  
                  });
                });
                // Save the state of the list item.
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setBool('Bus$index', _selected[index]);
                });
              });
          // () {
          // Navigate to the details page. If the user leaves and returns to
          // the app after it has been killed while running in the
          // background, the navigation stack is restored.

          // Navigator.restorablePushNamed(
          //   context,
          //   SampleItemDetailsView.routeName,
          // );
          // });
        },
      ),
    );
  }
}
