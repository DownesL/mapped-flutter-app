import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapped/firebase_service.dart';
import 'package:mapped/image_util.dart';
import 'package:mapped/models/event.dart';
import 'package:provider/provider.dart';

class AddImageOverlay extends StatefulWidget {
  const AddImageOverlay({super.key, required this.closeFunction});

  final Function() closeFunction;

  @override
  State<AddImageOverlay> createState() => _AddImageOverlayState();
}

class _AddImageOverlayState extends State<AddImageOverlay> {
  dynamic _pickImageError;
  String? _retrieveDataError;
  bool isVideo = false;
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();

  var iU = ImageUtil();

  List<XFile>? _mediaFileList = [];

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
            var imgs = iU.setImageFileListFromFile(response.file);
            if (_mediaFileList != null) {
              _mediaFileList!.add(imgs!.last);
            } else {
              _mediaFileList = imgs;
            }
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
          var imgs = iU.setImageFileListFromFile(pickedFile);
          if (_mediaFileList != null) {
            _mediaFileList!.add(imgs!.last);
          } else {
            _mediaFileList = imgs;
          }
          setState(() {});
        } catch (e) {
          setState(() {
            _pickImageError = e;
          });
        }
      });
    }
  }

  List<String> imgList = [];

  @override
  Widget build(BuildContext context) {
    var event = context.read<Event>();
    imgList = [];
    for (var element in event.pictureList) {
      imgList.add(element);
    }
    if (_mediaFileList != null && _mediaFileList!.isNotEmpty) {
      for (var element in _mediaFileList!) {
        imgList.add(element.path);
      }
    }

    return Scaffold(
      backgroundColor: Colors.black54,
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(20),
        ),
        width: MediaQuery.sizeOf(context).width * .9,
        padding: EdgeInsets.all(16.0),
        margin: EdgeInsets.symmetric(
          vertical: MediaQuery.sizeOf(context).height * .2,
          horizontal: MediaQuery.sizeOf(context).width * .1,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add or remove images',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Flexible(
              child: Container(
                height: 250,
                padding: EdgeInsets.symmetric(
                  vertical: 25,
                ),
                width: double.maxFinite,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: [
                    if (imgList.isNotEmpty)
                      for (var pic in imgList)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 8.0),
                              width: 250,
                              height: 200,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)),
                              clipBehavior: Clip.antiAlias,
                              child: pic.contains("/data/user/0")
                                  ? Image(
                                      fit: BoxFit.cover,
                                      image: FileImage(File(pic)))
                                  : Image(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(pic),
                                    ),
                            ),
                            FilledButton.icon(
                              onPressed: () {
                                if (pic.contains("/data/user/0")) {
                                  _mediaFileList = _mediaFileList!
                                      .where((item) => item.path != pic)
                                      .toList();
                                } else {
                                  event.pictureList.remove(pic);
                                }
                                setState(() {});
                              },
                              icon: Icon(Icons.close),
                              style: ButtonStyle(
                                visualDensity: VisualDensity.compact,
                              ),
                              label: Text("Remove Picture"),
                            )
                          ],
                        ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          FilledButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Add'),
                            onPressed: () => _onImageButtonPressed(
                                ImageSource.gallery,
                                context: context),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (isLoading)
                  CircularProgressIndicator(),
                Spacer(),
                OutlinedButton(
                  style: ButtonStyle(
                    side: MaterialStatePropertyAll(
                      BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  child: const Text('Cancel'),
                  onPressed: widget.closeFunction,
                ),
                FilledButton(
                  child: const Text('Save'),
                  onPressed: () {
                    save();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  save() async {
    setState(() {
      isLoading = true;
    });
    var fS = FirebaseService();
    var event = context.read<Event>();
    var updatedList =
        imgList.where((pic) => !pic.contains("/data/user/0")).toList();
    if (_mediaFileList != null) {
      for (var img in _mediaFileList!) {
        var url = await fS.uploadImage(
          "/events/${event.eid}/${img.name}",
          File(img.path),
        );
        if (url != null) {
          updatedList.add(url);
        }
      }
    }
    event.updatePictureList(updatedList);
    await fS.updateEvent(event);
    setState(() {
      isLoading = false;
    });

    widget.closeFunction();
  }
}
