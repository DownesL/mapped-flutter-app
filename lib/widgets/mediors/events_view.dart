import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapped/firebase_service.dart';
import 'package:mapped/models/event.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:mapped/widgets/micros/event_card.dart';
import 'package:mapped/widgets/micros/event_tile.dart';
import 'package:mapped/widgets/micros/pill.dart';
import 'package:provider/provider.dart';

class EventsView extends StatefulWidget {
  const EventsView({
    super.key,
    this.startDateFilter = false,
    this.eventTypeFilter = false,
    this.useCards = false,
    this.user,
  });

  final bool startDateFilter;
  final bool eventTypeFilter;
  final bool useCards;
  final MappedUser? user;

  @override
  State<EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends State<EventsView> {
  final ValueNotifier<List<Event>> _selectedEvents = ValueNotifier(<Event>[]);
  final ValueNotifier<EventType?> _selectedEventType = ValueNotifier(null);
  final ValueNotifier<DateTime> _after = ValueNotifier(DateTime.now());
  int limit = 5;
  late MappedUser mUser;
  var fS = FirebaseService();

  void decreaseAfter() {
    _after.value = _after.value.subtract(const Duration(days: 7));
    EventType? eT = _selectedEventType.value;
    _selectedEventType.value = null;
    getEvents(eventType: eT);
  }

  void increaseAfter() {
    limit += 5;
    EventType? eT = _selectedEventType.value;
    _selectedEventType.value = null;
    getEvents(eventType: eT);
  }

  void getEvents({
    EventType? eventType,
  }) async {
    _selectedEventType.value =
        eventType == _selectedEventType.value ? null : eventType;
    if (widget.user != null) {
      List<Event> arr = [];
      arr.addAll(
        await fS.getUserEvents(
              widget.user!,
              eventType: EventType.public,
              limit: 5,
              after: _after.value,
            ) ??
            <Event>[],
      );
      if (mUser.friends != null && mUser.friends!.contains(widget.user!.uid)) {
        arr.addAll(
          await fS.getUserEvents(
                widget.user!,
                eventType: EventType.friend,
                after: _after.value,
                limit: 5,
              ) ??
              <Event>[],
        );
      }
      _selectedEvents.value = arr;
    } else {
      _selectedEvents.value = await fS.getUserEvents(
            mUser,
            eventType: widget.eventTypeFilter ? _selectedEventType.value : null,
            after: widget.startDateFilter ? _after.value : null,
          ) ??
          <Event>[];
    }
  }

  @override
  void initState() {
    mUser = context.read<MappedUser>();
    getEvents(
      eventType: _selectedEventType.value,
    );
    super.initState();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    _selectedEventType.dispose();
    _after.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.eventTypeFilter)
          ValueListenableBuilder(
            valueListenable: _selectedEventType,
            builder: (context, eventType, _) => Row(
              children: [
                Pill(
                  isSelected: eventType == EventType.public,
                  label: "Public",
                  color: Color(
                    mUser.labels!.public,
                  ),
                  onTap: () => getEvents(
                    eventType: EventType.public,
                  ),
                ),
                Pill(
                  isSelected: eventType == EventType.private,
                  color: Color(mUser.labels!.private),
                  label: "Private",
                  onTap: () => getEvents(
                    eventType: EventType.private,
                  ),
                ),
                Pill(
                  isSelected: eventType == EventType.friend,
                  label: "Friend",
                  color: Color(
                    mUser.labels!.friend,
                  ),
                  onTap: () => getEvents(
                    eventType: EventType.friend,
                  ),
                ),
              ],
            ),
          ),
        if (widget.startDateFilter)
          ValueListenableBuilder(
            valueListenable: _after,
            builder: (context, events, _) => GestureDetector(
              onTap: decreaseAfter,
              child: Row(children: [
                const Icon(Icons.keyboard_arrow_up),
                Text("Previous week (${DateFormat("dd MMM yy").format(
                  _after.value.subtract(
                    const Duration(
                      days: 7,
                    ),
                  ),
                )})"),
              ]),
            ),
          ),
        const SizedBox(
          height: 8.0,
        ),
        Expanded(
          child: ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, events, _) {
              return events.isEmpty
                  ? const SizedBox(
                      height: 200,
                      child: Center(child: Text("No events here :)")),
                    )
                  : ListView(
                      scrollDirection:
                          widget.useCards ? Axis.horizontal : Axis.vertical,
                      shrinkWrap: !widget.useCards,
                      children: [
                        for (int index = 0;
                            index < min(limit, events.length);
                            index++)
                          renderEvent(events[index])
                      ],
                    );
            },
            child: const Text("No Events Found"),
          ),
        ),
        if (widget.startDateFilter)
          ValueListenableBuilder(
            valueListenable: _selectedEvents,
            builder: (context, events, _) {
              if (limit >= _selectedEvents.value.length) {
                return Container();
              }
              return GestureDetector(
                onTap: increaseAfter,
                child: const Row(children: [
                  Icon(Icons.keyboard_arrow_down),
                  Text("Load more"),
                ]),
              );
            },
          ),
      ],
    );
  }

  Widget renderEvent(Event event) {
    if (widget.useCards) {
      return EventCard(
        onTap: () => Navigator.pushNamed(
          context,
          '/home/event',
          arguments: EventArguments(event: event),
        ),
        accentColor: Color(mUser.labels!.eventLabelColor(event.eventType)),
        event: event,
      );
    }
    return EventTile(
      onTap: () => Navigator.pushNamed(
        context,
        '/home/event',
        arguments: EventArguments(event: event),
      ),
      accentColor: Color(mUser.labels!.eventLabelColor(event.eventType)),
      event: event,
    );
  }
}
