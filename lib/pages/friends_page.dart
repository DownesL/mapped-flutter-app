import 'package:flutter/material.dart';
import 'package:mapped/firebase_service.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:mapped/widgets/mediors/top_bar.dart';
import 'package:mapped/widgets/micros/user_info_widget.dart';
import 'package:mapped/widgets/micros/user_tile.dart';
import 'package:provider/provider.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({
    super.key,
  });

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<MappedUser> pendingRequests = [];
  List<MappedUser> friends = [];
  late MappedUser mUser;


  var fS = FirebaseService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    mUser = context.watch<MappedUser>();
    setUserFriends(mUser);
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: AppBar(
            forceMaterialTransparency: true,
            title: const TopBar(title: "Friends"),
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width,
                height: 16.0,
              ),
              Text(
                "Pending Requests",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (pendingRequests.isEmpty)
                const Text("No pending requests")
              else
                Flexible(
                  fit: FlexFit.loose,
                  child: ListView.builder(
                    itemCount: pendingRequests.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) =>
                        UserTile(mappedUser: pendingRequests[index]),
                  ),
                ),
              Text(
                "Friends",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (friends.isEmpty)
                const Text("Do you need help making friends?")
              else
                Flexible(
                  fit: FlexFit.loose,
                  child: ListView.builder(
                    itemCount: friends.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) =>
                        UserTile(mappedUser: friends[index]),
                  ),
                ),
            ],
          ),
        ));
  }

  void setUserFriends(MappedUser mappedUser) async {
    if (mappedUser.pending != null && mappedUser.pending!.isNotEmpty) {
      pendingRequests = await fS.getUserFriends(mappedUser.pending!);
    }
    if (mappedUser.friends != null && mappedUser.friends!.isNotEmpty) {
      friends = await fS.getUserFriends(mappedUser.friends!);
    }
  }
}
