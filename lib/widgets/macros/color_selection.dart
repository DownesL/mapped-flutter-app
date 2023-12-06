import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mapped/models/labels.dart';
import 'package:mapped/widgets/micros/color_selector.dart';
import 'package:provider/provider.dart';

class ColorSelection extends StatefulWidget {
  const ColorSelection({super.key});

  @override
  State<ColorSelection> createState() => _ColorSelectionState();
}

class _ColorSelectionState extends State<ColorSelection> {
  late Color publicColor;
  late Color privateColor;
  late Color friendColor;
  late Labels labels;
  String? errorMessage;

  void changePublicColor(Color color) {
    labels.setPublicColor(color);
    setState(() => publicColor = color);
  }

  void changePrivateColor(Color color) {
    labels.setPrivateColor(color);
    setState(() => privateColor = color);
  }

  void changeFriendColor(Color color) {
    labels.setFriendColor(color);
    setState(() => friendColor = color);
  }

  @override
  void initState() {
    super.initState();
    labels = context.read<Labels>();
    publicColor = Color(labels.public);
    privateColor = Color(labels.private);
    friendColor = Color(labels.friend);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32.0),
        ColorSelector(
          color: publicColor,
          label: 'Choose Public Color',
          action: () => _dialogBuilder(context, publicColor, changePublicColor),
        ),
        const SizedBox(height: 16.0),
        ColorSelector(
          color: privateColor,
          label: 'Choose Private Color',
          action: () =>
              _dialogBuilder(context, privateColor, changePrivateColor),
        ),
        const SizedBox(height: 16.0),
        ColorSelector(
          color: friendColor,
          label: 'Choose Friend Color',
          action: () => _dialogBuilder(context, friendColor, changeFriendColor),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Future<void> _dialogBuilder(
      BuildContext context, Color pickerCol, void Function(Color) callBack) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a Color'),
          content: Wrap(
            children: [
              HueRingPicker(
                colorPickerHeight: 200,
                pickerColor: pickerCol,
                onColorChanged: callBack,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Choose Color'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
