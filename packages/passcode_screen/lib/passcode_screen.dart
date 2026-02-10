import 'dart:async';

import 'package:flutter/material.dart';
import 'circle.dart';
import 'keyboard.dart';

class PasscodeScreen extends StatefulWidget {
  final Widget title;
  final CircleUIConfig? circleUIConfig;
  final KeyboardUIConfig? keyboardUIConfig;
  final ValueChanged<String> passwordEnteredCallback;
  final Widget cancelButton;
  final Widget deleteButton;
  final Stream<bool> shouldTriggerVerification;
  final Color backgroundColor;
  final VoidCallback? cancelCallback;
  final List<String>? digits;
  final int passwordDigits;
  final Widget? bottomWidget;

  const PasscodeScreen({
    super.key,
    required this.title,
    required this.passwordEnteredCallback,
    required this.cancelButton,
    required this.deleteButton,
    required this.shouldTriggerVerification,
    required this.backgroundColor,
    required this.passwordDigits,
    this.circleUIConfig,
    this.keyboardUIConfig,
    this.cancelCallback,
    this.digits,
    this.bottomWidget,
  });

  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {
  String _input = '';
  StreamSubscription<bool>? _verificationSub;
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    _verificationSub = widget.shouldTriggerVerification.listen((isValid) {
      if (!isValid) {
        setState(() {
          _errorText = 'Incorrect passcode';
          _input = '';
        });
      } else {
        setState(() {
          _errorText = '';
        });
      }
    });
  }

  @override
  void dispose() {
    _verificationSub?.cancel();
    super.dispose();
  }

  void _handleDigit(String digit) {
    if (_input.length >= widget.passwordDigits) return;
    setState(() {
      _input = '$_input$digit';
    });
    if (_input.length >= widget.passwordDigits) {
      widget.passwordEnteredCallback(_input);
    }
  }

  void _handleDelete() {
    if (_input.isEmpty) return;
    setState(() {
      _input = _input.substring(0, _input.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final circleConfig = widget.circleUIConfig ?? const CircleUIConfig();
    final keyboardConfig = widget.keyboardUIConfig ?? const KeyboardUIConfig();
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.height < 640;
    final logoSize = isCompact ? 110.0 : 172.0;
    final keypadAspect = isCompact ? 1.35 : 1.1;
    final keypadSpacing = isCompact ? 8.0 : 12.0;
    final circleRadius = circleConfig.radius ?? 8.0;
    final borderColor = circleConfig.borderColor ?? Colors.white70;
    final fillColor = circleConfig.fillColor ?? Colors.white;
    final digitColor = keyboardConfig.digitColor ?? Colors.white;
    final cancelColor = keyboardConfig.cancelButtonColor ?? Colors.white70;
    final deleteColor = keyboardConfig.deleteButtonColor ?? Colors.white70;
    final digits =
        widget.digits ?? ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];

    final h = MediaQuery.sizeOf(context).height;
    final w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/MRS-LOGO.png',
                            height: w * 0.4,
                            width: w * 0.4,
                          ),
                          const SizedBox(height: 12),
                          widget.title,
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                                List.generate(widget.passwordDigits, (index) {
                              final filled = index < _input.length;
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                width: circleRadius * 1.5,
                                height: circleRadius * 1.5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      filled ? fillColor : Colors.transparent,
                                  border: Border.all(
                                      color: borderColor, width: 1.2),
                                ),
                              );
                            }),
                          ),
                          if (_errorText.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              _errorText,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        _buildKeypad(
                          digits: digits,
                          digitColor: digitColor,
                          aspectRatio: keypadAspect,
                          spacing: keypadSpacing,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: widget.cancelCallback,
                                child: DefaultTextStyle.merge(
                                  style: TextStyle(color: cancelColor),
                                  child: widget.cancelButton,
                                ),
                              ),
                              TextButton(
                                onPressed: _handleDelete,
                                child: DefaultTextStyle.merge(
                                  style: TextStyle(color: deleteColor),
                                  child: widget.deleteButton,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.bottomWidget != null) widget.bottomWidget!,
                        const SizedBox(height: 12),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildKeypad({
    required List<String> digits,
    required Color digitColor,
    double aspectRatio = 1.1,
    double spacing = 12,
  }) {
    final items = digits.length >= 10
        ? <String>[
            digits[0],
            digits[1],
            digits[2],
            digits[3],
            digits[4],
            digits[5],
            digits[6],
            digits[7],
            digits[8],
            '',
            digits[9],
            '',
          ]
        : digits;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: aspectRatio,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final value = items[index];
          if (value.isEmpty) return const SizedBox.shrink();
          return _DigitButton(
            digit: value,
            color: digitColor,
            onTap: () => _handleDigit(value),
          );
        },
      ),
    );
  }
}

class _DigitButton extends StatelessWidget {
  final String digit;
  final Color color;
  final VoidCallback onTap;

  const _DigitButton({
    required this.digit,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Center(
          child: Text(
            digit,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
