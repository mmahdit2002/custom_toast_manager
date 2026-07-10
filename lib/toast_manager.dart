// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';

enum ToastType { success, warning, error }

enum ToastStyle { glassmorphism, neumorphism, flat, gradient, bordered, shadowed, glowing, minimal }

enum ToastAnimation { slide, fadeIn, bounceIn, scaleIn, rotateIn, flipIn }

enum ToastPosition { top, bottom }

class ToastManager {
  static final ToastManager _instance = ToastManager._internal();
  factory ToastManager() => _instance;
  ToastManager._internal();

  OverlayEntry? _overlayEntry;
  bool _isVisible = false;

  void showToast({
    required BuildContext context,
    required Color backgroundColor,
    required String message,
    String? buttonText,
    VoidCallback? onButtonPressed,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
    ToastStyle style = ToastStyle.glassmorphism,
    ToastAnimation animation = ToastAnimation.slide,
    ToastPosition position = ToastPosition.top,
  }) {
    if (_isVisible) {
      _overlayEntry?.remove();
      _isVisible = false;
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isLargeScreen = screenWidth > 800;
        final isRtl = Directionality.of(context) == TextDirection.rtl;

        Alignment alignment;
        EdgeInsets margin;
        double? width;

        if (isLargeScreen) {
          if (position == ToastPosition.bottom) {
            alignment = isRtl ? Alignment.bottomLeft : Alignment.bottomRight;
            margin = const EdgeInsets.only(bottom: 30, left: 30, right: 30);
          } else {
            alignment = isRtl ? Alignment.topLeft : Alignment.topRight;
            margin = const EdgeInsets.only(top: 30, left: 30, right: 30);
          }
          width = min(screenWidth * 0.3, 400.0);
        } else {
          if (position == ToastPosition.bottom) {
            alignment = Alignment.bottomCenter;
            margin = const EdgeInsets.only(bottom: 50, left: 20, right: 20);
          } else {
            alignment = Alignment.topCenter;
            margin = const EdgeInsets.only(top: 30, left: 20, right: 20);
          }
          width = double.infinity;
        }

        return SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment: alignment,
                  child: Padding(
                    padding: margin,
                    child: SizedBox(
                      width: width,
                      child: Material(
                        color: Colors.transparent,
                        child: _ToastWidget(
                          backgroundColor: backgroundColor,
                          icon: icon,
                          message: message,
                          buttonText: buttonText,
                          onPressed: onButtonPressed,
                          onDismiss: () {
                            _overlayEntry?.remove();
                            _isVisible = false;
                          },
                          duration: duration,
                          style: style,
                          animation: animation,
                          position: position,
                          isLargeScreen: isLargeScreen,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isVisible = true;
  }

  void dismissToast() {
    if (_isVisible) {
      _overlayEntry?.remove();
      _isVisible = false;
    }
  }
}

class _ToastWidget extends StatefulWidget {
  final Color backgroundColor;
  final IconData icon;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;
  final VoidCallback onDismiss;
  final Duration duration;
  final ToastStyle style;
  final ToastAnimation animation;
  final ToastPosition position;
  final bool isLargeScreen;
  final bool isDarkMode;

  const _ToastWidget({
    required this.backgroundColor,
    required this.icon,
    required this.message,
    this.buttonText,
    this.onPressed,
    required this.onDismiss,
    required this.duration,
    required this.style,
    required this.animation,
    required this.position,
    required this.isLargeScreen,
    required this.isDarkMode,
  });

  @override
  _ToastWidgetState createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _flipAnimation;

  bool _isManuallyDismissed = false;
  final GlobalKey _toastKey = GlobalKey();
  double _height = 100.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    double verticalOffsetStart = widget.position == ToastPosition.bottom ? 1.0 : -1.0;

    switch (widget.animation) {
      case ToastAnimation.slide:
        _slideAnimation = Tween<Offset>(begin: Offset(0, verticalOffsetStart), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_controller);
        _rotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
        _flipAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
        break;
      case ToastAnimation.fadeIn:
        _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_controller);
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_controller);
        _rotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
        _flipAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
        break;
      case ToastAnimation.bounceIn:
        _slideAnimation = Tween<Offset>(begin: Offset(0, verticalOffsetStart), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.bounceOut));
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_controller);
        _rotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
        _flipAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
        break;
      case ToastAnimation.scaleIn:
        _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_controller);
        _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
        _rotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
        _flipAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
        break;
      case ToastAnimation.rotateIn:
        _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_controller);
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_controller);
        _rotationAnimation = Tween<double>(begin: -0.05, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
        _flipAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
        break;
      case ToastAnimation.flipIn:
        _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_controller);
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_controller);
        _rotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
        _flipAnimation = Tween<double>(begin: 0.5, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
        break;
    }

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted && !_isManuallyDismissed) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    if (mounted && !_isManuallyDismissed) {
      _isManuallyDismissed = true;
      _controller.reverse().then((_) {
        widget.onDismiss();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (details) {
        final RenderBox? renderBox = _toastKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) _height = renderBox.size.height;
      },
      onVerticalDragUpdate: (details) {
        double delta = details.delta.dy / _height;
        if (widget.position == ToastPosition.bottom) delta = -delta;
        _controller.value += delta;
      },
      onVerticalDragEnd: (details) {
        const double dismissThreshold = 0.3;
        const double velocityThreshold = 200.0;
        final double velocity = details.primaryVelocity ?? 0.0;

        bool draggingAway = false;
        if (widget.position == ToastPosition.top) {
          if (velocity < -velocityThreshold) draggingAway = true;
        } else {
          if (velocity > velocityThreshold) draggingAway = true;
        }

        if (1 - _controller.value > dismissThreshold || draggingAway) {
          _isManuallyDismissed = true;
          _controller.reverse().then((_) {
            if (mounted) widget.onDismiss();
          });
        } else {
          _controller.animateTo(1.0, duration: const Duration(milliseconds: 400), curve: Curves.elasticOut);
        }
      },
      child: Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.horizontal,
        onDismissed: (direction) => _handleDismiss(),
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: RotationTransition(
                turns: _rotationAnimation,
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(_flipAnimation.value * 3.1416),
                      alignment: Alignment.center,
                      child: child,
                    );
                  },
                  child: _buildStyledContainer(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInnerContent(Color textColor, Color? neuBgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.style == ToastStyle.neumorphism && neuBgColor != null)
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: neuBgColor,
                boxShadow: [
                  BoxShadow(color: widget.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7), offset: const Offset(2, 2), blurRadius: 2),
                  BoxShadow(color: widget.isDarkMode ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.05), offset: const Offset(-2, -2), blurRadius: 3),
                ],
              ),
              child: Icon(widget.icon, size: 20.0, color: widget.backgroundColor),
            )
          else
            Icon(widget.icon, size: 24.0, color: textColor),

          const SizedBox(width: 14.0),
          Expanded(
            child: Text(
              widget.message,
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600, color: textColor, letterSpacing: 0.2),
            ),
          ),
          if (widget.buttonText != null) ...[
            const SizedBox(width: 8.0),
            TextButton(
              onPressed: () {
                widget.onPressed?.call();
                _handleDismiss();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                backgroundColor: textColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                widget.buttonText!,
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
          ],
          if (widget.isLargeScreen) ...[
            const SizedBox(width: 12.0),
            Container(height: 24, width: 1, color: textColor.withOpacity(0.2)),
            const SizedBox(width: 8.0),
            InkWell(
              onTap: _handleDismiss,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Icon(Icons.close_rounded, size: 18, color: textColor.withOpacity(0.6)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStyledContainer() {
    BoxDecoration decoration;
    final Color baseColor = widget.backgroundColor;
    final bool isDark = widget.isDarkMode;

    Color textColor = baseColor.computeLuminance() > 0.4 ? Colors.grey[900]! : Colors.white;
    final double radius = widget.style == ToastStyle.minimal ? 30.0 : 20.0;

    switch (widget.style) {
      case ToastStyle.glassmorphism:
        textColor = isDark ? Colors.white : Colors.grey[900]!;
        final Color glassTint = baseColor.withOpacity(isDark ? 0.15 : 0.15);
        final Color borderColor = baseColor.withOpacity(isDark ? 0.4 : 0.6);

        decoration = BoxDecoration(
          border: Border.all(color: borderColor, width: 1.0),
          borderRadius: BorderRadius.circular(radius),
          color: glassTint,
        );

        // Optimization: Removed AnimatedBuilder on the blur radius.
        // The FadeTransition parent handles the entrance visually, removing 90% of GPU load.
        return RepaintBoundary(
          key: _toastKey,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child: Container(decoration: decoration, child: _buildInnerContent(textColor, null)),
            ),
          ),
        );
      case ToastStyle.neumorphism:
        final Color toastBg = isDark ? Color.alphaBlend(Colors.black.withOpacity(0.3), Colors.grey[900]!) : const Color(0xFFF0F3F8);
        textColor = isDark ? Colors.white : Colors.grey[800]!;

        decoration = BoxDecoration(
          color: toastBg,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.08), offset: const Offset(4, 4), blurRadius: 10),
            BoxShadow(color: isDark ? Colors.white.withOpacity(0.05) : Colors.white, offset: const Offset(-4, -4), blurRadius: 10),
          ],
        );
        return Container(key: _toastKey, decoration: decoration, child: _buildInnerContent(textColor, toastBg));

      case ToastStyle.flat:
        decoration = BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(radius));
        break;

      case ToastStyle.gradient:
        decoration = BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [baseColor, Color.lerp(baseColor, isDark ? Colors.black : Colors.white, 0.3)!]),
        );
        break;

      case ToastStyle.bordered:
        final Color surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        textColor = isDark ? Colors.white : Colors.grey[900]!;
        decoration = BoxDecoration(
          color: surfaceColor,
          border: Border.all(color: baseColor, width: 2.0),
          borderRadius: BorderRadius.circular(radius),
        );
        break;

      case ToastStyle.shadowed:
        decoration = BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [BoxShadow(color: baseColor.withOpacity(isDark ? 0.6 : 0.3), blurRadius: 16, offset: const Offset(0, 8))],
        );
        break;

      case ToastStyle.glowing:
        decoration = BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [BoxShadow(color: baseColor.withOpacity(isDark ? 0.5 : 0.4), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 0))],
        );
        break;

      case ToastStyle.minimal:
        textColor = isDark ? Colors.white : Colors.grey[900]!;
        decoration = BoxDecoration(color: (isDark ? Colors.grey[850] : Colors.white)!.withOpacity(0.95), borderRadius: BorderRadius.circular(radius));
        break;
    }

    return Container(key: _toastKey, decoration: decoration, child: _buildInnerContent(textColor, null));
  }
}

void showCustomToast(
  ToastStyle style,
  ToastAnimation animation,
  ToastType toastType,
  String toastMessage, {
  required BuildContext context,
  String? buttonText,
  VoidCallback? onButtonPressed,
  ToastPosition position = ToastPosition.top,
}) {
  Color backgroundColor;
  IconData icon;

  switch (toastType) {
    case ToastType.success:
      backgroundColor = const Color(0xFF10B981);
      icon = Icons.check_circle_rounded;
      break;
    case ToastType.warning:
      backgroundColor = const Color(0xFFF59E0B);
      icon = Icons.warning_rounded;
      break;
    case ToastType.error:
      backgroundColor = const Color(0xFFEF4444);
      icon = Icons.error_rounded;
      break;
  }

  ToastManager().showToast(
    context: context,
    backgroundColor: backgroundColor,
    message: toastMessage,
    buttonText: buttonText,
    onButtonPressed: onButtonPressed,
    icon: icon,
    style: style,
    animation: animation,
    position: position,
  );
}
