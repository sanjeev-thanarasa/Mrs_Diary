import 'package:flutter/material.dart';

class RoundedLoadingButtonController extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _isError = false;

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  bool get isError => _isError;

  void start() {
    _isLoading = true;
    _isSuccess = false;
    _isError = false;
    notifyListeners();
  }

  void stop() {
    _isLoading = false;
    notifyListeners();
  }

  void success() {
    _isLoading = false;
    _isSuccess = true;
    _isError = false;
    notifyListeners();
  }

  void error() {
    _isLoading = false;
    _isSuccess = false;
    _isError = true;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _isSuccess = false;
    _isError = false;
    notifyListeners();
  }
}

class RoundedLoadingButton extends StatefulWidget {
  final RoundedLoadingButtonController? controller;
  final VoidCallback? onPressed;
  final Widget child;
  final double width;
  final double height;
  final Color color;
  final Color? successColor;
  final Color? errorColor;
  final double elevation;

  const RoundedLoadingButton({
    super.key,
    required this.child,
    this.controller,
    this.onPressed,
    this.width = 200.0,
    this.height = 48.0,
    this.color = Colors.blue,
    this.successColor,
    this.errorColor,
    this.elevation = 2.0,
  });

  @override
  State<RoundedLoadingButton> createState() => _RoundedLoadingButtonState();
}

class _RoundedLoadingButtonState extends State<RoundedLoadingButton> {
  RoundedLoadingButtonController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant RoundedLoadingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      _controller = widget.controller;
      _controller?.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handlePressed() {
    if (widget.onPressed == null) {
      return;
    }
    _controller?.start();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _controller?.isLoading ?? false;
    final isSuccess = _controller?.isSuccess ?? false;
    final isError = _controller?.isError ?? false;

    Color background = widget.color;
    if (isSuccess && widget.successColor != null) {
      background = widget.successColor!;
    } else if (isError && widget.errorColor != null) {
      background = widget.errorColor!;
    }

    Widget content = widget.child;
    if (isLoading) {
      content = const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else if (isSuccess) {
      content = const Icon(Icons.check, color: Colors.white);
    } else if (isError) {
      content = const Icon(Icons.close, color: Colors.white);
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ElevatedButton(
        onPressed:
            widget.onPressed == null || isLoading ? null : _handlePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          elevation: widget.elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: content,
        ),
      ),
    );
  }
}
