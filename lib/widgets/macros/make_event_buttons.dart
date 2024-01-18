import 'package:flutter/material.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:mapped/widgets/micros/make_event_button.dart';
import 'package:provider/provider.dart';

class MakeEventButtons extends StatefulWidget {
  const MakeEventButtons({super.key});

  @override
  State<MakeEventButtons> createState() => _MakeEventButtonsState();
}

class _MakeEventButtonsState extends State<MakeEventButtons> {
  bool eventBtnsHidden = true;

  @override
  Widget build(BuildContext context) {
    MappedUser user = context.watch<MappedUser>();
    Color public = Color(user.labels!.public);
    Color private = Color(user.labels!.private);
    Color friend = Color(user.labels!.friend);
    return Container(
      padding: const EdgeInsets.only(
        bottom: 8.0,
        right: 8.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!eventBtnsHidden)
            MakeEventButton(
              color: public,
              label: 'New Public Event',
              onPressed: () => Navigator.pushNamed(context, '/events/public/add'),
            ),
          if (!eventBtnsHidden)
            MakeEventButton(
              color: friend,
              label: 'New Friend Event',
              onPressed: () => Navigator.pushNamed(context, '/events/friend/add'),
            ),
          if (!eventBtnsHidden)
            MakeEventButton(
              color: private,
              label: 'New Private Event',
              onPressed: () => Navigator.pushNamed(context, '/events/private/add'),
            ),
          FloatingActionButton(
            onPressed: () {
              eventBtnsHidden = !eventBtnsHidden;
              setState(() {});
            },
            backgroundColor: Theme.of(context).colorScheme.background,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: eventBtnsHidden
                ? Icon(
                    Icons.edit_calendar,
                    semanticLabel: 'Add new Event',
                    color: Theme.of(context).primaryColor,
                    size: 32,
                  )
                : Icon(
                    Icons.close,
                    semanticLabel: 'Close overlay',
                    color: Theme.of(context).primaryColor,
                    size: 32,
                  ),
          )
        ],
      ),
    );
  }
}
