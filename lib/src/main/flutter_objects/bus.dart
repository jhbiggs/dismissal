
class Bus {
  final int id;
  final String name;
  final String animal;
  bool arrived = false;

  Bus(this.id, this.name, this.animal, this.arrived);

  // The factory constructor is used to create a
  // new instance of the bus class from a JSON (map) object.
  factory Bus.fromJson(Map<String, dynamic> json) {
    try {
      return Bus(
        json['id'] as int,
        json['number'] as String,
        json['animal'] as String,
        json['arrived'] as bool,
      );
    } catch (e) {
      throw const FormatException('Invalid or missing data in JSON');
    }
  }
}

class Buses {
  final List<Bus> buses;

  Buses({required this.buses});

  factory Buses.fromJson(List<dynamic> json) {
    List<Bus> buses = [];
    buses = json.map((i) => Bus.fromJson(i)).toList();
    return Buses(buses: buses);
  }
}
