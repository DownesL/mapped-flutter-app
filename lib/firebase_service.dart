import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mapped/models/event.dart';
import 'package:mapped/models/labels.dart';
import 'package:mapped/models/search_options.dart';

import 'models/mapped_user.dart';

class FirebaseService {
  Future<MappedUser> getUser() async {
    var user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      var userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userData.exists) {
        return MappedUser.fromFirestore(userData, null, user);
      }
    }
    return MappedUser.def();
  }

  Future<MappedUser?> getUserByID(String id) async {
    var userData =
        await FirebaseFirestore.instance.collection('users').doc(id).get();
    if (userData.exists) {
      return MappedUser.fromFirestore(userData, null, null);
    }
    return null;
  }

  Future<Event?> getEventByID(String id) async {
    var eventData =
        await FirebaseFirestore.instance.collection('events').doc(id).get();
    if (eventData.exists) {
      return Event.fromFirestore(eventData, null);
    }
    return null;
  }

  Future<void> updateUserData(MappedUser mUser) async {
    if (mUser.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(mUser.uid)
          .set(mUser.toFirestore());
    }
  }

  Future<void> updateEvent(Event event) async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(event.eid)
          .set(event.toFirestore());
    }
  }

  Future<List<MappedUser>> getUserFriends(
    List<String> uids,
  ) async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: uids)
          .get()
          .then((querySnapshot) {
        return querySnapshot.docs
            .map((e) => MappedUser.fromFirestore(e, null, null))
            .toList();
      });
    }
    return [];
  }

  Future<void> updateEmailAddress(String email) async {
    FirebaseAuth.instance.currentUser?.updateEmail(email);
  }

  Future<void> updateDisplayName(String name) async {
    FirebaseAuth.instance.currentUser?.updateDisplayName(name);
  }

  Future<String?> firestoreSignUp(
    MappedUser mUser,
    String email,
    String password,
    String displayName,
  ) async {
    try {
      UserCredential result =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        await user.updateDisplayName(displayName);
        mUser.upDateFirebaseUser(user);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> setFirestoreColorData(
    MappedUser mUser,
    Labels colors,
  ) async {
    try {
      var user = FirebaseAuth.instance.currentUser!;
      mUser.upDateFirebaseUser(user);
      mUser.updateColors(colors);
      updateUserData(mUser);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> uploadImage(String targetPath, File file) async {
    final imageRef = FirebaseStorage.instance.ref().child(targetPath);
    try {
      await imageRef.putFile(file);
      return await imageRef.getDownloadURL();
    } on FirebaseException catch (e) {
      return e.message;
    }
  }

  Future<List<Event>?> getUserEvents(
    MappedUser mUser, {
    EventType? eventType,
    int? limit,
    DateTime? after,
    DateTime? before,
  }) async {
    var db = FirebaseFirestore.instance
        .collection('events')
        .where("attendees", arrayContains: mUser.uid);
    if (eventType != null) {
      db = db.where("event_type", isEqualTo: eventType.number);
    }
    if (limit != null) {
      db = db.limit(limit);
    }
    if (after != null) {
      db = db.where("end_date", isGreaterThanOrEqualTo: after);
    }
    if (before != null) {
      db = db.where("end_date", isLessThanOrEqualTo: before);
    }
    return await db.get().then((querySnapshot) {
      return querySnapshot.docs.map((e) {
        return Event.fromFirestore(e, null);
      }).toList();
    });
  }

  Future<List<SearchItem>> getSearchItems(
    String term,
    SearchType? searchType,
  ) async {
    term = term.toLowerCase();
    if (searchType == null) {
      List<SearchItem> totalList = (await getEventSearchItems(term));
      totalList.addAll(await getUserSearchItems(term));
      return totalList;
    }
    if (searchType == SearchType.event) {
      return getEventSearchItems(term);
    }
    if (searchType == SearchType.people) {
      return getUserSearchItems(term);
    }
    return <SearchItem>[];
  }

  Future<List<SearchItem>> getEventSearchItems(
    String term,
  ) async {
    var db = FirebaseFirestore.instance;
    List<Event> eventList = [];
    var user = await getUser();

    await db
        .collection('events')
        .orderBy("search_name")
        .startAt([term])
        .endAt(['$term\uf8ff'])
        .where("event_type", isEqualTo: 0)
        .get()
        .then((querySnapshot) {
          eventList = querySnapshot.docs
              .map((e) => Event.fromFirestore(e, null))
              .toList();
        });
    await db
        .collection('events')
        .where(
          "organisers",
          arrayContains: user.uid!,
        )
        .orderBy("search_name")
        .startAt([term])
        .endAt(['$term\uf8ff'])
        .get()
        .then((querySnapshot) {
          eventList.addAll(querySnapshot.docs
              .map((e) => Event.fromFirestore(e, null))
              .where((event) => event.eventType != EventType.public)
              .toList());
        });

    return List<SearchItem>.generate(
      eventList.length,
      (index) => SearchItem(
        searchType: SearchType.event,
        event: eventList[index],
      ),
    );
  }

  Future<List<SearchItem>> getUserSearchItems(
    String term,
  ) async {
    var db = FirebaseFirestore.instance;
    var cUuid = FirebaseAuth.instance.currentUser!.uid;
    List<MappedUser> mappedUserList = [];

    await db
        .collection('users')
        .orderBy("name")
        .startAt([term])
        .endAt(['$term\uf8ff'])
        .get()
        .then((querySnapshot) {
          mappedUserList = querySnapshot.docs
              .where((e) => e.id != cUuid)
              .map((e) => MappedUser.fromFirestore(e, null, null))
              .toList();
        });

    return List<SearchItem>.generate(
      mappedUserList.length,
      (index) => SearchItem(
        searchType: SearchType.people,
        user: mappedUserList[index],
      ),
    );
  }

  Future<List<String?>> getEventAttendeePics(Event event) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: event.attendeeIDs)
        .limit(3)
        .get()
        .then((querySnapshot) => querySnapshot.docs
            .map((e) => MappedUser.fromFirestore(e, null, null).profilePicUrl)
            .toList());
  }

  Stream<List<MappedUser>> getFriends(MappedUser mappedUser) {
    return FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: mappedUser.friends ?? [])
        .snapshots()
        .map(
          (e) => e.docs
              .map((doc) => MappedUser.fromFirestore(doc, null, null))
              .toList(),
        );
  }

  Stream<List<MappedUser>> getPending(MappedUser mappedUser) {
    if (mappedUser.pending == null || mappedUser.pending!.isEmpty) {
      return Stream.value(<MappedUser>[]);
    }
    return FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: mappedUser.pending ?? [])
        .snapshots()
        .map(
          (e) => e.docs
              .map((doc) => MappedUser.fromFirestore(doc, null, null))
              .toList(),
        );
  }

  Future<List<Event>?> getPublicEvents( {
    int? limit,
  }) async {
    var db = FirebaseFirestore.instance
        .collection('events')
        .where("event_type", isEqualTo: EventType.public.number)
        .where("end_date", isGreaterThanOrEqualTo: DateTime.now());
    if (limit != null) {
      db = db.limit(limit);
    }
    return await db.get().then((querySnapshot) {
      return querySnapshot.docs.map((e) {
        return Event.fromFirestore(e, null);
      }).toList();
    });
  }

  Future<void> addEvent(Event event) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    if (event.eid.isNotEmpty) {
      await db.collection("events").doc(event.eid).set(event.toFirestore());
    } else {
      await db.collection("events").add(event.toFirestore());
    }
  }
}
