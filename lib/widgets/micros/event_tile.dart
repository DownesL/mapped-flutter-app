import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapped/models/event.dart';

class EventTile extends StatelessWidget {
  const EventTile({
    super.key,
    required this.onTap,
    required this.accentColor,
    required this.event,
  });

  final void Function() onTap;
  final Color accentColor;
  final Event event;

  String getEventDates() {
    var format = DateFormat('dd MMM yy');
    if (event.startDate.day == event.endDate.day) {
      return format.format(event.startDate);
    }
    return "${format.format(event.startDate)} - ${format.format(event.endDate)}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: accentColor,
        ),
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        onTap: onTap,
        leading: [
          Icon(Icons.public, color: accentColor),
          Icon(Icons.person, color: accentColor),
          Icon(Icons.people, color: accentColor),
        ][event.eventType.number],
        title: Text(event.name),
        trailing: Text(getEventDates()),
      ),
    );
  }
}
