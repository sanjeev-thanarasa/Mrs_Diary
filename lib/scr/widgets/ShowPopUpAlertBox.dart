import 'package:flutter/material.dart';

class PopUpBox extends StatelessWidget {
  final BuildContext context;
  final String hintText;
  final String labelText;
  final String btnText;
  final Function bthFunction;

  const PopUpBox({Key key,
    @required this.context,
    @required this.hintText,
    @required this.labelText,
    @required this.btnText,
    @required this.bthFunction}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    TextEditingController textEditingController=TextEditingController();
    return AlertDialog(
      contentPadding: const EdgeInsets.all(20.0),
      content: new Row(
        children: <Widget>[
          new Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: new TextField(
                controller: textEditingController,
                autofocus: true,
                decoration: new InputDecoration(
                    hintText: hintText,
                    labelText: labelText,
                    labelStyle: TextStyle(fontSize: 25.0)

                ),
              ),
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
            child: const Text('CANCEL'),
            onPressed: (){
              textEditingController.clear();
              Navigator.pop(context);
            }

    ),

        ElevatedButton(
          onPressed: (){
            bthFunction(textEditingController.text);
            Navigator.pop(context);
            textEditingController.clear();
            },
          child: Text(btnText),
        ),

      ],
    );
  }
}
