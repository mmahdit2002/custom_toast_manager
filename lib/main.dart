// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:toast_manager/toast_manager.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Premium Toasts',
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF3F4F6),
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1), brightness: Brightness.light),
            fontFamily: 'Inter',
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF09090B),
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF818CF8), brightness: Brightness.dark),
            fontFamily: 'Inter',
            useMaterial3: true,
          ),
          themeMode: currentMode,
          debugShowCheckedModeBanner: false,
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ToastStyle _selectedStyle = ToastStyle.glassmorphism;
  ToastAnimation _selectedAnimation = ToastAnimation.slide;
  ToastType _selectedType = ToastType.success;
  ToastPosition _selectedPosition = ToastPosition.top;

  void _triggerToast(BuildContext context) {
    showCustomToast(_selectedStyle, _selectedAnimation, _selectedType, 'Your settings look amazing!', context: context, position: _selectedPosition, buttonText: 'UNDO');
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Extracted to a constant widget to prevent expensive backdrop filter rebuilds on setState
          const _AmbientBackground(),
          SafeArea(bottom: false, child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout()),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 48.0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 6,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildHeader(), const SizedBox(height: 48), _buildControls(isMobile: false)]),
              ),
              const SizedBox(width: 48),
              Expanded(flex: 4, child: _buildPreviewCard(isMobile: false)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildHeader(), const SizedBox(height: 32), _buildControls(isMobile: true), const SizedBox(height: 24), _buildPreviewCard(isMobile: true)],
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TOAST UI',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2.0, color: isDark ? Colors.white54 : Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              'Configurator',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1.0, color: isDark ? Colors.white : const Color(0xFF09090B), height: 1.0),
            ),
          ],
        ),
        _GlassCard(
          padding: const EdgeInsets.all(8),
          child: IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, size: 20),
            color: isDark ? Colors.white : Colors.black87,
            onPressed: () => themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark,
          ),
        ),
      ],
    );
  }

  Widget _buildControls({required bool isMobile}) {
    return Column(
      children: [
        _buildSectionGroup(
          title: 'Aesthetic Style',
          icon: Icons.palette_outlined,
          isMobile: isMobile,
          child: _buildWrapSelector<ToastStyle>(values: ToastStyle.values, selected: _selectedStyle, isMobile: isMobile, onSelected: (v) => setState(() => _selectedStyle = v)),
        ),
        const SizedBox(height: 16),
        _buildSectionGroup(
          title: 'Motion Animation',
          icon: Icons.animation_rounded,
          isMobile: isMobile,
          child: _buildWrapSelector<ToastAnimation>(values: ToastAnimation.values, selected: _selectedAnimation, isMobile: isMobile, onSelected: (v) => setState(() => _selectedAnimation = v)),
        ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildSectionGroup(
                  title: 'Semantic Type',
                  icon: Icons.info_outline_rounded,
                  isMobile: isMobile,
                  child: _buildWrapSelector<ToastType>(values: ToastType.values, selected: _selectedType, isMobile: isMobile, onSelected: (v) => setState(() => _selectedType = v)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSectionGroup(
                  title: 'Screen Dock',
                  icon: Icons.vertical_align_center_rounded,
                  isMobile: isMobile,
                  child: _buildWrapSelector<ToastPosition>(values: ToastPosition.values, selected: _selectedPosition, isMobile: isMobile, onSelected: (v) => setState(() => _selectedPosition = v)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionGroup({required String title, required IconData icon, required Widget child, required bool isMobile}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _GlassCard(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: isDark ? Colors.white70 : Colors.black87),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          child,
        ],
      ),
    );
  }

  Widget _buildWrapSelector<T extends Enum>({required List<T> values, required T selected, required ValueChanged<T> onSelected, required bool isMobile}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Wrap(
      spacing: isMobile ? 6 : 8,
      runSpacing: isMobile ? 6 : 8,
      children: values.map((v) {
        final isSelected = v == selected;
        final bgColor = isSelected ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05));
        final textColor = isSelected ? (isDark ? Colors.black : Colors.white) : (isDark ? Colors.white70 : Colors.black87);
        final borderColor = isSelected ? Colors.transparent : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1));

        return GestureDetector(
          onTap: () => onSelected(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 10 : 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              v.name.capitalize(),
              style: TextStyle(color: textColor, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, fontSize: isMobile ? 12 : 13),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreviewCard({required bool isMobile}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _GlassCard(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_rounded, size: 20, color: isDark ? Colors.white70 : Colors.black87),
              const SizedBox(width: 10),
              Text(
                "Live Preview",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 24 : 40),

          SizedBox(
            width: double.infinity,
            child: _MockToast(style: _selectedStyle, type: _selectedType, isDark: isDark),
          ),

          if (!isMobile) ...[
            const SizedBox(height: 40),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.code_rounded, size: 16, color: isDark ? Colors.white54 : Colors.black54),
                        const SizedBox(width: 8),
                        Text(
                          'Generated Dart Code',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: isDark ? Colors.white54 : Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          "showCustomToast(\n  context: context,\n  style: ToastStyle.${_selectedStyle.name},\n  animation: ToastAnimation.${_selectedAnimation.name},\n  type: ToastType.${_selectedType.name},\n  position: ToastPosition.${_selectedPosition.name},\n  buttonText: 'UNDO',\n);",
                          style: TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.7, color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          SizedBox(height: isMobile ? 24 : 32),

          InkWell(
            onTap: () => _triggerToast(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: const Center(
                child: Text(
                  'TRIGGER TOAST',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Optimization: Extracted Ambient Background ---
// This prevents the heavy screen-wide blur from re-rendering on every single setState click.
class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: isDark ? const Color(0xFF09090B) : const Color(0xFFF3F4F6))),
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? const Color(0xFF4F46E5).withOpacity(0.3) : const Color(0xFF818CF8).withOpacity(0.2)),
            ),
          ),
          Positioned(
            bottom: -200,
            right: -100,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? const Color(0xFF9333EA).withOpacity(0.2) : const Color(0xFFC084FC).withOpacity(0.2)),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockToast extends StatelessWidget {
  final ToastStyle style;
  final ToastType type;
  final bool isDark;
  final String? buttonText;

  const _MockToast({required this.style, required this.type, required this.isDark}) : buttonText = 'UNDO';

  @override
  Widget build(BuildContext context) {
    Color baseColor;
    IconData icon;

    switch (type) {
      case ToastType.success:
        baseColor = const Color(0xFF10B981);
        icon = Icons.check_circle_rounded;
        break;
      case ToastType.warning:
        baseColor = const Color(0xFFF59E0B);
        icon = Icons.warning_rounded;
        break;
      case ToastType.error:
        baseColor = const Color(0xFFEF4444);
        icon = Icons.error_rounded;
        break;
    }

    Color textColor = baseColor.computeLuminance() > 0.4 ? Colors.grey[900]! : Colors.white;
    BoxDecoration decoration;
    final double radius = style == ToastStyle.minimal ? 30.0 : 20.0;
    Color? neuBgColor;

    switch (style) {
      case ToastStyle.glassmorphism:
        textColor = isDark ? Colors.white : Colors.grey[900]!;
        decoration = BoxDecoration(
          border: Border.all(color: baseColor.withOpacity(isDark ? 0.4 : 0.6), width: 1.0),
          borderRadius: BorderRadius.circular(radius),
          color: baseColor.withOpacity(isDark ? 0.15 : 0.15),
        );
        break;
      case ToastStyle.neumorphism:
        final Color toastBg = isDark ? Color.alphaBlend(Colors.black.withOpacity(0.3), Colors.grey[900]!) : const Color(0xFFF0F3F8);
        textColor = isDark ? Colors.white : Colors.grey[800]!;
        neuBgColor = toastBg;
        decoration = BoxDecoration(
          color: toastBg,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.08), offset: const Offset(4, 4), blurRadius: 10),
            BoxShadow(color: isDark ? Colors.white.withOpacity(0.05) : Colors.white, offset: const Offset(-4, -4), blurRadius: 10),
          ],
        );
        break;
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
        textColor = isDark ? Colors.white : Colors.grey[900]!;
        decoration = BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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

    final bool isLargeScreen = MediaQuery.of(context).size.width > 800;

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (style == ToastStyle.neumorphism && neuBgColor != null)
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: neuBgColor,
                boxShadow: [
                  BoxShadow(color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7), offset: const Offset(2, 2), blurRadius: 2),
                  BoxShadow(color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.05), offset: const Offset(-2, -2), blurRadius: 3),
                ],
              ),
              child: Icon(icon, size: 20.0, color: baseColor),
            )
          else
            Icon(icon, size: 24.0, color: textColor),

          const SizedBox(width: 14.0),
          Expanded(
            child: Text(
              'Your settings look amazing!',
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600, color: textColor, letterSpacing: 0.2),
            ),
          ),

          if (buttonText != null) ...[
            const SizedBox(width: 8.0),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                backgroundColor: textColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                buttonText!,
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
          ],

          if (isLargeScreen) ...[
            const SizedBox(width: 12.0),
            Container(height: 24, width: 1, color: textColor.withOpacity(0.2)),
            const SizedBox(width: 8.0),
            InkWell(
              onTap: () {},
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

    Widget toastBody = Container(width: double.infinity, decoration: decoration, child: content);

    if (style == ToastStyle.glassmorphism) {
      toastBody = RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0), child: toastBody),
        ),
      );
    }

    return toastBody;
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _GlassCard({required this.child, this.padding = const EdgeInsets.all(24)});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.5), width: 1.0),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
}
