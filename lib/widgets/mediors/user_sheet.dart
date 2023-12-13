import 'package:flutter/material.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:mapped/widgets/micros/friendship_toggle.dart';
import 'package:mapped/widgets/micros/profile_pic.dart';
import 'package:mapped/widgets/micros/qr_code_popup.dart';
import 'package:provider/provider.dart';

class UserSheet extends StatelessWidget {
  const UserSheet({super.key, required this.mappedUser});

  final MappedUser mappedUser;

  @override
  Widget build(BuildContext context) {
    var mUser = context.watch<MappedUser>();
    bool areFriends = mUser.friends!.contains(mappedUser.uid);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: ProfilePic(size: 40, mappedUser: mappedUser,),
            contentPadding: EdgeInsets.all(0),
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
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              QRCodePopup(url: 'users/${mappedUser.uid}'),
              Spacer(),
              IconButton.outlined(
                style: ButtonStyle(
                  side: MaterialStatePropertyAll(
                    BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                onPressed: () {},
                icon: Icon(
                  Icons.share,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              FriendshipToggle(mappedUser: mappedUser),
            ],
          ),
          SizedBox(
            height: 16,
          )
        ],
      ),
    );
  }
}
