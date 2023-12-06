import 'package:flutter/material.dart';
import 'package:mapped/firebase_service.dart';
import 'package:mapped/models/event.dart';
import 'package:mapped/models/mapped_user.dart';

class SearchOptions extends ChangeNotifier {
  String? term;
  SearchType? searchType;
  List<SearchItem>? items;

  var fS = FirebaseService();

  setSearchTerm(String term) {
    this.term = term.isEmpty ? null : term;
    if (term.isNotEmpty) {
      getExternalSearchItems();
    } else {
      items = null;
    }
    notifyListeners();
  }

  setSearchType(SearchType? searchType) {
    this.searchType = searchType;

    getExternalSearchItems();
    notifyListeners();
  }

  setItems(List<SearchItem>? items) {
    this.items = items;
    notifyListeners();
  }

  void getExternalSearchItems() async {
    if (term == null) return;
    List<SearchItem> l = await fS.getSearchItems(
      term!,
      searchType,
    );
    setItems(l);
  }
}

class SearchItem {
  final SearchType searchType;
  final Event? event;
  final MappedUser? user;

  SearchItem({required this.searchType, this.event, this.user});
}

enum SearchType { event, people, place }
