import 'package:flutter/material.dart';
import 'package:zifyr/core/utils/icons/app_icons_icons.dart';

enum NavigationEnum {
  home,
  mission,
  live,
  explore,
  chat;

  IconData get icon => switch (this) {
    home => AppIcons.home,
    mission => AppIcons.mission,
    live => AppIcons.stream,
    explore => AppIcons.compas,
    chat => AppIcons.message,
  };

  String get label => switch (this) {
    home => 'Home',
    mission => 'Mission',
    live => 'Live',
    explore => 'Explore',
    chat => "Chat",
  };
}
