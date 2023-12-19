import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapped/models/event.dart';
import 'package:mapped/models/filter_options.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:mapped/models/search_options.dart';
import 'package:mapped/pages/calendar_overview_page.dart';
import 'package:mapped/pages/discover_overview_page.dart';
import 'package:mapped/pages/map_overview_page.dart';
import 'package:mapped/widgets/macros/account_view.dart';
import 'package:mapped/widgets/mediors/event_sheet.dart';
import 'package:mapped/widgets/mediors/search_bar.dart';
import 'package:mapped/widgets/mediors/top_bar.dart';
import 'package:mapped/widgets/mediors/user_sheet.dart';
import 'package:mapped/widgets/micros/account_drawer_button.dart';
import 'package:provider/provider.dart';
import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationContainer extends StatefulWidget {
  const NavigationContainer({
    super.key,
    this.givenIndex,
    this.event,
    this.user,
    this.filterOptions,
  });

  final int? givenIndex;
  final Event? event;
  final MappedUser? user;
  final FilterOptions? filterOptions;

  @override
  State<NavigationContainer> createState() => _NavigationContainerState();
}

class _NavigationContainerState extends State<NavigationContainer> {
  late int _selectedIndex = 0;

  late Event? eventFromWidget;

  bool buttonOverlayOpen = false;
  SearchOptions searchOptions = SearchOptions();

  setSelectedIndex(int i) {
    _selectedIndex = i;
    setState(() {});
  }

  late MappedUser mappedUser;

  void redirectIfNotLoggedIn(User? user) {
    if (user == null && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      if (mounted) {
        var mUser = context.read<MappedUser>();
        if (mUser.labels == null) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/sign_up/2', (route) => false);
        } else {
          print('User is signed in!');
        }
      }
    }
  }

  @override
  void initState() {
    eventFromWidget = widget.event;
    FirebaseAuth.instance.authStateChanges().listen(redirectIfNotLoggedIn);
    mappedUser = context.read<MappedUser>();
    if (eventFromWidget != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => showModalBottomSheet<void>(
          showDragHandle: true,
          backgroundColor: Theme.of(context).colorScheme.background,
          barrierColor: Colors.transparent,
          barrierLabel: "Event",
          isScrollControlled: true,
          constraints:
              BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .5),
          context: context,
          builder: (BuildContext context) {
            return EventSheet(
              event: eventFromWidget!,
            );
          },
        ),
      );
    }
    if (widget.user != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => showModalBottomSheet<void>(
          showDragHandle: true,
          backgroundColor: Theme.of(context).colorScheme.background,
          barrierColor: Colors.transparent,
          barrierLabel: "User",
          isScrollControlled: true,
          constraints:
              BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .5),
          context: context,
          builder: (BuildContext context) {
            return UserSheet(
              mappedUser: widget.user!,
            );
          },
        ),
      );
    }

    _selectedIndex = widget.givenIndex ?? 0;
    super.initState();
    init();
  }

  late ScreenshotCallback screenshotCallback;

  void init() async {
    await initScreenshotCallback();
  }

  Future<void> initScreenshotCallback() async {
    screenshotCallback = ScreenshotCallback();

    screenshotCallback.addListener(() async {
      await launchUrl(
          Uri.parse("https://youtu.be/dQw4w9WgXcQ?si=L3dzOgjY8fitf7RN"));
    });
  }

  @override
  void dispose() {
    screenshotCallback.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: searchOptions,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: [
            const Size.fromHeight(80),
            const Size.fromHeight(60),
            const Size.fromHeight(80),
            const Size.fromHeight(60),
          ][_selectedIndex],
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.red,
            title: [
              Container(),
              const TopBar(title: "Calender Overview"),
              Container(),
              const TopBar(title: "Account"),
            ][_selectedIndex],
            flexibleSpace: [
              const TopSearchBar(),
              Container(),
              const TopSearchBar(),
              Container(),
            ][_selectedIndex],
            forceMaterialTransparency: true,
            actions: [Container()],
          ),
        ),
        extendBodyBehindAppBar: [true, false, true, false][_selectedIndex],
        resizeToAvoidBottomInset: false,
        body: <Widget>[
          MapOverviewPage(
            event: eventFromWidget,
            filterOptions: widget.filterOptions,
          ),
          CalendarOverviewPage(
            mappedUser: mappedUser,
          ),
          DiscoverOverviewPage(
            event: eventFromWidget,
            filterOptions: widget.filterOptions,
          ),
          const AccountView(),
        ][_selectedIndex],
        bottomNavigationBar:
            searchOptions.term != null && searchOptions.term!.isEmpty
                ? null
                : BottomNavigationBar(
                    currentIndex: _selectedIndex,
                    showUnselectedLabels: true,
                    unselectedItemColor:
                        Theme.of(context).colorScheme.inversePrimary,
                    selectedItemColor: Theme.of(context).primaryColor,
                    selectedIconTheme: const IconThemeData(
                      size: 32,
                    ),
                    onTap: setSelectedIndex,
                    items: [
                      const BottomNavigationBarItem(
                          icon: Icon(Icons.map), label: 'Map'),
                      const BottomNavigationBarItem(
                          icon: Icon(Icons.calendar_today), label: 'Calendar'),
                      const BottomNavigationBarItem(
                          icon: Icon(Icons.explore), label: 'Discover'),
                      BottomNavigationBarItem(
                        label: "Account",
                        icon: AccountDrawerButton(
                          selected: _selectedIndex == 3,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
