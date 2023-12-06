import 'package:flutter/material.dart';
import 'package:mapped/models/mapped_user.dart';

class AccountPageHeader extends StatelessWidget {
  const AccountPageHeader({super.key, required this.mappedUser});

  final MappedUser mappedUser;

  @override
  Widget build(BuildContext context) {
    return const PreferredSize(
      preferredSize: Size.fromHeight(200),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [],
      ),
    );
  }
}
