import 'package:flutter/material.dart';

class PopUpBox extends StatelessWidget {
  final BuildContext context;
  final String hintText;
  final String labelText;
  final String btnText;
  final ValueChanged<String> bthFunction;

  const PopUpBox({
    super.key,
    required this.context,
    required this.hintText,
    required this.labelText,
    required this.btnText,
    required this.bthFunction,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController textEditingController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: TextField(
          controller: textEditingController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: hintText,
            labelText: labelText,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontFamily: 'TamilArima',
              fontWeight: FontWeight.w600,
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'TamilArima',
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: <Widget>[
        TextButton(
          onPressed: () {
            textEditingController.clear();
            Navigator.pop(context);
          },
          child: const Text(
            'CANCEL',
            style: TextStyle(
              fontFamily: 'TamilArima',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            bthFunction(textEditingController.text);
            Navigator.pop(context);
            textEditingController.clear();
          },
          child: Text(
            btnText,
            style: const TextStyle(
              fontFamily: 'TamilArima',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
