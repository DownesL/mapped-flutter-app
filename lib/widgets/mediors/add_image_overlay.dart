import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  final ImagePicker _picker = ImagePicker();

  var iU = ImageUtil();

  List<XFile>? _mediaFileList;

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
          _mediaFileList = iU.setImageFileListFromFile(pickedFile);
          setState(() {});
        } catch (e) {
          setState(() {
            _pickImageError = e;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var event = context.read<Event>();

    var imgList = <String>[];
    event.pictureList.forEach((element) => imgList.add(element));
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
                width: double.maxFinite,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: [
                    if (imgList.isNotEmpty)
                      for (var pic in imgList)
                        if (pic.contains("/data/user/0"))
                          Image(
                              width: 300,
                              height: 200,
                              fit: BoxFit.cover,
                              image: FileImage(File(pic)))
                        else
                          Image(
                            width: 300,
                            height: 200,
                            fit: BoxFit.cover,
                            image: NetworkImage(pic),
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  child: const Text('Cancel'),
                  onPressed: widget.closeFunction,
                ),
                FilledButton(
                  child: const Text('Save'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
