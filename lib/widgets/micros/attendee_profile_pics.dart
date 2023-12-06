import 'package:flutter/material.dart';
import 'package:mapped/firebase_service.dart';
import 'package:mapped/models/event.dart';

class AttendeeProfilePics extends StatefulWidget {
  const AttendeeProfilePics({super.key, required this.event});

  final Event event;

  @override
  State<AttendeeProfilePics> createState() => _AttendeeProfilePicsState();
}

class _AttendeeProfilePicsState extends State<AttendeeProfilePics> {
  var fS = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fS.getEventAttendeePics(widget.event),
        builder: (context, snapshot) {
          return Row(
            children: [
              if (snapshot.data != null)
                for (var i in (snapshot.data! as List<String?>))
                  if (i != null)
                    CircleAvatar(
                      maxRadius: 12,
                      backgroundImage: NetworkImage(i),
                    ),
            ],
          );
        });
  }
}
