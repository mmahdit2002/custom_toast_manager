// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:ui'; // For ImageFilter

enum ToastType { success, warning, error }

enum ToastStyle { glassmorphism, neumorphism, flat, gradient, bordered, shadowed, glowing, minimal }

enum ToastAnimation { slideFromTop, fadeIn, bounceIn, scaleIn, rotateIn, flipIn }

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
    ToastAnimation animation = ToastAnimation.slideFromTop,
  }) {
    if (_isVisible) {
      _overlayEntry?.remove();
      _isVisible = false;
    }

    _overlayEntry = OverlayEntry(
      builder: (_) => SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 30,
              left: 20,
              right: 20,
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
              ),
            ),
          ],
        ),
      ),
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

    switch (widget.animation) {
      case ToastAnimation.slideFromTop:
        _slideAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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
        _slideAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.bounceOut));
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_controller);
        _rotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
        _flipAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
        break;
      case ToastAnimation.scaleIn:
        _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_controller);
        _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
        _rotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
        _flipAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
        break;
      case ToastAnimation.rotateIn:
        _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_controller);
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_controller);
        _rotationAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
        _flipAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
        break;
      case ToastAnimation.flipIn:
        _slideAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_controller);
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_controller);
        _rotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
        _flipAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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
        if (renderBox != null) {
          _height = renderBox.size.height;
        }
      },
      onVerticalDragUpdate: (details) {
        final double delta = details.delta.dy / _height;
        _controller.value += delta;
      },
      onVerticalDragEnd: (details) {
        const double dismissThreshold = 0.3;
        const double velocityThreshold = 200.0;
        final double velocity = details.primaryVelocity ?? 0.0;
        bool shouldDismiss = false;

        if (_controller.value < 1) {
          final double fraction = 1 - _controller.value;
          final double vel = -velocity;
          if (fraction > dismissThreshold || vel > velocityThreshold) {
            shouldDismiss = true;
          }
        } else {
          final double fraction = _controller.value - 1;
          final double vel = velocity;
          if (fraction > dismissThreshold || vel > velocityThreshold) {
            shouldDismiss = true;
          }
        }

        if (shouldDismiss) {
          _isManuallyDismissed = true;
          if (_controller.value > 1) {
            _controller.animateTo(_controller.value + 0.2, duration: const Duration(milliseconds: 150), curve: Curves.easeOut).then((_) {
              if (mounted) {
                _controller.animateTo(0.0, duration: const Duration(milliseconds: 400), curve: Curves.easeInBack).then((_) {
                  if (mounted) {
                    widget.onDismiss();
                  }
                });
              }
            });
          } else {
            _controller.animateTo(0.0, duration: const Duration(milliseconds: 200), curve: Curves.easeIn).then((_) {
              if (mounted) {
                widget.onDismiss();
              }
            });
          }
        } else {
          _controller.animateTo(1.0, duration: const Duration(milliseconds: 400), curve: Curves.elasticOut);
        }
      },
      child: Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.horizontal,
        onDismissed: (direction) {
          _handleDismiss();
        },
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
                        ..rotateY(_flipAnimation.value * 3.1416),
                      alignment: Alignment.center,
                      child: child,
                    );
                  },
                  child: Material(color: Colors.transparent, child: _buildStyledContainer()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Replace the previous _buildStyledContainer and _buildContent with these:

  Widget _buildInnerContent(Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0),
      child: Row(
        children: [
          Icon(widget.icon, size: 20.0, color: textColor),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              widget.message,
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600, color: textColor),
            ),
          ),
          if (widget.buttonText != null)
            TextButton(
              onPressed: () {
                widget.onPressed?.call();
                _handleDismiss();
              },
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text(
                widget.buttonText!,
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStyledContainer() {
    BoxDecoration decoration;
    final Color baseColor = widget.backgroundColor;
    final Color textColor = baseColor.computeLuminance() > 0.1 ? Colors.grey[700]! : Colors.white;
    final double radius = widget.style == ToastStyle.minimal ? 30.0 : 16.0;

    switch (widget.style) {
      case ToastStyle.glassmorphism:
        decoration = BoxDecoration(
          border: Border.all(color: baseColor.withOpacity(0.4), width: 1.5),
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [baseColor.withOpacity(0.3), baseColor.withOpacity(0.1)]),
        );

        // For glassmorphism we clip the blurred area only — we don't clip the outer widget that could show shadows.
        return Container(
          key: _toastKey,
          // outer container (no clipping) so any outer shadows (if you add them later) remain visible
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child: Container(decoration: decoration, child: _buildInnerContent(textColor)),
            ),
          ),
        );

      case ToastStyle.neumorphism:
        {
          final Color neuColor = Color.lerp(Colors.grey[100]!, baseColor.withOpacity(0.6), 0.4)!;
          final Color lightShadow = Color.lerp(neuColor, Colors.white, 0.7)!;
          final Color darkShadow = Color.lerp(neuColor, Colors.black, 0.2)!;
          decoration = BoxDecoration(
            color: neuColor,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(color: lightShadow, offset: const Offset(-6, -6), blurRadius: 12, spreadRadius: 1),
              BoxShadow(color: darkShadow, offset: const Offset(6, 6), blurRadius: 12, spreadRadius: 1),
            ],
          );
        }
        break;

      case ToastStyle.flat:
        decoration = BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [BoxShadow(color: baseColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        );
        break;

      case ToastStyle.gradient:
        decoration = BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [baseColor, Color.lerp(baseColor, Colors.white, 0.3)!]),
          boxShadow: [BoxShadow(color: baseColor.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))],
        );
        break;

      case ToastStyle.bordered:
        decoration = BoxDecoration(
          color: baseColor.withOpacity(0.15),
          border: Border.all(color: baseColor, width: 2.5),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [BoxShadow(color: baseColor.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))],
        );
        break;

      case ToastStyle.shadowed:
        decoration = BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [BoxShadow(color: baseColor.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 5))],
        );
        break;

      case ToastStyle.glowing:
        decoration = BoxDecoration(
          color: baseColor.withOpacity(0.15),
          border: Border.all(color: baseColor, width: 2.5),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [BoxShadow(color: baseColor.withOpacity(0.5), blurRadius: 20, spreadRadius: 1, offset: const Offset(0, 0))],
        );
        break;

      case ToastStyle.minimal:
        decoration = BoxDecoration(color: baseColor.withOpacity(0.9), borderRadius: BorderRadius.circular(radius));
        break;
    }

    // Default: just render a decorated container (no ClipRRect) — this allows BoxShadow to be visible.
    return Container(key: _toastKey, decoration: decoration, child: _buildInnerContent(textColor));
  }
}

