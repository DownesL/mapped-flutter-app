import 'package:flutter/material.dart';
import 'package:mapped/widgets/mediors/events_view.dart';
import 'package:mapped/widgets/mediors/top_bar.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TopBar(title: "Events"),
      ),
      resizeToAvoidBottomInset: false,
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: EventsView(
          eventTypeFilter: true,
          startDateFilter: true,
        ),
      ),
    );
  }
}
