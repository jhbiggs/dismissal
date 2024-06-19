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
      List<Bus> buses = list['buses']
          .map<Bus>((bus) => Bus.fromJson(bus))
          .toList();
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
