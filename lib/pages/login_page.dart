import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:mapped/firebase_service.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var fS = FirebaseService();
  bool wrongCredentials = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Login',
              ),
              if (wrongCredentials)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  padding: const EdgeInsets.symmetric(
                      vertical: 3.0, horizontal: 10.0),
                  decoration: BoxDecoration(
                      color: const Color(0x66BB2342),
                      border: Border.all(color: Colors.red)),
                  child: const Text(
                    'Wrong Credentials',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(
                height: 16.0,
              ),
              TextFormField(
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'email',
                ),
                controller: emailController,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email address';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 16.0,
              ),
              TextFormField(
                textInputAction: TextInputAction.go,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
                obscureText: true,
                controller: passwordController,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 16.0,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: FilledButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      signIn(context);
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 64.0),
                  ),
                  child: const Text('Submit'),
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/sign_up');
                    },
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            width: 2.0,
                            color: Theme.of(context).colorScheme.primary),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 64.0)),
                    child: const Text('Sign up')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void signIn(BuildContext context) async {
    var mUser = context.read<MappedUser>();
    var canVibrate = await Haptics.canVibrate();
    try {
      UserCredential result =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.value.text,
        password: passwordController.value.text,
      );
      User? user = result.user;
      if (user != null) {
        mUser.upDateFirebaseUser(user);
        mUser.setValues(await fS.getUser());
        if (canVibrate) {
          await Haptics.vibrate(HapticsType.success);
        }
        if (context.mounted) {
          if (mUser.isNotEmpty) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/sign_up/2',
              (route) => false,
            );
          }
        }
      }
    } on FirebaseAuthException {
      emailController.clear();
      passwordController.clear();
      wrongCredentials = true;
      setState(() {});
      if (canVibrate) {
        await Haptics.vibrate(HapticsType.error);
      }
    }
  }
}
