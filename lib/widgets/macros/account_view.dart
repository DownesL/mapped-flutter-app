import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:mapped/widgets/mediors/events_view.dart';
import 'package:mapped/widgets/micros/user_info_widget.dart';
import 'package:provider/provider.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {

  void signOut() async {

    await FirebaseAuth.instance.signOut();
    if (mounted) {
      var mU = context.read<MappedUser>();
      mU.clearValues();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                UserInfoWidget(
                  size: 80,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                      Theme.of(context).colorScheme.background),
                  foregroundColor: MaterialStatePropertyAll(Theme.of(context).textTheme.labelLarge!.color),
                  textStyle: const MaterialStatePropertyAll(TextStyle(fontSize: 20)),
                  iconSize: const MaterialStatePropertyAll(20.0),
                ),
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
                onPressed: () => Navigator.pushNamed(context, '/account/edit'),
              ),
              const Spacer(),
              ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                      Theme.of(context).colorScheme.errorContainer),
                  foregroundColor: MaterialStatePropertyAll(
                      Theme.of(context).colorScheme.error),
                  textStyle: const MaterialStatePropertyAll(TextStyle(fontSize: 16)),
                  iconSize: const MaterialStatePropertyAll(20.0),
                ),
                icon: const Icon(Icons.logout),
                label: const Text("Log out"),
                onPressed: () {
                  signOut();
                },
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/friends'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                        Theme.of(context).colorScheme.primaryContainer),
                    foregroundColor: MaterialStatePropertyAll(
                        Theme.of(context).colorScheme.primary),
                  ),
                  icon: const Icon(
                    Icons.group,
                    size: 16,
                  ),
                  label: const Text(
                    'Friends',
                    style: TextStyle(fontSize: 14),
                  )),
              ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/events'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                        Theme.of(context).colorScheme.secondaryContainer),
                    foregroundColor: MaterialStatePropertyAll(
                        Theme.of(context).colorScheme.secondary),
                  ),
                  icon: const Icon(
                    Icons.event,
                    size: 16,
                  ),
                  label: const Text(
                    'Events',
                    style: TextStyle(fontSize: 14),
                  )),
              ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/scanner'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                        Theme.of(context).colorScheme.tertiaryContainer),
                    foregroundColor: MaterialStatePropertyAll(
                        Theme.of(context).colorScheme.tertiary),
                  ),
                  icon: const Icon(
                    Icons.qr_code_scanner,
                    size: 16,
                  ),
                  label: const Text(
                    'Scan QR',
                    style: TextStyle(fontSize: 14),
                  )),
            ],
          ),
          const Divider(),
          const SizedBox(
            height: 16.0,
          ),
          Text(
            "Upcoming Events",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(
            height: 8.0,
          ),
          Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white60,
                border: Border.all(
                  color: Colors.black12,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * .5,
              ),
              child: const EventsView(
                startDateFilter: true,
              ))
        ],
      ),
    );
  }
}
