import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUtil {
  Future<void> displayPickImageDialog(
      BuildContext context, OnPickImageCallback onPick) async {
    return onPick(null, null, null);
  }

  List<XFile>? setImageFileListFromFile(XFile? value) {
    return value == null ? null : <XFile>[value];
  }

  Widget? handlePreview(bool isVideo, List<XFile>? mediaFileList,
      String? retrieveDataError, String? pickImageError) {
    if (isVideo) {
      return const Dialog(
        child: AlertDialog(
          title: Text("FILE FORMAT NOT ALLOWED"),
        ),
      );
    } else {
      return previewImages(mediaFileList, retrieveDataError, pickImageError);
    }
  }

  Text? getRetrieveErrorWidget(String? retrieveDataError) {
    if (retrieveDataError != null) {
      final Text result = Text(retrieveDataError);
      retrieveDataError = null;
      return result;
    }
    return null;
  }

  Widget? previewImages(List<XFile>? mediaFileList, String? retrieveDataError,
      String? pickImageError) {
    final Text? retrieveError = getRetrieveErrorWidget(retrieveDataError);
    if (retrieveError != null) {
      return retrieveError;
    }
    if (mediaFileList != null) {
      return Semantics(
          label: 'image_picker_example_picked_images',
          child: ClipOval(
            clipBehavior: Clip.hardEdge,
            child: Image(
              image: FileImage(File(mediaFileList.last.path)),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ));
    } else if (pickImageError != null) {
      return Text(
        'Pick image error: $pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return null;
    }
  }
}

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality);
