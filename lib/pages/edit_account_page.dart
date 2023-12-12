import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapped/firebase_service.dart';
import 'package:mapped/image_util.dart';
import 'package:mapped/models/labels.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:mapped/utils.dart';
import 'package:mapped/widgets/macros/color_selection.dart';
import 'package:mapped/widgets/mediors/top_bar.dart';
import 'package:mapped/widgets/micros/profile_pic.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({
    super.key,
  });

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late MappedUser mUser;
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  late Labels newLabels;
  String? errorMessage;

  var fS = FirebaseService();
  var iU = ImageUtil();

  List<XFile>? _mediaFileList;
  late User user;

  dynamic _pickImageError;
  String? _retrieveDataError;
  bool isVideo = false;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();

  final nameController = TextEditingController();
  final locationController = TextEditingController();

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (response.type == RetrieveType.video) {
        isVideo = true;
      } else {
        isVideo = false;
        setState(() {
          if (response.files == null) {
            _mediaFileList = iU.setImageFileListFromFile(response.file);
          } else {
            _mediaFileList = response.files;
          }
        });
      }
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  Future<void> _onImageButtonPressed(
    ImageSource source, {
    required BuildContext context,
  }) async {
    if (context.mounted) {
      await iU.displayPickImageDialog(context,
          (double? maxWidth, double? maxHeight, int? quality) async {
        try {
          final XFile? pickedFile = await _picker.pickImage(
            source: source,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            imageQuality: quality,
          );
          setState(() {
            _mediaFileList = iU.setImageFileListFromFile(pickedFile);
          });
        } catch (e) {
          setState(() {
            _pickImageError = e;
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    mUser = context.watch<MappedUser>();
    displayNameController.text = mUser.displayName!;
    emailController.text = mUser.email!;
    newLabels = Labels.copy(mUser.labels!);
    return Scaffold(
      appBar: AppBar(
        title: const TopBar(title: 'Edit account'),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 16.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  !kIsWeb && defaultTargetPlatform == TargetPlatform.android
                      ? FutureBuilder<void>(
                          future: retrieveLostData(),
                          builder: (BuildContext context,
                              AsyncSnapshot<void> snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                              case ConnectionState.waiting:
                                return const Text(
                                  'You have not yet picked an image.',
                                  textAlign: TextAlign.center,
                                );
                              case ConnectionState.done:
                                return iU.handlePreview(
                                      isVideo,
                                      _mediaFileList,
                                      _retrieveDataError,
                                      _pickImageError,
                                    ) ??
                                    ProfilePic(size: 100);
                              case ConnectionState.active:
                                if (snapshot.hasError) {
                                  return Text(
                                    'Pick image/video error: ${snapshot.error}}',
                                    textAlign: TextAlign.center,
                                  );
                                } else {
                                  return const Text(
                                    'You have not yet picked an image.',
                                    textAlign: TextAlign.center,
                                  );
                                }
                            }
                          },
                        )
                      : iU.handlePreview(
                            isVideo,
                            _mediaFileList,
                            _retrieveDataError,
                            _pickImageError,
                          ) ??
                          ProfilePic(size: 100),
                  ElevatedButton.icon(
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      size: 16,
                    ),
                    label: const Text('Take new'),
                    onPressed: () => _onImageButtonPressed(ImageSource.camera,
                        context: context),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Library'),
                    onPressed: () => _onImageButtonPressed(ImageSource.gallery,
                        context: context),
                  ),
                ],
              ),
              const SizedBox(
                height: 32.0,
              ),
              Form(
                  child: Column(
                children: [
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
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a email name';
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
                ],
              )),
              ChangeNotifierProvider.value(
                value: newLabels,
                child: const ColorSelection(),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.red),
                      foregroundColor: MaterialStatePropertyAll(Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.green),
                      foregroundColor: MaterialStatePropertyAll(Colors.white),
                    ),
                    onPressed: () => saveAccount(),
                    child: const Text("Save"),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  saveAccount() async {
    if (_mediaFileList != null && _mediaFileList!.isNotEmpty) {
      mUser.updateProfilePic(_mediaFileList!.last);
    }
    if (!areSameColors(mUser.labels!, newLabels)) {
      var message = await fS.setFirestoreColorData(mUser, newLabels);
      if (message != null) {
        errorMessage = message;
      }
    }
    if (emailController.text != mUser.email) {
      await fS.updateEmailAddress(emailController.text);
      mUser = await fS.getUser();
      mUser.updateEmail(emailController.text);
    }
    if (displayNameController.text != mUser.displayName) {
      await fS.updateDisplayName(displayNameController.text);
      mUser.updateDisplayName(displayNameController.text);
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }
}
