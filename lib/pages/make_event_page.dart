import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoder_buddy/geocoder_buddy.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapped/models/date_picker_arguments.dart';
import 'package:mapped/models/event.dart';

class MakeEventPage extends StatefulWidget {
  const MakeEventPage({super.key, this.restorationId, required this.eventType});

  final String? restorationId;
  final EventType eventType;

  @override
  State<MakeEventPage> createState() => _MakeEventPageState();
}

class _MakeEventPageState extends State<MakeEventPage> with RestorationMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  String? get restorationId => widget.restorationId;

  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  List<GBSearchData> searchItem = [];
  bool isSearching = false;
  Address? _address;
  LatLng? _latLng;

  String? dateErrorMessage;

  final RestorableDateTime _selectedStartDate =
      RestorableDateTime(DateTime.now());
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
              args.currentDate ?? DateTime.now().millisecondsSinceEpoch),
          firstDate: DateTime.fromMillisecondsSinceEpoch(
              args.startDate ?? DateTime.now().millisecondsSinceEpoch),
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
  Widget build(BuildContext context) {
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
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Title:'),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        if (value.length > 50) {
                          return 'Please enter a name shorter than 50 characters';
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
                          style: TextStyle(color: Colors.red),
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
                                  color: Theme.of(context).primaryColor),
                              label: Text(
                                  _selectedStartTime.value.format(context)),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                _restorableStartDatePickerRouteFuture.present();
                              },
                              icon: Icon(Icons.calendar_today,
                                  color: Theme.of(context).primaryColor),
                              label: Text(
                                  '${_selectedStartDate.value.day}/${_selectedStartDate.value.month}/${_selectedStartDate.value.year}'),
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
                                  color: Theme.of(context).primaryColor),
                              label:
                                  Text(_selectedEndTime.value.format(context)),
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                _restorableEndDatePickerRouteFuture.present();
                              },
                              icon: Icon(Icons.calendar_today,
                                  color: Theme.of(context).primaryColor),
                              label: Text(
                                  '${_selectedEndDate.value.day}/${_selectedEndDate.value.month}/${_selectedEndDate.value.year}'),
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
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Description:',
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
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Address:'),
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
                            ? ListView.builder(
                                itemCount: searchItem.length,
                                itemBuilder: (context, index) {
                                  var item = searchItem[index];
                                  return ListTile(
                                    title: Text(
                                      item.displayName,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    onTap: () {
                                      setLocation(item);
                                      searchItem = [];
                                    },
                                  );
                                })
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
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Number:'),
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
              backgroundColor: Theme.of(context).primaryColor,
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

  void saveEvent() {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _address?.houseNumber = numberController.text;
      Event event = Event(
        eid: '',
        name: nameController.text,
        startDate: _selectedStartDate.value,
        endDate: _selectedEndDate.value,
        address: _address!,
        attendeeIDs: [user.uid],
        organiserIDs: [user.uid],
        pictureList: [],
        eventType: widget.eventType,
        description: descriptionController.text,
        latLng: _latLng!,
      );

      FirebaseFirestore db = FirebaseFirestore.instance;
      db.collection("events").add(event.toFirestore());
      Navigator.pushNamedAndRemoveUntil(context, '/calendar', (route) => false);
    }
  }
}
