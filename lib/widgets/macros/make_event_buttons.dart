import 'package:flutter/material.dart';
import 'package:mapped/widgets/micros/make_event_button.dart';

class MakeEventButtons extends StatefulWidget {
  const MakeEventButtons({super.key});

  @override
  State<MakeEventButtons> createState() => _MakeEventButtonsState();
}

class _MakeEventButtonsState extends State<MakeEventButtons> {
  bool eventBtnsHidden = true;

  @override
  Widget build(BuildContext context) {
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
              color: Theme.of(context).colorScheme.primary,
              label: 'New Public Event',
              onPressed: () => Navigator.pushNamed(context, '/make_event/public'),
            ),
          if (!eventBtnsHidden)
            MakeEventButton(
              color: Theme.of(context).colorScheme.secondary,
              label: 'New Friend Event',
              onPressed: () => Navigator.pushNamed(context, '/make_event/friend'),
            ),
          if (!eventBtnsHidden)
            MakeEventButton(
              color: Theme.of(context).colorScheme.tertiary,
              label: 'New Private Event',
              onPressed: () => Navigator.pushNamed(context, '/make_event/private'),
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
