import 'package:flutter/material.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:mapped/widgets/macros/calendar.dart';

import '../widgets/macros/make_event_buttons.dart';

class CalendarOverviewPage extends StatelessWidget {
  const CalendarOverviewPage({super.key, required this.mappedUser});

  final MappedUser? mappedUser;

  @override
  Widget build(BuildContext context) {
    return const Stack(children: [
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(),
          Calendar(),
        ],
      ),
      Positioned(
        right: 8.0,
        bottom: 8.0,
        child: MakeEventButtons(),
      ),
    ]);
  }
}
