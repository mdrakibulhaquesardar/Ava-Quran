import '/bootstrap/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:nylo_framework/nylo_framework.dart';

/// ToastNotification provides a registry of toast notification styles.
/// Use [ToastNotification.styles] to get the default styles map.
class ToastNotification {
  /// Create a fully custom toast notification with a builder function.
  ///
  /// Use this when you want complete control over the toast's widget tree.
  /// Pair with a data-aware factory to access title, description, and custom data.
  ///
  /// Example:
  /// ```dart
  /// 'custom': (data) => ToastNotification.builder((context) {
  ///   return Container(
  ///     padding: EdgeInsets.all(16),
  ///     child: Text(data['description'] ?? ''),
  ///   );
  /// }, animation: ToastAnimation.springFromTop()),
  /// ```
  static ToastStyleFactory builder(
    Widget Function(BuildContext context) builder, {
    ToastNotificationPosition? position,
    Duration? duration,
    ToastAnimation? animation,
    ToastAnimation? reverseAnimation,
    bool? dismissOtherToast,
    TextDirection? textDirection,
    Alignment? alignment,
    Axis? axis,
    Offset? startOffset,
    Offset? endOffset,
    Offset? reverseStartOffset,
    Offset? reverseEndOffset,
    bool? isHideKeyboard,
    bool? isIgnoring,
    CustomAnimationBuilder? animationBuilder,
    CustomAnimationBuilder? reverseAnimBuilder,
    ToastOnInitStateCallback? onInitState,
  }) {
    return (ToastMeta meta, void Function(ToastMeta) updateMeta) {
      final updatedMeta = meta.copyWith(
        position: position,
        duration: duration,
        animation: meta.animation ?? animation,
        reverseAnimation: meta.reverseAnimation ?? reverseAnimation,
        dismissOtherToast: meta.dismissOtherToast ?? dismissOtherToast,
        textDirection: meta.textDirection ?? textDirection,
        alignment: meta.alignment ?? alignment,
        axis: meta.axis ?? axis,
        startOffset: meta.startOffset ?? startOffset,
        endOffset: meta.endOffset ?? endOffset,
        reverseStartOffset: meta.reverseStartOffset ?? reverseStartOffset,
        reverseEndOffset: meta.reverseEndOffset ?? reverseEndOffset,
        isHideKeyboard: meta.isHideKeyboard ?? isHideKeyboard,
        isIgnoring: meta.isIgnoring ?? isIgnoring,
        animationBuilder: meta.animationBuilder ?? animationBuilder,
        reverseAnimBuilder: meta.reverseAnimBuilder ?? reverseAnimBuilder,
        onInitState: meta.onInitState ?? onInitState,
      );
      updateMeta(updatedMeta);
      return Builder(builder: (context) => builder(context));
    };
  }

  /// Helper to create a toast style with defaults.
  ///
  /// Parameters:
  /// - [icon] - The icon widget to display
  /// - [color] - Background color for the icon section
  /// - [defaultTitle] - Title shown when no title is provided
  /// - [position] - Where the toast appears (top, bottom, center)
  /// - [duration] - How long the toast is displayed
  /// - [animation] - Animation style for the toast (e.g., ToastAnimation.fade())
  static ToastStyleFactory style({
    required Widget icon,
    required Color color,
    String? defaultTitle,
    ToastNotificationPosition? position,
    Duration? duration,
    ToastAnimation? animation,
    ToastAnimation? reverseAnimation,
    bool? dismissOtherToast,
    TextDirection? textDirection,
    Alignment? alignment,
    Axis? axis,
    Offset? startOffset,
    Offset? endOffset,
    Offset? reverseStartOffset,
    Offset? reverseEndOffset,
    bool? isHideKeyboard,
    bool? isIgnoring,
    CustomAnimationBuilder? animationBuilder,
    CustomAnimationBuilder? reverseAnimBuilder,
    ToastOnInitStateCallback? onInitState,
    Widget Function(ToastMeta toastMeta)? builder,
  }) {
    return (ToastMeta meta, void Function(ToastMeta) updateMeta) {
      final updatedMeta = meta.copyWith(
        icon: meta.icon ?? icon,
        color: meta.color ?? color,
        title: meta.title.isEmpty ? defaultTitle : null,
        position: position,
        duration: duration,
        animation: meta.animation ?? animation,
        reverseAnimation: meta.reverseAnimation ?? reverseAnimation,
        dismissOtherToast: meta.dismissOtherToast ?? dismissOtherToast,
        textDirection: meta.textDirection ?? textDirection,
        alignment: meta.alignment ?? alignment,
        axis: meta.axis ?? axis,
        startOffset: meta.startOffset ?? startOffset,
        endOffset: meta.endOffset ?? endOffset,
        reverseStartOffset: meta.reverseStartOffset ?? reverseStartOffset,
        reverseEndOffset: meta.reverseEndOffset ?? reverseEndOffset,
        isHideKeyboard: meta.isHideKeyboard ?? isHideKeyboard,
        isIgnoring: meta.isIgnoring ?? isIgnoring,
        animationBuilder: meta.animationBuilder ?? animationBuilder,
        reverseAnimBuilder: meta.reverseAnimBuilder ?? reverseAnimBuilder,
        onInitState: meta.onInitState ?? onInitState,
      );
      updateMeta(updatedMeta);
      if (builder != null) {
        return builder(updatedMeta);
      }
      return _ToastNotificationBase(updatedMeta);
    };
  }
}

/// Base toast notification widget that renders the common layout.
class _ToastNotificationBase extends StatelessWidget {
  const _ToastNotificationBase(this._toastMeta);

  final ToastMeta _toastMeta;

  @override
  Widget build(BuildContext context) {
    final Color accentColor = _toastMeta.color ?? const Color(0xFF267B92);
    final isDark = context.isThemeDark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C252A) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 60 : 15),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              )
            ],
            border: Border.all(
              color: isDark ? Colors.white.withAlpha(15) : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: _toastMeta.action != null ? () => _toastMeta.action!() : null,
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // Left aesthetic accent bar
                    Container(
                      width: 6,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                    ),
                    
                    // Icon section with soft aura
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 4),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: accentColor.withAlpha(isDark ? 40 : 25),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: IconTheme(
                            data: IconThemeData(
                              color: accentColor,
                              size: 20,
                            ),
                            child: _toastMeta.icon ?? const Icon(Icons.info_rounded),
                          ),
                        ),
                      ),
                    ),

                    // Content section
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _toastMeta.title.tr(),
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                            if (_toastMeta.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                _toastMeta.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black54,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Dismiss button
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: _toastMeta.dismiss != null ? () => _toastMeta.dismiss!() : null,
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: isDark ? Colors.white38 : Colors.black26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
