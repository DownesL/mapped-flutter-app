import 'package:flutter/material.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:mapped/widgets/micros/friendship_toggle.dart';
import 'package:mapped/widgets/micros/profile_pic.dart';
import 'package:provider/provider.dart';

class UserTile extends StatelessWidget {
  const UserTile({
    super.key,
    required this.mappedUser,
  });

  final MappedUser mappedUser;

  @override
  Widget build(BuildContext context) {
    MappedUser cU = context.watch<MappedUser>();
    bool areFriends = false;
    if (cU != null) {
      areFriends = cU.friends!.contains(mappedUser.uid);
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ListTile(
        onTap: () => Navigator.pushNamed(
          context,
          '/home/user',
          arguments: UserArguments(mUser: mappedUser),
        ),
        leading: ProfilePic(
          size: 40,
          mappedUser: mappedUser,
        ),
        title: Text(
          mappedUser.displayName ?? "Danny",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(areFriends
            ? "Friends"
            : "Add ${mappedUser.displayName ?? "Danny"} as a friend!"),
        trailing: FriendshipToggle(
          mappedUser: mappedUser,
        ),
      ),
    );
  }
}
