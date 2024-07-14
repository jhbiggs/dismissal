class Event {
  String messageType;
  Map<String,dynamic> message;

  Event(this.messageType, this.message);

  factory Event.fromJson(Map<String, dynamic> json) {
    try {
      return Event(
        json['messageType'] as String,
        json['message'] as Map<String, dynamic>
      );
    } catch (e) {
      throw const FormatException('Invalid or missing data in EVENT JSON');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'messageType': messageType,
      'message': message,
    };
  }

}
