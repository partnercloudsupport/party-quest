import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if(oldValue.text == newValue.text){
      return newValue;
    }
    return TextEditingValue(
      text: newValue.text?.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class JoinGamePage extends StatelessWidget {
  final TextEditingController _textController = TextEditingController();
  final UpperCaseTextFormatter upperCaseTextFormatter =
      new UpperCaseTextFormatter();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // color: Colors.white,
      appBar: new AppBar(
        elevation: -1.0,
        title: new Text("Join Game",
            style: new TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              fontSize: 22.0,
            )),
      ),
      body: Column(children: <Widget>[
        Padding(
            padding: EdgeInsets.all(20.0),
            child: Container(
                child: Column(
              children: <Widget>[
                TextFormField(
                  maxLines: 1,
                  maxLength: 5,
                  textAlign: TextAlign.start,
                  controller: _textController,
                  inputFormatters: <TextInputFormatter>[upperCaseTextFormatter],
                  keyboardType: TextInputType.text,
                  decoration:
                      InputDecoration.collapsed(hintText: "Enter a room code"),
                )
              ],
            ))),
        Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: new FlatButton(
                key: null,
                onPressed: () => _handleSubmitted(_textController.text),
                color: const Color(0xFFBA5536),
                child: new Text(
                  "Send Request",
                  style: new TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      ),
                ))),
        Padding(
          padding: const EdgeInsets.all(65.0),
        ),
      ]),
    );
  }

  static void _handleSubmitted(String text) {}
}
