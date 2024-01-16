import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapped/models/date_picker_arguments.dart';
import 'package:mapped/models/filter_options.dart';
import 'package:provider/provider.dart';

class FilterOverlay extends StatefulWidget {
  const FilterOverlay({super.key, required this.closeFunction, this.restorationId,});

  final Function() closeFunction;
  final String? restorationId;

  @override
  State<FilterOverlay> createState() => _FilterOverlayState();
}

class _FilterOverlayState extends State<FilterOverlay>  with RestorationMixin {
  @override
  String? get restorationId => widget.restorationId;


  bool isLoading = false;
  late FilterOptions filterOptions;

  final TextEditingController _limitController = TextEditingController();

  late final RestorableDateTime _selectedStartDate;

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

  void _selectStartDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      _selectedStartDate.value = newSelectedDate;
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
              args.startDate ?? DateTime(2002).millisecondsSinceEpoch),
          lastDate: DateTime(2030),
        );
      },
    );
  }

  @override
  void initState() {
    filterOptions = context.read<FilterOptions>();
    _limitController.text = "${filterOptions.limit}";
    _selectedStartDate = RestorableDateTime(filterOptions.after);
    super.initState();
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedStartDate, 'selected_filter_date');
    registerForRestoration(
        _restorableStartDatePickerRouteFuture, 'filter_date_picker_route_future');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(20),
        ),
        width: MediaQuery.sizeOf(context).width * .9,
        padding: EdgeInsets.all(16.0),
        margin: EdgeInsets.symmetric(
          vertical: MediaQuery.sizeOf(context).height * .2,
          horizontal: MediaQuery.sizeOf(context).width * .1,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Set Filter parameters',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16,),
            SizedBox(height: 16,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Start date:'),
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
            SizedBox(height: 16,),
            TextFormField(
              controller: _limitController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null) {
                  return "Please fill in a limit";
                }
                var intValue = int.parse(value);
                if (intValue < 1 && 100 < intValue) {
                  return "Please fill in a number between 0 and 100";
                }
              },
            ),
            SizedBox(height: 16,),
            SizedBox(height: 8,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (isLoading) CircularProgressIndicator(),
                Spacer(),
                OutlinedButton(
                  style: ButtonStyle(
                    side: MaterialStatePropertyAll(
                      BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  child: const Text('Cancel'),
                  onPressed: () => widget.closeFunction(),
                ),
                SizedBox(width: 8.0,),
                FilledButton(
                  child: const Text('Save'),
                  onPressed: () {
                    save();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  save() async {
    setState(() {
      isLoading = true;
    });

    filterOptions.setValues(
        limit: int.parse(_limitController.text),
        after: _selectedStartDate.value);

    setState(() {
      isLoading = false;
    });
    widget.closeFunction();
  }
}
