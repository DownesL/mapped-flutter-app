import 'package:geocoder_buddy/geocoder_buddy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapped/models/labels.dart';
import 'package:permission_handler/permission_handler.dart';

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

Future<LatLng?> getCurrentPosition(
    GeolocatorPlatform geolocatorPlatform) async {
  var hasNoPermission = await Permission.location.isDenied;

  if (hasNoPermission) {
    return null;
  }

  var position = await geolocatorPlatform.getCurrentPosition();
  GBLatLng latLngPos =
      GBLatLng(lat: position.latitude, lng: position.longitude);
  GBData data = await GeocoderBuddy.findDetails(latLngPos);
  return LatLng(double.parse(data.lat), double.parse(data.lon));
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

int getColorHexFromInt(int color) {
  var colorStr = "$color".toUpperCase();
  colorStr = colorStr.replaceAll("#", "");
  int val = 0;
  int len = colorStr.length;
  for (int i = 0; i < len; i++) {
    int hexDigit = colorStr.codeUnitAt(i);
    if (hexDigit >= 48 && hexDigit <= 57) {
      val += (hexDigit - 48) * (1 << (4 * (len - 1 - i)));
    } else if (hexDigit >= 65 && hexDigit <= 70) {
// A..F
      val += (hexDigit - 55) * (1 << (4 * (len - 1 - i)));
    } else {
      throw const FormatException("An error occurred when converting a color");
    }
  }
  return val;
}
bool areSameColors(Labels original, Labels news) {
  return original == news;
}