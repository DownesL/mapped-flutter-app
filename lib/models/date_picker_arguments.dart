class DatePickerArguments {
  final int? startDate;
  final int? currentDate;

  DatePickerArguments(this.startDate, this.currentDate);

  Map<String, dynamic> toMap() {
    return {
      "start_date": startDate,
      "current_date": currentDate,
    };
  }

  DatePickerArguments.fromMap(Map<String, dynamic> map)
      : currentDate = map['current_date'],
        startDate = map['start_date'];
}
class TimePickerArguments {
  final int? startTime;

  TimePickerArguments(this.startTime, );

  Map<String, dynamic> toMap() {
    return {
      "start_time": startTime,
    };
  }

  TimePickerArguments.fromMap(Map<String, dynamic> map)
      : startTime = map['start_time'];
}
