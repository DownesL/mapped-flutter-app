import 'package:flutter/material.dart';
import 'package:mapped/firebase_service.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final displayNameController = TextEditingController();
  var fS = FirebaseService();

  String? errorMessage;

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
              Text(
                'Sign up',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(
                height: 16.0,
              ),
              if (errorMessage != null) Text(errorMessage!),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Display Name',
                ),
                controller: displayNameController,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a dispaly name';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 16.0,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'email',
                ),
                controller: emailController,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email address';
                  }
                  var match = RegExp(
                      r"[a-zA-Z0-9._\-]{0,15}@[a-z\-]{2,8}\.[a-z.]{2,6}")
                      .stringMatch(value);
                  if (match == null || match.isEmpty) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 16.0,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Confirm email',
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm email address';
                  } else if (value != emailController.value.text) {
                    return "Email addresses don't match";
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 16.0,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
                controller: passwordController,
                obscureText: true,
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
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Confirm Password',
                ),
                obscureText: true,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm password';
                  } else if (value != passwordController.value.text) {
                    return "Passwords don't match";
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 16.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () => {
                    if (_formKey.currentState!.validate()) {signUp(context)}
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 64.0),
                  ),
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void signUp(BuildContext context) async {
    var mUser = context.read<MappedUser>();
    var message = await fS.firestoreSignUp(
      mUser,
      emailController.text,
      passwordController.text,
      displayNameController.text,
    );
    if (message == null && context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/sign_up/2', (route) => false);
    } else {
      errorMessage = message;
    }
  }
}
