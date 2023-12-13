import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoder_buddy/geocoder_buddy.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapped/firebase_service.dart';
import 'package:mapped/models/event.dart';
import 'package:mapped/models/labels.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:mapped/models/search_options.dart';
import 'package:mapped/pages/map_overview_page.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'firebase_mock.dart';
import 'marker_tap_test.mocks.dart';

@GenerateNiceMocks([MockSpec<FirebaseService>()])
main() {
  var fSMock = MockFirebaseService();
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });
  testWidgets("Markerlayer generates no markers", (WidgetTester tester) async {
    var mU = MappedUser(
      uid: "123",
      labels: Labels(
        public: 0xff123123,
        private: 0xff123123,
        friend: 0xff123123,
      ),
      friends: [],
      pending: {},
      attendingEventsIDs: [],
      organisedEventsIDs: [],
    );
    when(fSMock.getUser()).thenAnswer(
      (realInvocation) => Future.value(
        mU,
      ),
    );

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: mU,
      child: MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider(
              create: (BuildContext context) => SearchOptions(),
              child: const MapOverviewPage()),
        ),
      ),
    ));

    var markers = find.byType(Marker);

    expect(markers, findsNothing);
  });
  testWidgets("Markerlayer generates all markers", (WidgetTester tester) async {
    var mU = MappedUser(
      uid: "123",
      labels: Labels(
        public: 0xff123123,
        private: 0xff123123,
        friend: 0xff123123,
      ),
      friends: [],
      pending: {},
      attendingEventsIDs: ["Event 1"],
      organisedEventsIDs: [],
    );
    when(fSMock.getUser()).thenAnswer(
      (realInvocation) => Future.value(
        mU,
      ),
    );
    when(fSMock.getUserEvents(mU)).thenAnswer((realInvocation) => Future.value([
          Event(
              eid: "aaa",
              name: "lukas",
              startDate: DateTime.now(),
              endDate: DateTime.now(),
              address: Address(),
              attendeeIDs: [],
              organiserIDs: [],
              pictureList: [],
              eventType: EventType.public,
              description: "",
              latLng: const LatLng(12.0, 12.0))
        ]));

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: mU,
      child: MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider(
              create: (BuildContext context) => SearchOptions(),
              child: const MapOverviewPage()),
        ),
      ),
    ));

    var markers = find.byType(Marker);

    expect(markers, findsOneWidget);
  });
}
