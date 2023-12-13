import 'package:flutter/material.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:provider/provider.dart';

class AccountDrawerButton extends StatelessWidget {
  const AccountDrawerButton({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    var mUser = context.watch<MappedUser>();
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Theme.of(context).primaryColor),
      height: selected ? 47 : 40.0,
      width: selected ? 47 : 40.0,
      clipBehavior: Clip.antiAlias,
      child: (mUser.profilePicUrl != null)
          ? Image(
              image: NetworkImage(mUser.profilePicUrl!),
              fit: BoxFit.cover)
          : null,
    );
  }
}
