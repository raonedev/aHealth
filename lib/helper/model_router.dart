// lib/common/modal_sheet_page.dart
import 'package:flutter/material.dart';

class ModalSheetPage<T> extends Page<T> {
  final WidgetBuilder builder;
  final Color barrierColor;
  final bool isScrollControlled;

  const ModalSheetPage({
    required this.builder,
    this.barrierColor = Colors.black54,
    this.isScrollControlled = true,
    super.key,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return ModalBottomSheetRoute<T>(
      settings: this,
      builder: builder,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
    );
  }
}