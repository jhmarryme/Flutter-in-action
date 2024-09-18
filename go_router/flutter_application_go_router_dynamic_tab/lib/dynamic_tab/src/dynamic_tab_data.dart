import 'package:flutter/material.dart';

class TabData {
  final int id;
  final String routeName;
  final Widget title;
  final Widget content;

  TabData({
    required this.id,
    required this.routeName,
    required this.title,
    required this.content,
  });

}

/// Defines where the Tab indicator animation moves to when new Tab is added.
///
///
enum MoveToTab {
  /// The [idol] indicator will remain on current Tab when new Tab is added.
  // idol,
  /// The [last] indicator will move to the Last Tab when new Tab is added.
  last,
  next,
  previous,
  first,
}
