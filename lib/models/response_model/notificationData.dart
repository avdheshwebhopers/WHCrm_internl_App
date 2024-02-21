
class NotificationData {
  final String title;
  final String body;
  final String number;
  final String id;
  final String type;
  final String datetime;

  NotificationData({
    required this.title,
    required this.body,
    required this.number,
    required this.id,
    required this.type,
    required this.datetime,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      title: json['title'] as String,
      body: json['body'] as String,
      number: json['number'] as String,
      id: json['id'] as String,
      type: json['type'] as String,
      datetime: json['datetime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'number': number,
      'id': id,
      'type': type,
      'datetime': datetime,
    };
  }
}
