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
  final TextEditingController _controller = TextEditingController();
  StreamSubscription<bool>? _verificationSub;
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    _verificationSub = widget.shouldTriggerVerification.listen((isValid) {
      if (!isValid) {
        setState(() {
          _errorText = 'Incorrect passcode';
          _controller.clear();
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
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    if (value.length >= widget.passwordDigits) {
      widget.passwordEnteredCallback(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: widget.title,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: widget.passwordDigits,
                style: const TextStyle(color: Colors.white, fontSize: 22),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Enter passcode',
                  hintStyle:
                      TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  errorText: _errorText.isEmpty ? null : _errorText,
                  errorStyle: const TextStyle(color: Colors.redAccent),
                ),
                onChanged: _handleChanged,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: widget.cancelCallback,
                  child: widget.cancelButton,
                ),
                TextButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _controller.text = _controller.text
                          .substring(0, _controller.text.length - 1);
                      _controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: _controller.text.length),
                      );
                    }
                  },
                  child: widget.deleteButton,
                ),
              ],
            ),
            if (widget.bottomWidget != null) widget.bottomWidget!,
          ],
        ),
      ),
    );
  }
}
