class SpecialEvent {
  SpecialEvent({
    this.id,
    this.name,
    this.date,
    this.isConcurrent: false,
    this.friendId,
  });
  String id;
  String name;
  DateTime date;
  bool isConcurrent;
  String friendId;

  factory SpecialEvent.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }
    final int startMilliseconds = data['date'];

    final String name = data['name'];
    final DateTime date =
        DateTime.fromMillisecondsSinceEpoch(startMilliseconds);
    final bool isConcurrent = data['isConcurrent'];
    final String friendId = data['friendId'];

    return SpecialEvent(
      id: documentId,
      name: name,
      date: date,
      isConcurrent: isConcurrent,
      friendId: friendId,
    );
  }

  Map<String, dynamic> toMap(String _friendId) {
    return {
      'name': name,
      'date': date.millisecondsSinceEpoch,
      'isConcurrent': isConcurrent,
      'friendId': _friendId,
    };
  }
}
