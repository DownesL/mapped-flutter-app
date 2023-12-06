import 'package:flutter/material.dart';
import 'package:mapped/firebase_service.dart';
import 'package:mapped/models/labels.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:mapped/widgets/macros/color_selection.dart';
import 'package:provider/provider.dart';

class SignUpPageExtended extends StatefulWidget {
  const SignUpPageExtended({super.key});

  @override
  State<SignUpPageExtended> createState() => _SignUpPageExtendedState();
}

class _SignUpPageExtendedState extends State<SignUpPageExtended> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Color publicColor = const Color(0xff8c2cb9);
  Color privateColor = const Color(0xff4dca49);
  Color friendColor = const Color(0xff0b6dce);
  var fS = FirebaseService();

  String? errorMessage;

  late Labels newLabels;

  @override
  Widget build(BuildContext context) {
    newLabels = Labels(
      public: publicColor.value,
      private: privateColor.value,
      friend: friendColor.value,
    );
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              "Pick your Colors",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (errorMessage != null) Text(errorMessage!),
            ChangeNotifierProvider.value(
              value: newLabels,
              child: const ColorSelection(),
            ),
            FilledButton(
                onPressed: () => setColors(context),
                child: const Text("Continue"))
          ]),
        ),
      ),
    );
  }

  void setColors(BuildContext context) async {
    var mUser = context.read<MappedUser>();
    var message = await fS.setFirestoreColorData(
      mUser,
      newLabels,
    );
    //mUser.setValues(await getUser());
    if (message == null && context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    } else {
      errorMessage = message;
    }
  }
}
