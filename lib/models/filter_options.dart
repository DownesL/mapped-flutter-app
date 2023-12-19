import 'package:flutter/material.dart';

class FilterOptions extends ChangeNotifier {
  late DateTime after;
  late int limit;

  FilterOptions() {
    after = DateTime.now().subtract(Duration(days: 1));
    limit = 25;
  }

  setValues({required int limit,required DateTime after}) {
    this.limit = limit;
    this.after = after;
    notifyListeners();
  }
}