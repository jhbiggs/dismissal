import 'dart:convert';

import 'package:flutter_bus/src/main/flutter_objects/bus.dart';
import 'package:http/http.dart' as http;

Future<List<Bus>> fetchBuses() async {
  final response = await http.get(Uri.parse('http://localhost:8080/buses'));

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response,
    // then parse the JSON.
    Map<String, dynamic> list = json.decode(response.body);
    if (list['buses'] != null) {
      List<Bus> buses =
          list['buses'].map<Bus>((bus) => Bus.fromJson(bus)).toList() ;
          buses.sort((a, b) => a.name.compareTo(b.name));
      return buses;
    } else {
      return [];
    }
  } else {
    // If the server returns an error response,
    // then throw an exception.
    throw Exception('Failed to load buses');
  }
}

Future<http.Response> updateBus(Bus bus) async {
  final response = await http.put(
    Uri.parse('http://localhost:8080/buses/${bus.id}/toggleBusArrivalStatus'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, bool>{'arrived': bus.arrived}),
  );

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response,
    // then parse the JSON.
    print (response.body);
    return response;
  } else {
    // If the server returns an error response,
    // then throw an exception.
    throw Exception('Failed to update bus, error code: ${response.statusCode}');
  }
}
