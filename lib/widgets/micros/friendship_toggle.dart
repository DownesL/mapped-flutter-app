import 'package:flutter/material.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:provider/provider.dart';

class FriendshipToggle extends StatelessWidget {
  const FriendshipToggle({super.key, required this.mappedUser});

  final MappedUser mappedUser;

  @override
  Widget build(BuildContext context) {
    var cU = context.watch<MappedUser>();
    bool areFriends = cU.friends!.contains(mappedUser.uid);
    bool pending = cU.pending!.keys.contains(mappedUser.uid);
    bool sender = false;
    if (pending) {
      sender = cU.pending![mappedUser.uid]!;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!sender)
            IconButton.outlined(
              // ignore: prefer_const_constructors
              style: ButtonStyle(
                side: const MaterialStatePropertyAll(
                  BorderSide(
                    color: Colors.green,
                  ),
                ),
              ),
              onPressed: () {
                cU.acceptPending(mappedUser);
              },
              icon: const Icon(
                Icons.check,
                color: Colors.green,
              ),
            ),
          IconButton.outlined(
            style: ButtonStyle(
              side: MaterialStatePropertyAll(
                BorderSide(
                  color: sender
                      ? Theme.of(context).colorScheme.tertiary
                      : Colors.red,
                ),
              ),
            ),
            onPressed: () {
              cU.removePending(mappedUser);
            },
            icon: Icon(
              sender ? Icons.schedule_send : Icons.close,
              color:
                  sender ? Theme.of(context).colorScheme.tertiary : Colors.red,
            ),
          ),
        ],
      );
    }
    return IconButton.outlined(
        style: ButtonStyle(
          side: MaterialStatePropertyAll(
            BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ),
        icon: Icon(
          areFriends ? Icons.person_remove : Icons.person_add,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        onPressed: () => cU.toggleFriendship(mappedUser, areFriends, pending));
  }
}
