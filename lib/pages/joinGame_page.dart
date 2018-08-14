import 'package:flutter/material.dart';
import 'package:pegg_party/globals.dart' as globals;
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (oldValue.text == newValue.text) {
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
        automaticallyImplyLeading: false,
        leading: new IconButton(
            icon: new Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        backgroundColor: const Color(0xFF00073F),
        title: new Text("Join Game",
            style: new TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              fontSize: 22.0,
            )),
      ),
      body: Container(
          width: 500.0,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/background-gradient.png"),
                  fit: BoxFit.fill)),
          child: Column(children: <Widget>[
            Row(children: <Widget>[
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(left: 15.0),
                      child: Text("Private Game",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12.0),
                          textAlign: TextAlign.left)))
            ]),
            Padding(
                padding: EdgeInsets.all(20.0),
                child: Container(
                    height: 60.0,
                    width: 300.0,
                    padding:
                        EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
                    child: Row(children: <Widget>[
                      Flexible(
                          child: TextFormField(
                        maxLines: 1,
                        maxLength: 5,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 8.0),
                        controller: _textController,
                        inputFormatters: <TextInputFormatter>[
                          upperCaseTextFormatter
                        ],
                        keyboardType: TextInputType.text,
                        decoration:
                            InputDecoration.collapsed(hintText: "Room code", hintStyle: TextStyle(color: Colors.white)),
                      ))
                    ]),
                    decoration: BoxDecoration(
                      color: const Color(0x33FFFFFF),
                      borderRadius: BorderRadius.circular(8.0),
                      // border:
                      //     Border(top: BorderSide(color: Colors.grey[200]))
                    ))),
            Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                child: new FlatButton(
                    key: null,
                    onPressed: () => _handleCodeSubmitted(_textController.text),
                    color: const Color(0xFF00b0ff),
                    child: new Text(
                      "Send Request",
                      style: new TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ))),
          ])),
    );
  }

  void _handleCodeSubmitted(String code) async {
    // QuerySnapshot snapshot = await Firestore.instance.collection('Games').where('code', isEqualTo: code).getDocuments();
    // var channelName = snapshot.documents;
    var userRef = Firestore.instance.collection('Users').document(globals.userState['userId']);
    userRef.get().then((snapshot) {
      Map userRequests = snapshot.data['requests'];
      userRequests[code] = true;
      userRef.updateData(<String, dynamic>{
        'requests': userRequests,
      });
    });

  }
}

// return ListView.builder(
//   itemCount: messageCount,
//   itemBuilder: (_, int index) {
//     final DocumentSnapshot document = snapshot.data.documents[index];
//     return Container(child: );
// return GestureDetector(
//   child: Container(
//       margin: const EdgeInsets.symmetric(
//           vertical: 16.0, horizontal: 24.0),
//       child: Stack(
//         children: <Widget>[
//           Container(
//               height: 124.0,
//               width: 300.0,
//               margin: EdgeInsets.only(left: 46.0),
//               padding: EdgeInsets.only(
//                   top: 20.0, left: 65.0, right: 20.0),
//               decoration: BoxDecoration(
//                 color: Color(0xFF333366),
//                 shape: BoxShape.rectangle,
//                 borderRadius: BorderRadius.circular(8.0),
//                 boxShadow: <BoxShadow>[
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 10.0,
//                     offset: Offset(0.0, 10.0),
//                   ),
//                 ],
//               ),
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Text(
//                         document['title'] != null
//                             ? document['title']
//                             : 'no title.',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w800,
//                             fontSize: 24.0)),
//                     Text(
//                         document['name'] != null
//                             ? document['name']
//                             : 'no name.',
//                         textAlign: TextAlign.left,
//                         style: TextStyle(
//                             color: Colors.white70,
//                             fontWeight: FontWeight.w100,
//                             fontSize: 16.0)),
//                   ])),
//           Container(
//             margin: EdgeInsets.symmetric(vertical: 16.0),
//             alignment: FractionalOffset.centerLeft,
//             child: CachedNetworkImage(
//               placeholder: CircularProgressIndicator(),
//               imageUrl: document['imageUrl'],
//               height: 92.0,
//               width: 92.0,
//             ),
//           ),
//         ],
//       )),
//   onTap: () => _handleGameSelected(document),
// );
