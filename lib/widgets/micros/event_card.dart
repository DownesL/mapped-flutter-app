import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapped/models/event.dart';

class EventCard extends StatelessWidget {
  const EventCard({
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        width: 250,
        margin: const EdgeInsets.only(top: 4.0, bottom: 4.0, right: 8.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: accentColor,
            width: 2.0
          ),
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            [
              Icon(Icons.public, color: accentColor, size: 40,),
              Icon(Icons.person, color: accentColor, size: 40,),
              Icon(Icons.people, color: accentColor, size: 40,),
            ][event.eventType.number],
            const SizedBox(height: 8.0),
            Text(event.name,style: Theme.of(context).textTheme.titleMedium,),
            const SizedBox(height: 8.0),
            Text(getEventDates()),
          ],
        ),
      ),
    );
  }
}
