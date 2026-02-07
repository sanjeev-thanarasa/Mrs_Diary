import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DatePicker extends StatefulWidget {
  final ValueChanged<DateTime> onDateTimeChanged;

  const DatePicker({
    super.key,
    required this.onDateTimeChanged,
  });
  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .35,
      color: Color.fromARGB(255, 255, 255, 255),
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * .25,
            child: CupertinoDatePicker(
              initialDateTime: DateTime.now(),
              onDateTimeChanged: widget.onDateTimeChanged,
              // setState(() {
              //   chosenDatetime = val;
              //   widget.dateWithTime
              //       ? widget.dateController.text= DateFormat('MM/dd/yyyy hh:mm a').format(chosenDatetime)
              //       : widget.dateController.text= chosenDatetime.toIso8601String().split('T').first;
              //
              // });
            ),
          ),

          // Close the modal
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue, // foreground
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
