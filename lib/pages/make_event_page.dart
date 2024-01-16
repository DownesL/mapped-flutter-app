import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoder_buddy/geocoder_buddy.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapped/firebase_service.dart';
import 'package:mapped/models/date_picker_arguments.dart';
import 'package:mapped/models/event.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:provider/provider.dart';

class MakeEventPage extends StatefulWidget {
  const MakeEventPage(
      {super.key, this.restorationId, required this.eventType, this.event});

  final String? restorationId;
  final EventType eventType;
  final Event? event;

  @override
  State<MakeEventPage> createState() => _MakeEventPageState();
}

class _MakeEventPageState extends State<MakeEventPage> with RestorationMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  String? get restorationId => widget.restorationId;

  final titleController = TextEditingController();
  final numberController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  List<GBSearchData> searchItem = [];
  bool isSearching = false;
  Address? _address;
  LatLng? _latLng;

  String? dateErrorMessage;

  final RestorableDateTime _selectedStartDate =
      RestorableDateTime(DateTime.now().add(Duration(minutes: 15)));
  late final RestorableRouteFuture<DateTime?>
      _restorableStartDatePickerRouteFuture = RestorableRouteFuture<DateTime?>(
    onComplete: _selectStartDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: DatePickerArguments(
          null,
          _selectedStartDate.value.millisecondsSinceEpoch,
        ).toMap(),
      );
    },
  );
  final RestorableDateTime _selectedEndDate = RestorableDateTime(
    DateTime.now().add(
      const Duration(
        hours: 2,
      ),
    ),
  );
  late final RestorableRouteFuture<DateTime?>
      _restorableEndDatePickerRouteFuture = RestorableRouteFuture<DateTime?>(
    onComplete: _selectEndDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: DatePickerArguments(
          _selectedStartDate.value.millisecondsSinceEpoch,
          _selectedEndDate.value.millisecondsSinceEpoch,
        ).toMap(),
      );
    },
  );
  final RestorableTimeOfDay _selectedStartTime =
      RestorableTimeOfDay(TimeOfDay.now());
  late final RestorableRouteFuture<TimeOfDay?>
      _restorableStartTimePickerRouteFuture = RestorableRouteFuture<TimeOfDay?>(
    onComplete: _selectStartTime,
    onPresent: (NavigatorState navigator, Object? arguments) {
      var time = DateTime(2023, 1, 1, _selectedStartTime.value.hour,
          _selectedStartTime.value.minute);
      return navigator.restorablePush(
        _timePickerRoute,
        arguments: TimePickerArguments(
          time.millisecondsSinceEpoch,
        ).toMap(),
      );
    },
  );
  final RestorableTimeOfDay _selectedEndTime = RestorableTimeOfDay(
      TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 2))));
  late final RestorableRouteFuture<TimeOfDay?>
      _restorableEndTimePickerRouteFuture = RestorableRouteFuture<TimeOfDay?>(
    onComplete: _selectEndTime,
    onPresent: (NavigatorState navigator, Object? arguments) {
      var time = DateTime(2023, 1, 1, _selectedStartTime.value.hour,
          _selectedStartTime.value.minute);
      return navigator.restorablePush(
        _timePickerRoute,
        arguments: TimePickerArguments(
          time.millisecondsSinceEpoch,
        ).toMap(),
      );
    },
  );

  void _selectStartDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      _selectedStartDate.value = newSelectedDate;
      if (_selectedStartDate.value.isAfter(_selectedEndDate.value)) {
        _selectedEndDate.value = newSelectedDate;
      }
      setState(() {});
    }
  }

  void _selectEndDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedEndDate.value = newSelectedDate;
      });
    }
  }

  void _selectStartTime(TimeOfDay? timeOfDay) {
    if (timeOfDay != null) {
      var date = _selectedStartDate.value;
      var newDate = DateTime(
        date.year,
        date.month,
        date.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );
      if (newDate.isBefore(DateTime.now())) {
        dateErrorMessage = "Select a date and time in the future.";
        setState(() {});
        return;
      } else {
        dateErrorMessage = null;
      }
      _selectedStartTime.value = timeOfDay;
      _selectedStartDate.value = newDate;
      if (_selectedStartDate.value.isAfter(_selectedEndDate.value)) {
        _selectedEndDate.value = newDate.add(const Duration(hours: 2));
        _selectedEndTime.value = TimeOfDay.fromDateTime(_selectedEndDate.value);
      }
      setState(() {});
    }
  }

  void _selectEndTime(TimeOfDay? timeOfDay) {
    if (timeOfDay != null) {
      var date = _selectedStartDate.value;
      var newDate = DateTime(
        date.year,
        date.month,
        date.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );
      if (newDate.isBefore(DateTime.now())) {
        dateErrorMessage = "Select a date and time in the future.";
        setState(() {});
        return;
      } else {
        dateErrorMessage = null;
      }

      _selectedEndTime.value = timeOfDay;
      _selectedEndDate.value = newDate;
      if (_selectedStartDate.value.isAfter(_selectedEndDate.value)) {
        _selectedStartDate.value =
            newDate.subtract(const Duration(minutes: 30));
        _selectedStartTime.value =
            TimeOfDay.fromDateTime(_selectedStartDate.value);
      }
      setState(() {});
    }
  }

  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        var args =
            DatePickerArguments.fromMap(arguments as Map<String, dynamic>);
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(
              args.currentDate ?? DateTime.now().add(const Duration(minutes: 15)).millisecondsSinceEpoch),
          firstDate: DateTime.fromMillisecondsSinceEpoch(
              args.startDate ?? DateTime.now().add(const Duration(minutes: 15)).millisecondsSinceEpoch),
          lastDate: DateTime(2030),
        );
      },
    );
  }

  @pragma('vm:entry-point')
  static Route<TimeOfDay> _timePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        var args =
            TimePickerArguments.fromMap(arguments as Map<String, dynamic>);
        return TimePickerDialog(
          restorationId: 'time_picker_dialog',
          initialEntryMode: TimePickerEntryMode.dialOnly,
          initialTime: TimeOfDay.fromDateTime(
              DateTime.fromMillisecondsSinceEpoch(args.startTime ??
                  DateTime(2023, 1, 1, 17, 0).millisecondsSinceEpoch)),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedStartDate, 'selected_start_date');
    registerForRestoration(_selectedEndDate, 'selected_end_date');
    registerForRestoration(_selectedStartTime, 'selected_start_time');
    registerForRestoration(_selectedEndTime, 'selected_start_time');
    registerForRestoration(
        _restorableStartDatePickerRouteFuture, 'date_picker_route_future');
    registerForRestoration(
        _restorableEndDatePickerRouteFuture, 'date_picker_route_future');
    registerForRestoration(
        _restorableStartTimePickerRouteFuture, 'time_picker_route_future');
    registerForRestoration(
        _restorableEndTimePickerRouteFuture, 'time_picker_route_future');
  }

  void searchLocation(String query) async {
    setState(() {
      isSearching = true;
    });
    List<GBSearchData> data = await GeocoderBuddy.query(query);
    setState(() {
      isSearching = false;
      searchItem = data;
    });
  }

  void setLocation(item) async {
    var data = await GeocoderBuddy.searchToGBData(item);
    setState(() {
      _latLng = LatLng(double.parse(data.lat), double.parse(data.lon));
      _address = data.address;
    });

    locationController.text =
        '${_address!.road}, ${_address!.postcode}, ${_address!.countryCode!.toUpperCase()}';
  }

  @override
  void initState() {
    if (widget.event != null) {
      var e = widget.event!;
      titleController.text = e.name;
      numberController.text = e.address.houseNumber ?? "1";
      descriptionController.text = e.description;
      _address = e.address;
      _latLng = e.latLng;
      locationController.text =
          '${e.address.road}, ${e.address.postcode}, ${e.address.countryCode!.toUpperCase()}';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MappedUser mUser = context.read<MappedUser>();
    Color color = Color(mUser.labels!.eventLabelColor(widget.eventType));
    return Scaffold(
      appBar: AppBar(
        title: Text('New ${widget.eventType.value} Event'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, top: 32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: titleController,
                      textInputAction: TextInputAction.next,
                      cursorColor: color,
                      decoration: InputDecoration(
                        labelText: 'Title:',
                        floatingLabelStyle: TextStyle(color: color),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: color),
                        ),
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        if (value.length > 50) {
                          return 'Please enter a title shorter than 50 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    if (dateErrorMessage != null)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.symmetric(
                            vertical: 3.0, horizontal: 10.0),
                        decoration: BoxDecoration(
                            color: const Color(0x22BB2342),
                            border: Border.all(color: Colors.red)),
                        child: Text(
                          dateErrorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Start date:'),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                _restorableStartTimePickerRouteFuture.present();
                              },
                              icon: Icon(Icons.access_time_outlined,
                                  color: color),
                              label: Text(
                                _selectedStartTime.value.format(context),
                                style: TextStyle(color: color),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                _restorableStartDatePickerRouteFuture.present();
                              },
                              icon: Icon(Icons.calendar_today, color: color),
                              label: Text(
                                '${_selectedStartDate.value.day}/${_selectedStartDate.value.month}/${_selectedStartDate.value.year}',
                                style: TextStyle(color: color),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('End date:'),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                _restorableEndTimePickerRouteFuture.present();
                              },
                              icon: Icon(Icons.access_time_outlined,
                                  color: color),
                              label: Text(
                                _selectedEndTime.value.format(context),
                                style: TextStyle(color: color),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                _restorableEndDatePickerRouteFuture.present();
                              },
                              icon: Icon(Icons.calendar_today, color: color),
                              label: Text(
                                '${_selectedEndDate.value.day}/${_selectedEndDate.value.month}/${_selectedEndDate.value.year}',
                                style: TextStyle(color: color),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    TextFormField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textAlign: TextAlign.start,
                      textInputAction: TextInputAction.next,
                      controller: descriptionController,
                      cursorColor: color,
                      decoration: InputDecoration(
                        labelText: 'Description:',
                        floatingLabelStyle: TextStyle(color: color),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: color),
                        ),
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        if (value.length > 240) {
                          return 'Please enter a description shorter than 240 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    TextFormField(
                      controller: locationController,
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: (data) {
                        setState(() {
                          _address = null;
                        });
                        if (data.isNotEmpty) searchLocation(data);
                      },
                      cursorColor: color,
                      decoration: InputDecoration(
                        labelText: 'Address:',
                        floatingLabelStyle: TextStyle(color: color),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: color),
                        ),
                      ),
                      validator: (String? value) {
                        if (value == null ||
                            value.isEmpty ||
                            _address == null ||
                            _latLng == null) {
                          return 'Please enter an address';
                        }
                        return null;
                      },
                    ),
                    if (_address == null && searchItem.isNotEmpty)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: !isSearching
                            ? searchItem.isNotEmpty
                                ? ListView.builder(
                                    itemCount: searchItem.length,
                                    itemBuilder: (context, index) {
                                      var item = searchItem[index];
                                      return ListTile(
                                        title: Text(
                                          item.displayName,
                                          style: TextStyle(
                                            color: color,
                                          ),
                                        ),
                                        onTap: () {
                                          setLocation(item);
                                          searchItem = [];
                                        },
                                      );
                                    })
                                : const Text("No corresponding address found.")
                            : const Center(
                                child: CircularProgressIndicator(),
                              ),
                      ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    TextFormField(
                      controller: numberController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: false, signed: false),
                      textInputAction: TextInputAction.next,
                      cursorColor: color,
                      decoration: InputDecoration(
                        labelText: 'Number:',
                        floatingLabelStyle: TextStyle(color: color),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: color),
                        ),
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a number';
                        }
                        RegExp reg = RegExp(r'[a-zA-Z0-9]{1,5}');
                        if (reg.stringMatch(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: MediaQuery.viewInsetsOf(context).bottom > 0
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  saveEvent();
                }
              },
              backgroundColor: color,
              label: Text(
                'Save Event',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.background),
              ),
              icon: Icon(
                Icons.save,
                color: Theme.of(context).colorScheme.background,
              ),
            ),
    );
  }

  Future<void> saveEvent() async {
    var user = FirebaseAuth.instance.currentUser;
    MappedUser? mappedUser = context.read<MappedUser>();
    if (mappedUser.isNotEmpty) {
      _address?.houseNumber = numberController.text;
      Event event = Event(
        eid: widget.event?.eid ?? '',
        name: titleController.text,
        startDate: _selectedStartDate.value,
        endDate: _selectedEndDate.value,
        address: _address!,
        attendeeIDs: [mappedUser.uid!],
        organiserIDs: [mappedUser.uid!],
        pictureList: [],
        eventType: widget.eventType,
        description: descriptionController.text,
        latLng: _latLng!,
      );

      var fS = FirebaseService();
      await fS.addEvent(mappedUser, event);
      if (mounted) {
        if (widget.event?.eid != null) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            "/home/event",
            (route) => false,
            arguments: EventArguments(event: event),
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, '/calendar', (route) => false);
        }
      }
    }
  }
}
