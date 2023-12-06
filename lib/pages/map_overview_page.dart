import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:geocoder_buddy/geocoder_buddy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapped/models/event.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:mapped/models/search_options.dart';
import 'package:mapped/widgets/macros/event_marker_layer.dart';
import 'package:mapped/widgets/micros/event_tile.dart';
import 'package:mapped/widgets/micros/location_control_button.dart';
import 'package:mapped/widgets/micros/rotation_control_button.dart';
import 'package:mapped/widgets/micros/user_tile.dart';
import 'package:provider/provider.dart';

import '../utils.dart';

class MapOverviewPage extends StatefulWidget {
  const MapOverviewPage({super.key, this.event});

  final Event? event;

  @override
  State<MapOverviewPage> createState() => _MapOverviewPageState();
}

final List<Widget> _searchTypes =
    SearchType.values.map((e) => Text(e.name)).toList();

class _MapOverviewPageState extends State<MapOverviewPage>
    with TickerProviderStateMixin {
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  GBData? data;
  late LatLng position;
  late final animatedMapController = AnimatedMapController(vsync: this);

  final ValueNotifier<double> _rotation = ValueNotifier(0.0);
  late final ValueNotifier<LatLng> _location;

  final List<bool> _selectedSearchTypes =
      List<bool>.generate(_searchTypes.length, (index) => false);

  updateCameraState(MapEvent mapEvent) {
    _rotation.value = mapEvent.camera.rotation * pi / 180;
    _location.value = mapEvent.camera.center;
  }

  MappedUser? mUser;

  @override
  void initState() {
    mUser = context.read<MappedUser>();
    _location = ValueNotifier(
        mUser!.lastKnownPosition ?? const LatLng(48.067539, 12.862530));
    position = _location.value;
    setPosition();
    super.initState();
  }

  @override
  void dispose() {
    _location.dispose();
    _rotation.dispose();
    super.dispose();
  }

  Future<void> setPosition() async {
    var position = await getCurrentPosition(_geolocatorPlatform);
    if (position != null) {
      this.position = position;
      if (widget.event == null) {
        animatedMapController.mapController.move(position, 16);
      }
      mUser?.lastKnownPosition = position;
    }
  }

  @override
  Widget build(BuildContext context) {
    SearchOptions searchOptions = context.watch<SearchOptions>();
    final ThemeData theme = Theme.of(context);
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        FlutterMap(
          mapController: animatedMapController.mapController,
          options: MapOptions(
              initialCenter: widget.event?.latLng ?? position,
              initialZoom: widget.event != null ? 19 : 16,
              onMapEvent: (mapEv) => updateCameraState(mapEv)),
          children: [
            TileLayer(
              urlTemplate:
                  'https://api.mapbox.com/styles/v1/ldownes/clomq10mb00ax01o4fb526cvf/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibGRvd25lcyIsImEiOiJjbG9tcG1rNGkwMHBnMmtwcW9tendhcjEzIn0.JiuiI569O8sATOuh5yt5Yw',
              userAgentPackageName: 'com.example.app',
            ),
            EventMarkerLayer(
              extraEvents: widget.event != null ? [widget.event!] : null,
            ),
            const RichAttributionWidget(
              showFlutterMapAttribution: false,
              alignment: AttributionAlignment.bottomLeft,
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: EdgeInsets.only(
                top: MediaQuery.sizeOf(context).height / 5, left: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<double>(
                  valueListenable: _rotation,
                  builder: (context, rotation, Widget? child) =>
                      Transform.rotate(
                    angle: rotation,
                    child: RotationControlButton(
                      onPressed: () =>
                          animatedMapController.animatedRotateReset(),
                      isDisabled: rotation == 0,
                    ),
                  ),
                ),
                ValueListenableBuilder<LatLng>(
                  valueListenable: _location,
                  builder: (context, location, Widget? child) =>
                      LocationControlButton(
                    onPressed: () =>
                        animatedMapController.centerOnPoint(position, zoom: 16),
                    isDisabled: location == position,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (searchOptions.term != null)
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 100),
              height: MediaQuery.sizeOf(context).height,
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 5),
                  ToggleButtons(
                    direction: Axis.horizontal,
                    onPressed: (int index) {
                      setState(() {
                        if (_selectedSearchTypes[index]) {
                          _selectedSearchTypes[index] =
                              !_selectedSearchTypes[index];
                        } else {
                          for (int i = 0;
                              i < _selectedSearchTypes.length;
                              i++) {
                            _selectedSearchTypes[i] = i == index;
                          }
                        }
                        var i = _selectedSearchTypes.indexOf(true);
                        searchOptions.setSearchType(
                            i >= 0 ? SearchType.values[i] : null);
                      });
                    },
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    selectedBorderColor: theme.primaryColor,
                    fillColor: theme.colorScheme.primaryContainer,
                    color: theme.colorScheme.primary,
                    constraints: const BoxConstraints(
                      minHeight: 40.0,
                      minWidth: 80.0,
                    ),
                    isSelected: _selectedSearchTypes,
                    children: _searchTypes,
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  if ((searchOptions.items != null) &&
                      (searchOptions.items!.isNotEmpty))
                    Flexible(
                      fit: FlexFit.loose,
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          itemCount: searchOptions.items!.length,
                          itemBuilder: (context, index) {
                            if (searchOptions.items![index].searchType ==
                                SearchType.event) {
                              Event e = searchOptions.items![index].event!;
                              return EventTile(
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/home/event',
                                  arguments: EventArguments(event: e),
                                ),
                                accentColor: Color(mUser!.labels!
                                    .eventLabelColor(e.eventType)),
                                event: e,
                              );
                            }
                            MappedUser mu = searchOptions.items![index].user!;
                            return UserTile(
                              mappedUser: mu,
                            );
                          }),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('No Search Results'),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
