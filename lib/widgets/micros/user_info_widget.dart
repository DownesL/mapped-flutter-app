import 'package:flutter/material.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:mapped/widgets/micros/profile_pic.dart';
import 'package:mapped/widgets/micros/qr_code_popup.dart';
import 'package:provider/provider.dart';

class UserInfoWidget extends StatelessWidget {
  const UserInfoWidget({super.key, this.size = 50, this.mappedUser});

  final double size;
  final MappedUser? mappedUser;

  @override
  Widget build(BuildContext context) {
    var mUser = mappedUser ?? context.watch<MappedUser>();

    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          ProfilePic(size: size),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(mUser.displayName!,
                  style: Theme.of(context).textTheme.titleLarge),
              Text(mUser.email!),
            ],
          ),
          const SizedBox(
            width: 32.0,
          ),
          const Spacer(),
          QRCodePopup(url: 'users/${mUser.uid}'),
        ],
      ),
    );
  }
}
