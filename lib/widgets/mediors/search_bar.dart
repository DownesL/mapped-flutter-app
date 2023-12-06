import 'package:flutter/material.dart';
import 'package:mapped/models/search_options.dart';
import 'package:provider/provider.dart';

class TopSearchBar extends StatefulWidget {
  const TopSearchBar({super.key});

  @override
  State<TopSearchBar> createState() => _TopSearchBarState();
}

class _TopSearchBarState extends State<TopSearchBar> {
  final searchController = TextEditingController();
  late SearchOptions searchOptions;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    searchOptions = context.watch<SearchOptions>();
    return Container(
      height: 50,
      margin: const EdgeInsets.only(
        top: 48,
        left: 8.0,
        right: 8.0,
      ),
      padding: const EdgeInsets.only(right: 6.0, left: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: 3,
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            size: 24,
          ),
          Container(
            margin: const EdgeInsets.only(left: 4.0),
            width: MediaQuery.sizeOf(context).width * .6,
            child: TextFormField(
              controller: searchController,
              onFieldSubmitted: (value) =>
                  searchOptions.setSearchTerm(value.trim()),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search for events, people...',
              ),
            ),
          ),
          const Spacer(),
          if (searchOptions.term != null)
            IconButton(
              onPressed: () {
                searchController.clear();
                searchOptions.setSearchTerm('');
              },
              icon: const Icon(Icons.clear),
            )/*
          else
            const AccountDrawerButton(),*/
        ],
      ),
    );
  }
}
