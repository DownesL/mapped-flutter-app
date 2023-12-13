//https://stackoverflow.com/questions/62325215/map-firebaseuser-to-custom-user-object
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapped/firebase_service.dart';
import 'package:mapped/models/labels.dart';

class MappedUser extends ChangeNotifier {
  String? uid;
  String? displayName;
  String? email;
  Labels? labels;
  List<String>? friends;
  List<String>? pending;
  List<String>? attendingEventsIDs;
  List<String>? organisedEventsIDs;
  String? profilePicUrl;
  LatLng? lastKnownPosition;

  var fS = FirebaseService();

  bool get exists => uid!.isNotEmpty;

  bool get isNotEmpty =>
      uid != null && email != null && displayName != null && labels != null
      /*&&
      pending != null &&
      organisedEventsIDs != null &&
      attendingEventsIDs != null*/
      ;

  MappedUser.def() {
    friends = [];
    pending = [];
    attendingEventsIDs = [];
    organisedEventsIDs = [];
  }
  MappedUser.clear() {
    uid = null;
    displayName = null;
    email = null;
    labels = null;
    friends = null;
    pending = null;
    attendingEventsIDs = null;
    organisedEventsIDs = null;
    profilePicUrl = null;
  }

  MappedUser({
    required this.uid,
    required this.labels,
    required this.friends,
    required this.pending,
    required this.attendingEventsIDs,
    required this.organisedEventsIDs,
  });

  MappedUser.withFirebaseUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.labels,
    required this.friends,
    required this.pending,
    required this.attendingEventsIDs,
    required this.organisedEventsIDs,
    this.profilePicUrl,
  });

  void upDateFirebaseUser(User user) {
    uid = user.uid;
    displayName = user.displayName;
    email = user.email;
    notifyListeners();
  }

  void updateColors(Labels colors) {
    labels = colors;
    notifyListeners();
  }

  Map<String, dynamic> toFirestore() => {
        "labels": labels!.toFirestore(),
        "friends": friends,
        "pending": pending,
        "attending_events": attendingEventsIDs,
        "organised_events": organisedEventsIDs,
        "profile_pic_url": profilePicUrl,
        "name": displayName!.toLowerCase(),
      };

  factory MappedUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
    User? user,
  ) {
    final data = snapshot.data();
    if (data == null) {
      return MappedUser.def();
    }
    if (user == null) {
      return MappedUser.withFirebaseUser(
          uid: snapshot.id,
          email: null,
          displayName: data['name'],
          labels:
              Labels.fromFirestore((data['labels'] as Map<String, dynamic>)),
          friends: List.from(data['friends']),
          pending: List.from(data['pending']),
          attendingEventsIDs: List.from(data['attending_events']),
          organisedEventsIDs: List.from(data['organised_events']),
          profilePicUrl: data['profile_pic_url']);
    }
    return MappedUser.withFirebaseUser(
        uid: user.uid,
        displayName: user.displayName,
        email: user.email,
        labels: Labels.fromFirestore((data['labels'] as Map<String, dynamic>)),
        friends: List.from(data['friends']),
        pending: List.from(data['pending']),
        attendingEventsIDs: List.from(data['attending_events']),
        organisedEventsIDs: List.from(data['organised_events']),
        profilePicUrl: data['profile_pic_url']);
  }

  void updateProfilePic(XFile img) async {
    var x = await fS.uploadImage('users/$uid/${img.name}', File(img.path));

    profilePicUrl = x;
    await fS.updateUserData(this);
    notifyListeners();
  }

  void updateDisplayName(String text) {
    displayName = text;
    notifyListeners();
  }

  void updateEmail(String text) {
    email = text;
    notifyListeners();
  }

  void clearValues() {
    uid = null;
    displayName = null;
    email = null;
    labels = null;
    friends = null;
    pending = null;
    attendingEventsIDs = null;
    organisedEventsIDs = null;
    profilePicUrl = null;
    notifyListeners();
  }

  void setValues(MappedUser mappedUser) {
    uid = mappedUser.uid ?? uid;
    displayName = mappedUser.displayName ?? displayName;
    email = mappedUser.email ?? email;
    labels = mappedUser.labels ?? labels;
    friends = mappedUser.friends ?? friends;
    pending = mappedUser.pending ?? pending;
    attendingEventsIDs = mappedUser.attendingEventsIDs ?? attendingEventsIDs;
    organisedEventsIDs = mappedUser.organisedEventsIDs ?? organisedEventsIDs;
    profilePicUrl = mappedUser.profilePicUrl ?? profilePicUrl;
    notifyListeners();
  }

  setPending(MappedUser mappedUser) async {
    pending!.add(mappedUser.uid!);
    mappedUser.pending!.add(uid!);
    notifyListeners();

    await fS.updateUserData(this);
    await fS.updateUserData(mappedUser);
  }

  removePending(MappedUser mappedUser) async {
    pending!.remove(mappedUser.uid!);
    mappedUser.pending!.remove(uid!);
    notifyListeners();

    await fS.updateUserData(this);
    await fS.updateUserData(mappedUser);
  }

  removeFriend(MappedUser mappedUser) async {
    friends?.remove(mappedUser.uid);
    mappedUser.friends?.remove(uid);
    notifyListeners();
    await fS.updateUserData(this);
    await fS.updateUserData(mappedUser);
  }

  toggleFriendship(MappedUser mappedUser, bool areFriends, bool pending) async {
    if (areFriends) {
      await removeFriend(mappedUser);
    } else {
      if (pending) {
        await removePending(mappedUser);
      } else {
        await setPending(mappedUser);
      }
    }
  }
}

class UserArguments {
  final MappedUser mUser;

  UserArguments({required this.mUser});
}
