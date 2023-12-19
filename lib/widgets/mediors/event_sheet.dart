import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapped/firebase_service.dart';
import 'package:mapped/models/event.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:mapped/widgets/mediors/add_image_overlay.dart';
import 'package:mapped/widgets/micros/attendee_profile_pics.dart';
import 'package:mapped/widgets/micros/qr_code_popup.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

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

  final fS = FirebaseService();

  late Event event;
  late OverlayState overlayState;
  late OverlayEntry overlayEntry;

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

  @override
  void initState() {
    event = widget.event;
    overlayState = Overlay.of(context);
    super.initState();
  }

  bool isLoading = false;

  void getEvent() async {
    var e = await fS.getEventByID(widget.event.eid);
    if (e == null) return;
    event = e;
    if (mounted) {
      setState(() {});
    }
  }

  void share() async {
    final box = context.findRenderObject() as RenderBox;
    await Share.share(
        "Check out this event on the Mapped App: https://mapped.app/events/${event.eid}",
        subject: "Hello",
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  }

  @override
  Widget build(BuildContext context) {
    var mUser = context.watch<MappedUser>();
    getEvent();
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
          const SizedBox(
            height: 8.0,
          ),
          if (event.pictureList.isNotEmpty)
            Flexible(
              fit: FlexFit.loose,
              flex: 2,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: event.pictureList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(5)),
                    margin: const EdgeInsets.only(right: 4.0),
                    clipBehavior: Clip.antiAlias,
                    child: Image(
                      width: 200,
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        event.pictureList[index],
                      ),
                    ),
                  );
                },
              ),
            )
          else
            const SizedBox(
                height: 250, child: Center(child: Text('No pictures yet'))),
          const Spacer(flex: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              QRCodePopup(url: 'events/${event.eid}'),
              const Spacer(),
              if (event.eventType != EventType.private)
                IconButton.outlined(
                  style: ButtonStyle(
                    side: MaterialStatePropertyAll(
                      BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  //todo: this link
                  onPressed: share,
                  icon: Icon(
                    Icons.share,
                    color: Theme.of(context).colorScheme.secondary,
                    semanticLabel: "Share",
                  ),
                ),
              if (event.organiserIDs.contains(mUser.uid))
                Row(
                  children: [
                    const SizedBox(
                      width: 4,
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showAddImageDialog(context),
                      style: ButtonStyle(
                        side: MaterialStatePropertyAll(
                          BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                      icon: const Icon(
                        Icons.add_a_photo,
                        size: 16,
                      ),
                      label: const Text("Add"),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text("Edit event"),
                      style: ButtonStyle(
                          foregroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.tertiary),
                          shape: MaterialStatePropertyAll(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  side: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary)))),
                    )
                  ],
                )
              else
                TextButton(
                  style: ButtonStyle(
                    side: MaterialStatePropertyAll(
                      BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  onPressed: () => togglePresence(),
                  child: event.attendeeIDs.contains(mUser.uid)
                      ? const Text('Leave Event')
                      : const Text('Join Event'),
                )
            ],
          ),
          const SizedBox(
            height: 16,
          )
        ],
      ),
    );
  }

  togglePresence() {
    var currentUser = context.read<MappedUser>();
    if (event.attendeeIDs.contains(currentUser.uid)) {
      event.attendeeIDs.remove(currentUser.uid);
    } else {
      event.attendeeIDs.add(currentUser.uid!);
    }
    fS.updateEvent(event);
    currentUser.toggleAttendingEvents(event.eid);
  }
}
