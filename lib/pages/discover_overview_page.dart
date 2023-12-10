import 'package:flutter/material.dart';
import 'package:mapped/models/event.dart';
import 'package:mapped/pages/map_overview_page.dart';

class DiscoverOverviewPage extends StatelessWidget {
  const DiscoverOverviewPage({super.key, this.event});

  final Event? event;

  @override
  Widget build(BuildContext context) {
    return MapOverviewPage(
      event: event,
      discoverPage: true,
    );
  }
}
