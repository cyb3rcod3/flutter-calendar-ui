class Event {
  String subject;
  String note;
  int startDateTime;
  int endDateTime;

  int id;

  Event({this.subject, this.note, this.startDateTime, this.endDateTime});

  Event.fromJson(Map<String, dynamic> json) {
    subject = json['subject'];
    note = json['note'];
    startDateTime = json['startDateTime'];
    endDateTime = json['endDateTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subject'] = this.subject;
    data['note'] = this.note;
    data['startDateTime'] = this.startDateTime;
    data['endDateTime'] = this.endDateTime;
    return data;
  }
}
