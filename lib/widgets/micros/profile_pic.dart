import 'package:flutter/material.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:provider/provider.dart';

class ProfilePic extends StatefulWidget {
  const ProfilePic({
    super.key,
    required this.size,
    this.mappedUser,
  });

  final double size;
  final MappedUser? mappedUser;

  @override
  State<ProfilePic> createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> {
  @override
  Widget build(BuildContext context) {
    MappedUser mappedUser = widget.mappedUser ?? context.watch<MappedUser>();
    return Container(
      height: widget.size,
      width: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).primaryColor,
      ),
      clipBehavior: Clip.antiAlias,
      child: (mappedUser.profilePicUrl != null)
          ? Image(
              image: NetworkImage(mappedUser.profilePicUrl!), fit: BoxFit.cover)
          : null,
    );
  }
}
