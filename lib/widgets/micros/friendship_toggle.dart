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
    bool pending = cU.pending!.contains(mappedUser.uid);
    return IconButton.outlined(
        style: ButtonStyle(
          side: MaterialStatePropertyAll(
            BorderSide(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ),
        icon: Icon(
          areFriends
              ? Icons.person_remove
              : (pending ? Icons.schedule_send : Icons.person_add),
          color: Theme.of(context).colorScheme.tertiary,
        ),
        onPressed: () => cU.toggleFriendship(mappedUser, areFriends, pending));
  }
}
