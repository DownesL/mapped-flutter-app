import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapped/models/event.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:mapped/widgets/micros/attendee_profile_pics.dart';
import 'package:mapped/widgets/micros/qr_code_popup.dart';
import 'package:provider/provider.dart';

class EventSheet extends StatelessWidget {
  const EventSheet({super.key, required this.event});

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
    var mUser = context.watch<MappedUser>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    event.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                ],
              ),
              const Spacer(),
              Text(
                getEventDates(),
                style: Theme.of(context).textTheme.titleSmall,
              )
            ],
          ),
          const Divider(),
          if (event.eventType != EventType.private)
            Row(
              children: [
                Text(
                  '${event.attendeeIDs.length} ${event.attendeeIDs.length == 1 ? "person" : "people"} will attend',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(
                  width: 8.0,
                ),
                AttendeeProfilePics(
                  event: event,
                ),
              ],
            ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              QRCodePopup(url: 'events/${event.eid}'),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.share,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              if (event.organiserIDs.contains(mUser.uid))
                TextButton(
                  onPressed: () {},
                  child: const Text("Edit event"),
                  style: ButtonStyle(
                      foregroundColor: MaterialStatePropertyAll(
                          Theme.of(context).colorScheme.tertiary),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.tertiary)))),
                )
              else if (event.attendeeIDs.contains(mUser.uid))
                TextButton(
                  onPressed: () {},
                  child: const Text('Leave Event'),
                )
              else
                TextButton(
                  onPressed: () {},
                  child: const Text('Join Event'),
                ),
            ],
          ),
          SizedBox(
            height: 16,
          )
        ],
      ),
    );
  }
}
