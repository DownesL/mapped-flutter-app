import 'package:flutter/material.dart';
import 'package:mapped/models/event.dart';
import 'package:mapped/models/filter_options.dart';
import 'package:mapped/pages/map_overview_page.dart';

class DiscoverOverviewPage extends StatelessWidget {
  const DiscoverOverviewPage({super.key, this.event, this.filterOptions});

  final Event? event;
  final FilterOptions? filterOptions;

  @override
  Widget build(BuildContext context) {
    return MapOverviewPage(
      event: event,
      filterOptions: filterOptions,
      discoverPage: true,
    );
  }
}
