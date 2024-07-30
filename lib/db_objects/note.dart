
class NoteDB {
  String title;
  String category;
  String content;
  String dateModified;  // make this DateTime
  String timeNotification; // provisional
  String locationNotification; // provisional
  String weatherNotification; // provisional

  NoteDB(
      {
      required this.title,
      required this.category,
      required this.content,
      required this.dateModified,
      required this.timeNotification,
      required this.locationNotification,
      required this.weatherNotification});

  Map<String, Object?> toMap() {
    return {
      'title': title,
      'category': category,
      'content': content,
      'dateModified': dateModified,
      'timeNotification': timeNotification,
      'locationNotification': locationNotification,
      'weatherNotification': weatherNotification,
    };
  }
  static NoteDB fromMap(Map<String, Object?> map) {
    return NoteDB(
      title: map['title'] as String,
      category: map['category'] as String,
      content: map['content'] as String,
      dateModified: map['dateModified'] as String,
      timeNotification: map['timeNotification'] as String,
      locationNotification: map['locationNotification'] as String,
      weatherNotification: map['weatherNotification'] as String,
    );
  }

  @override
  String toString() {
    return 'Notification{title: $title, category: $category, content: $content, dateModified: $dateModified, timeNotification: $timeNotification, locationNotification: $locationNotification, weatherNotification: $weatherNotification}';
  }
}