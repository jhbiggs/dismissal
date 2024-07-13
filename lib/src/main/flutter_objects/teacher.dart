/// A placeholder class that represents an entity or model.
class Teacher {
  
  final int id;
  final String name;
  final String grade;
  bool arrived = false;

  Teacher(this.id, this.name, this.grade, this.arrived);

  /// The factory constructor is used to create a new
  ///  instance of the teacher class from a JSON (map) object.
  factory Teacher.fromJson(Map<String, dynamic> json) {
    try {
      // print(json);
      return Teacher(
        json['teacherid'] as int,
        json['teachername'] as String,
        json['grade'] as String,
        json['arrived'] as bool,
      );
    } catch (e) {
      throw const FormatException('Invalid or missing data in JSON');
    }
  }
}

class Teachers {
  final List<Teacher> teachers;

  Teachers({required this.teachers});

  factory Teachers.fromJson(List<dynamic> json) {
    List<Teacher> teachers = [];
    teachers = json.map((i) => Teacher.fromJson(i)).toList();
    return Teachers(teachers: teachers);
  }
}
