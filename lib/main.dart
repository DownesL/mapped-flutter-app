import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapped/firebase_options.dart';
import 'package:mapped/firebase_service.dart';
import 'package:mapped/models/destination.dart';
import 'package:mapped/models/event.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:mapped/pages/edit_account_page.dart';
import 'package:mapped/pages/events_page.dart';
import 'package:mapped/pages/friends_page.dart';
import 'package:mapped/pages/login_page.dart';
import 'package:mapped/pages/make_event_page.dart';
import 'package:mapped/pages/navigation_container.dart';
import 'package:mapped/pages/qr_scanner_page.dart';
import 'package:mapped/pages/sign_up_page.dart';
import 'package:mapped/pages/sign_up_page_2.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await requestPermission();

  var fS = FirebaseService();
  var user = await fS.getUser();
  runApp(
    ChangeNotifierProvider(
      create: (context) => user,
      child: const Mapped(),
    ),
  );
}

Future<void> requestPermission() async {
  const permissions = [Permission.camera, Permission.location, Permission.manageExternalStorage, Permission.photos];
  for (var permission in permissions) {
    if (await permission.isDenied) {
      await permission.request();
    }
  }
}

List<Destination> destinations = [
  Destination(name: "Home", icon: Icons.home, path: "/home"),
  Destination(name: "Account", icon: Icons.person, path: "/account"),
  Destination(name: "Friends", icon: Icons.group, path: "/friends"),
  Destination(name: "My Events", icon: Icons.event, path: "/events"),
  Destination(
      name: "Scan QR-code", icon: Icons.qr_code_scanner, path: "/account"),
];

class Mapped extends StatelessWidget {
  const Mapped({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.assistantTextTheme().copyWith(
          titleLarge: GoogleFonts.blinker(
              letterSpacing: 1.3, fontWeight: FontWeight.w700),
          titleMedium: GoogleFonts.blinker(
              letterSpacing: 1.3, fontWeight: FontWeight.w700),
          titleSmall: GoogleFonts.blinker(
              letterSpacing: 1.3, fontWeight: FontWeight.w700),
          labelLarge: GoogleFonts.blinker(
              letterSpacing: 1.3, fontWeight: FontWeight.w700),
          labelMedium: GoogleFonts.blinker(
              letterSpacing: 1.3, fontWeight: FontWeight.w700),
          labelSmall: GoogleFonts.blinker(
              letterSpacing: 1.3, fontWeight: FontWeight.w700),
        ),
        colorScheme:
            ColorScheme.fromSeed(seedColor: const Color(0xff912841)).copyWith(
          background: Colors.white,
          primary: const Color(0xff912841),
          primaryContainer: const Color(0xF5F6B9C5),
          //contrast of: 4.9:1
          secondary: const Color(0xff285091),
          secondaryContainer: const Color(0xFFC2D7FF),
          //contrast of: 5.46:1
          tertiary: const Color(0xff237a51),
          tertiaryContainer: const Color(0xffDCF4E6), //contrast of: 4.56:1
        ),
      ),
      home: const NavigationContainer(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/sign_up': (context) => const SignUpPage(),
        '/sign_up/2': (context) => const SignUpPageExtended(),
        '/home': (context) => const NavigationContainer(),
        '/home/event': (context) => NavigationContainer(
            event:
                (ModalRoute.of(context)!.settings.arguments as EventArguments)
                    .event),
        '/home/user': (context) => NavigationContainer(
            user: (ModalRoute.of(context)!.settings.arguments as UserArguments)
                .mUser),
        '/calendar': (context) => const NavigationContainer(givenIndex: 1),
        '/account': (context) => const NavigationContainer(givenIndex: 3),
        '/account/edit': (context) => const AccountPage(),
        '/make_event/public': (context) => const MakeEventPage(
              eventType: EventType.public,
              restorationId: "publicEvent",
            ),
        '/make_event/friend': (context) => const MakeEventPage(
              eventType: EventType.friend,
              restorationId: "friendEvent",
            ),
        '/make_event/private': (context) => const MakeEventPage(
              eventType: EventType.private,
              restorationId: "privateEvent",
            ),
        '/events': (context) => const EventsPage(),
        '/friends': (context) => const FriendsPage(),
        '/scanner': (context) => const QRScannerPage(),
      },
    );
  }
}