void showCustomToast(ToastStyle style, ToastAnimation animation, ToastType toastType, String toastMessage, {required BuildContext context, String? buttonText, VoidCallback? onButtonPressed}) {
  Color backgroundColor;
  IconData icon;

  switch (toastType) {
    case ToastType.success:
      backgroundColor = Colors.green.shade600;
      icon = Icons.check_circle;
      break;
    case ToastType.warning:
      backgroundColor = Colors.orange.shade700;
      icon = Icons.warning;
      break;
    case ToastType.error:
      backgroundColor = Colors.red.shade600;
      icon = Icons.error;
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
  );
}

void showInfoToast(String text, {required BuildContext context, VoidCallback? onButtonPressed, String? buttonText}) {
  ToastManager().showToast(context: context, backgroundColor: Colors.blue.shade600, message: text, buttonText: buttonText, onButtonPressed: onButtonPressed, icon: Icons.info);
}

void showWarningToast(String text, {required BuildContext context, VoidCallback? onButtonPressed, String? buttonText}) {
  ToastManager().showToast(context: context, backgroundColor: Colors.orange.shade700, message: text, buttonText: buttonText, onButtonPressed: onButtonPressed, icon: Icons.warning);
}

void showErrorToast(String text, {required BuildContext context, VoidCallback? onButtonPressed, String? buttonText}) {
  ToastManager().showToast(context: context, backgroundColor: Colors.red.shade600, message: text, buttonText: buttonText, onButtonPressed: onButtonPressed, icon: Icons.error);
}

void showSuccessToast(String text, {required BuildContext context, VoidCallback? onButtonPressed, String? buttonText}) {
  ToastManager().showToast(context: context, backgroundColor: Colors.green.shade600, message: text, buttonText: buttonText, onButtonPressed: onButtonPressed, icon: Icons.check_circle);
}

void showPrimaryToast(String text, {required BuildContext context, VoidCallback? onButtonPressed, String? buttonText}) {
  ToastManager().showToast(context: context, backgroundColor: Colors.blueAccent.shade700, message: text, buttonText: buttonText, onButtonPressed: onButtonPressed, icon: Icons.info);
}
