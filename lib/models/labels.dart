import 'package:flutter/material.dart';
import 'package:mapped/models/event.dart';

import '../utils.dart';

class Labels extends ChangeNotifier {
  late int public;
  late int private;
  late int friend;

  Labels.fromMap(Map<String, int> map) {
    public = map['public'] ?? 0xff8c2cb9;
    private = map['private'] ?? 0xff4dca49;
    friend = map['friend'] ?? 0xff0b6dce;
  }

  Labels({required this.public, required this.private, required this.friend});

  factory Labels.copy(Labels labels) => Labels(
        public: labels.public,
        private: labels.private,
        friend: labels.friend,
      );

  factory Labels.fromFirestore(Map<String, dynamic> data) {
    return Labels.fromMap(
      data.map(
        (key, value) => MapEntry(
          key,
          int.parse(value),
        ),
      ),
    );
  }

  Map<String, dynamic> toFirestore() => {
        "public": getColorHexFromInt(public).toRadixString(16),
        "private": getColorHexFromInt(private).toRadixString(16),
        "friend": getColorHexFromInt(friend).toRadixString(16),
      };

  void setFriendColor(Color color) {
    friend = color.value;
    notifyListeners();
  }
  void setPublicColor(Color color) {
    public = color.value;
    notifyListeners();
  }
  void setPrivateColor(Color color) {
    private = color.value;
    notifyListeners();
  }

  int eventLabelColor(EventType eventType) {
    switch (eventType) {
      case EventType.public:
        return public;
      case EventType.private:
        return private;
      case EventType.friend:
        return friend;
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is! Labels) {
      return false;
    }
    return public == other.public &&
        private == other.private &&
        friend == other.friend;
  }


}
