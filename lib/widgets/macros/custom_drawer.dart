import 'package:flutter/material.dart';
import 'package:mapped/models/destination.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:mapped/widgets/micros/user_info_widget.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    super.key,
    required this.destinations,
    required this.mappedUser,
    required this.currentPath,
  });

  final List<Destination> destinations;
  final String currentPath;
  final MappedUser mappedUser;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 100,
            width: MediaQuery.sizeOf(context).width,
            child: DrawerHeader(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Image(
                    image: AssetImage("assets/logo.png"),
                    height: 20,
                    fit: BoxFit.fitHeight,
                  ),
                  CloseButton(
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: UserInfoWidget(),
          ),
          const Divider(),
          for (var el in destinations)
            ListTile(
              title: Text(el.name),
              leading: Icon(el.icon),
              onTap: () {
                if (el.path == currentPath) {
                  Navigator.pop(context);
                } else {
                  Navigator.popAndPushNamed(context, el.path);
                }
              },
            )
        ],
      ),
    );
  }
}
