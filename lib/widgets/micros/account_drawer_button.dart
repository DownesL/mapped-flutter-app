import 'package:flutter/material.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:provider/provider.dart';

class AccountDrawerButton extends StatefulWidget {
  const AccountDrawerButton({super.key});

  @override
  State<AccountDrawerButton> createState() => _AccountDrawerButtonState();
}

class _AccountDrawerButtonState extends State<AccountDrawerButton> {

  MappedUser? mUser;

  @override
  void initState() {
    super.initState();
    mUser = context.read<MappedUser>();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Theme.of(context).primaryColor),
      height: 40.0,
      width: 40.0,
      clipBehavior: Clip.antiAlias,
      child: (mUser?.profilePicUrl != null)
          ? Image(
              image: NetworkImage(mUser!.profilePicUrl!),
              fit: BoxFit.cover)
          : null,
    );
  }
}
