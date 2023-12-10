import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mapped/firebase_service.dart';
import 'package:mapped/models/event.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:provider/provider.dart';

class EventMarkerLayer extends StatefulWidget {
  const EventMarkerLayer(
      {super.key, this.extraEvents, required this.onlyPublicEvents});

  final List<Event>? extraEvents;
  final bool onlyPublicEvents;

  @override
  State<EventMarkerLayer> createState() => _EventMarkerLayerState();
}

class _EventMarkerLayerState extends State<EventMarkerLayer> {
  late MappedUser currentUser;
  late List<Event> kEvents = [];
  var fS = FirebaseService();
  bool loading = false;

  void getAllEvents() async {
    setState(() {
      loading = true;
    });
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (widget.onlyPublicEvents) {
        kEvents = await fS.getPublicEvents(
              currentUser,
              limit: 25,
            ) ??
            <Event>[];
      } else {
        kEvents = await fS.getUserEvents(
              currentUser,
              after: DateTime.now(),
            ) ??
            <Event>[];
        if (widget.extraEvents != null) {
          kEvents.addAll(widget.extraEvents!);
        }
      }

      setState(() {
        loading = false;
      });
    }
  }

  Future<void> setUser() async {
    MappedUser mUser = await fS.getUser();
    if (mounted) {
      currentUser = context.read<MappedUser>();
      currentUser.setValues(mUser);
      getAllEvents();
    }
  }

  @override
  void initState() {
    super.initState();
    setUser();
  }

  @override
  Widget build(BuildContext context) {
    currentUser = context.watch<MappedUser>();
    var accentColors = currentUser.labels;
    return loading
        ? Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(9.0),
              child: CircularProgressIndicator(),
            ))
        : MarkerLayer(
            markers: [
              if (currentUser.lastKnownPosition != null)
                Marker(
                  point: currentUser.lastKnownPosition!,
                  child: const Stack(alignment: Alignment.center, children: [
                    Icon(
                      Icons.circle,
                      color: Colors.blueAccent,
                    ),
                    Icon(
                      Icons.circle_outlined,
                      color: Colors.lightBlueAccent,
                      size: 20,
                    ),
                    Icon(
                      Icons.circle_outlined,
                      color: Colors.white,
                      size: 19,
                    ),
                  ]),
                ),
              if (accentColors != null)
                for (Event event in kEvents)
                  Marker(
                    point: event.latLng,
                    width: 80,
                    height: 80,
                    child: GestureDetector(
                      onTap: widget.onlyPublicEvents
                          ? () => Navigator.pushNamed(
                                context,
                                '/discover/event',
                                arguments: EventArguments(event: event),
                              )
                          : () => Navigator.pushNamed(
                                context,
                                '/home/event',
                                arguments: EventArguments(event: event),
                              ),
                      child: [
                        Icon(
                          Icons.public,
                          size: 40,
                          color: Color(
                              accentColors.eventLabelColor(event.eventType)),
                        ),
                        Icon(
                          Icons.person,
                          size: 40,
                          color: Color(
                              accentColors.eventLabelColor(event.eventType)),
                        ),
                        Icon(
                          Icons.people,
                          size: 40,
                          color: Color(
                              accentColors.eventLabelColor(event.eventType)),
                        ),
                      ][event.eventType.number],
                      // Icon(
                      //   Icons.place,
                      //   size: 40,
                      //   color: Color(
                      //       ,
                      // ),
                    ),
                  ),
            ],
          );
  }
}
