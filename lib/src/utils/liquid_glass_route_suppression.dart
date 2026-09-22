import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mixin that auto-hides a native glass platform view when a popup or page
/// is pushed on top of the widget's route.
///
/// Uses [ModalRoute.of]`.isCurrent` — an `InheritedWidget` that Flutter
/// updates automatically when routes are pushed/popped. No observer or
/// manual setup required.
///
/// Apply to any `State` that hosts a `UiKitView` glass platform view:
///
/// ```dart
/// class _MyGlassState extends State<MyGlass>
///     with LiquidGlassRouteSuppression {
///   MethodChannel? _nativeChannel;
///
///   @override
///   MethodChannel? get suppressionChannel => _nativeChannel;
///
///   void _onPlatformViewCreated(int viewId) {
///     _nativeChannel = MethodChannel('...');
///     syncGlassRouteVisibility(); // check initial state
///   }
/// }
/// ```
mixin LiquidGlassRouteSuppression<T extends StatefulWidget> on State<T> {
  /// The per-view method channel used to send `setSuppressed` to native.
  MethodChannel? get suppressionChannel;

  bool _glassRouteCurrent = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    syncGlassRouteVisibility();
  }

  /// Checks [ModalRoute.of]`.offstage` and tells the native view to
  /// hide or show accordingly. Only opaque route pushes (full page navigation)
  /// mark lower routes as offstage, keeping toolbar and action controls
  /// visible during non-opaque overlays like bottom sheets.
  void syncGlassRouteVisibility() {
    final ch = suppressionChannel;
    if (ch == null) return;

    final route = ModalRoute.of(context);
    final isSuppressed = route?.offstage ?? false;
    if (isSuppressed == _glassRouteCurrent) {
      _glassRouteCurrent = !isSuppressed;
      ch.invokeMethod('setSuppressed', {'suppressed': isSuppressed});
    }
  }
}
