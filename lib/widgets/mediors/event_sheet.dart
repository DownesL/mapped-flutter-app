import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapped/models/event.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:mapped/widgets/mediors/add_image_overlay.dart';
import 'package:mapped/widgets/micros/attendee_profile_pics.dart';
import 'package:mapped/widgets/micros/qr_code_popup.dart';
import 'package:provider/provider.dart';

class EventSheet extends StatefulWidget {
  const EventSheet({super.key, required this.event});

  final Event event;

  @override
  State<EventSheet> createState() => _EventSheetState();
}

class _EventSheetState extends State<EventSheet> {
  String getEventDates() {
    var format = DateFormat('dd MMM yy');
    if (event.startDate.day == event.endDate.day) {
      return format.format(event.startDate);
    }
    return "${format.format(event.startDate)} - ${format.format(event.endDate)}";
  }

  late User user;

  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();

  final nameController = TextEditingController();
  final locationController = TextEditingController();

  _showAddImageDialog(BuildContext context) async {
    overlayEntry = OverlayEntry(
      builder: (context) {
        return ChangeNotifierProvider<Event>.value(
            value: event,
            child: AddImageOverlay(
              closeFunction: () => overlayEntry.remove(),
            ));
      },
    );

    overlayState.insert(overlayEntry);
  }

  late Event event;
  late OverlayState overlayState;
  late OverlayEntry overlayEntry;

  @override
  void initState() {
    event = widget.event;
    overlayState = Overlay.of(context);
    super.initState();
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
                const SizedBox(
                  width: 8.0,
                ),
                AttendeeProfilePics(
                  event: event,
                ),
              ],
            ),
          if (event.eventType != EventType.private) const Divider(),
          Row(
            children: [
              Text(
                "Pictures",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          SizedBox(
            height: 8.0,
          ),
          if (event.pictureList.isNotEmpty)
            Flexible(
                fit: FlexFit.loose,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: event.pictureList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(5)),
                      margin: EdgeInsets.only(right: 4.0),
                      clipBehavior: Clip.antiAlias,
                      child: Image(
                        width: 150,
                        height: 200,
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          event.pictureList[index],
                        ),
                      ),
                    );
                  },
                ))
          else
            const SizedBox(
                height: 150, child: Center(child: Text('No pictures yet'))),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              QRCodePopup(url: 'events/${event.eid}'),
              Spacer(),
              IconButton.outlined(
                style: ButtonStyle(
                  side: MaterialStatePropertyAll(
                    BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                onPressed: () {},
                icon: Icon(
                  Icons.share,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              if (event.organiserIDs.contains(mUser.uid))
                const SizedBox(
                  width: 4,
                ),
              if (event.organiserIDs.contains(mUser.uid))
                OutlinedButton.icon(
                  onPressed: () => _showAddImageDialog(context),
                  style: ButtonStyle(
                    side: MaterialStatePropertyAll(
                      BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  icon: const Icon(
                    Icons.add,
                    size: 16,
                  ),
                  label: Text("Add"),
                ),
              if (event.organiserIDs.contains(mUser.uid))
                const SizedBox(
                  width: 4,
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
          const SizedBox(
            height: 16,
          )
        ],
      ),
    );
  }
}
