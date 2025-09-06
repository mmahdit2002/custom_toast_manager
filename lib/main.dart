// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:toast_manager/toast_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent)),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ToastStyle _selectedStyle = ToastStyle.glassmorphism;
  ToastAnimation _selectedAnimation = ToastAnimation.slideFromTop;
  ToastType _selectedType = ToastType.success;

  @override
  Widget build(BuildContext context) {
    final spacing = const SizedBox(height: 16);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                spacing,
                _buildOptionCard(
                  title: 'Style',
                  leading: Icons.brush,
                  child: _buildChoiceChips<ToastStyle>(
                    values: ToastStyle.values,
                    selected: _selectedStyle,
                    labelFor: (s) => s.toString().split('.').last,
                    onSelected: (s) => setState(() => _selectedStyle = s),
                  ),
                ),
                spacing,
                _buildOptionCard(
                  title: 'Animation',
                  leading: Icons.motion_photos_on,
                  child: _buildChoiceChips<ToastAnimation>(
                    values: ToastAnimation.values,
                    selected: _selectedAnimation,
                    labelFor: (a) => a.toString().split('.').last,
                    onSelected: (a) => setState(() => _selectedAnimation = a),
                  ),
                ),
                spacing,
                _buildOptionCard(
                  title: 'Type',
                  leading: Icons.info,
                  child: _buildChoiceChips<ToastType>(
                    values: ToastType.values,
                    selected: _selectedType,
                    labelFor: (t) => t.toString().split('.').last,
                    onSelected: (t) => setState(() => _selectedType = t),
                  ),
                ),
                spacing,
                _buildPreviewCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({required String title, required IconData leading, required Widget child}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(leading, size: 18),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(_currentChoiceLabel(title), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  String _currentChoiceLabel(String title) {
    switch (title) {
      case 'Style':
        return _selectedStyle.toString().split('.').last;
      case 'Animation':
        return _selectedAnimation.toString().split('.').last;
      case 'Type':
        return _selectedType.toString().split('.').last;
      default:
        return '';
    }
  }

  Widget _buildChoiceChips<T>({required List<T> values, required T selected, required String Function(T) labelFor, required ValueChanged<T> onSelected}) {
    return Wrap(
      spacing: 4,
      alignment: WrapAlignment.center,
      children: values.map((v) {
        final isSelected = v == selected;
        return RawChip(
          label: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: Text(labelFor(v), style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
          ),
          selected: isSelected,
          onSelected: (_) => onSelected(v),
          showCheckmark: false,
          pressElevation: 0,
          selectedColor: Colors.blueAccent.shade100.withOpacity(0.3),
          backgroundColor: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        );
      }).toList(),
    );
  }

  Widget _buildPreviewCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.remove_red_eye),
                const SizedBox(width: 8),
                const Text('Live Preview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(_selectedAnimation.toString().split('.').last, style: const TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              builder: (context, value, _) {
                final offset = _transformOffsetForAnimation(_selectedAnimation, 16 * (1 - value));
                return Transform.translate(
                  offset: offset,
                  child: Opacity(opacity: value, child: _ToastPreview(context)),
                );
              },
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ElevatedButton(
                onPressed: () {
                  showCustomToast(_selectedStyle, _selectedAnimation, _selectedType, 'Test Toast Message', context: context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 8,
                  surfaceTintColor: Colors.blueAccent.shade100.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.campaign),
                    const SizedBox(width: 12),
                    const Text('Show Toast', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Offset _transformOffsetForAnimation(ToastAnimation anim, double magnitude) {
    switch (anim) {
      case ToastAnimation.slideFromTop:
        return Offset(0, -magnitude);
      case ToastAnimation.fadeIn:
        return Offset(0, 0);
      case ToastAnimation.bounceIn:
        return Offset(0, -magnitude / 2);
      case ToastAnimation.scaleIn:
        return Offset(0, 0);
      case ToastAnimation.rotateIn:
        return Offset(magnitude / 3, 0);
      case ToastAnimation.flipIn:
        return Offset(0, magnitude / 3);
    }
  }

  // ignore: non_constant_identifier_names
  Widget _ToastPreview(BuildContext context) {
    final borderRadius = BorderRadius.circular(12.0);
    final icon = _iconForType(_selectedType);
    final label = _selectedType.toString().split('.').last.toUpperCase();

    Widget contentRow(Color textColor) {
      return Row(
        children: [
          Icon(icon, size: 22, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textColor),
                ),
                const SizedBox(height: 2),
                Text('This is how your toast will look.', style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.9))),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(_selectedAnimation.toString().split('.').last, style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.85))),
        ],
      );
    }

    switch (_selectedStyle) {
      case ToastStyle.glassmorphism:
        return ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: _colorForType(_selectedType).withOpacity(0.4), width: 1.5),
                borderRadius: BorderRadius.circular(16.0),
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_colorForType(_selectedType).withOpacity(0.3), _colorForType(_selectedType).withOpacity(0.1)]),
              ),
              child: contentRow(Colors.grey[700]!),
            ),
          ),
        );

      case ToastStyle.neumorphism:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Color.lerp(Colors.grey[100]!, _colorForType(_selectedType).withOpacity(0.6), 0.4)!,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Color.lerp(Color.lerp(Colors.grey[100]!, _colorForType(_selectedType).withOpacity(0.6), 0.4)!, Colors.white, 0.7)!,
                offset: const Offset(-6, -6),
                blurRadius: 12,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Color.lerp(Color.lerp(Colors.grey[100]!, _colorForType(_selectedType).withOpacity(0.6), 0.4)!, Colors.black, 0.2)!,
                offset: const Offset(6, 6),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: contentRow(Colors.grey[700]!),
        );

      case ToastStyle.flat:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: _colorForType(_selectedType),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [BoxShadow(color: _colorForType(_selectedType).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: contentRow(Colors.grey[700]!),
        );

      case ToastStyle.gradient:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_colorForType(_selectedType), Color.lerp(_colorForType(_selectedType), Colors.white, 0.3)!]),
            boxShadow: [BoxShadow(color: _colorForType(_selectedType).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))],
          ),
          child: contentRow(Colors.grey[700]!),
        );

      case ToastStyle.bordered:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: _colorForType(_selectedType).withOpacity(0.15),
            border: Border.all(color: _colorForType(_selectedType), width: 2.5),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [BoxShadow(color: _colorForType(_selectedType).withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))],
          ),
          child: contentRow(Colors.grey[700]!),
        );

      case ToastStyle.shadowed:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: _colorForType(_selectedType),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [BoxShadow(color: _colorForType(_selectedType).withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 5))],
          ),
          child: contentRow(Colors.grey[700]!),
        );

      case ToastStyle.glowing:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: _colorForType(_selectedType).withOpacity(0.15),
            border: Border.all(color: _colorForType(_selectedType), width: 2.5),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [BoxShadow(color: _colorForType(_selectedType).withOpacity(0.5), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 0))],
          ),
          child: contentRow(Colors.grey[700]!),
        );
      case ToastStyle.minimal:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(color: _colorForType(_selectedType).withOpacity(0.9), borderRadius: BorderRadius.circular(30.0)),
          child: contentRow(Colors.grey[700]!),
        );
    }
  }

  IconData _iconForType(ToastType t) {
    switch (t) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.warning:
        return Icons.warning_amber_rounded;
      case ToastType.error:
        return Icons.error;
    }
  }

  Color _colorForType(ToastType t) {
    switch (t) {
      case ToastType.success:
        return Colors.green.shade600;
      case ToastType.warning:
        return Colors.orange.shade700;
      case ToastType.error:
        return Colors.red.shade700;
    }
  }
}
