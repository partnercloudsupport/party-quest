import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PickScenarioPage extends StatelessWidget {
  PickScenarioPage(this.genre, this.callback);
  final DocumentSnapshot genre;
  final Function callback;

	@override
	Widget build(BuildContext context) {
    return (genre == null)
			? Container() :
		  Scaffold(body: 
      Container(
				decoration: BoxDecoration(
					image: DecorationImage(
						image: AssetImage("assets/images/background-gradient.png"),
						fit: BoxFit.fill)),
        child: Column(children: <Widget>[
          Text(
            "Pick a Scenario",
            style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 30.0),
          ),
          Expanded(
            child: _buildPickScenario())
      ])));
	}

	Widget _buildPickScenario() {
    String genreName = genre.documentID;
    return StreamBuilder<QuerySnapshot>(
			stream: Firestore.instance
				.collection('Genres/$genreName/Scenarios')
				.snapshots(),
			builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
				if (!snapshot.hasData) return const Text('Loading...');
				final int messageCount = snapshot.data.documents.length;
				return ListView.builder(
					itemCount: messageCount,
					itemBuilder: (_, int index) {
						final DocumentSnapshot document =
							snapshot.data.documents[index];
						return GestureDetector(
							child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  padding: EdgeInsets.only(top: 10.0),
                  decoration: BoxDecoration(
												color: Color(0xFF333366),
												shape: BoxShape.rectangle,
												borderRadius: BorderRadius.circular(8.0),
												boxShadow: <BoxShadow>[
													BoxShadow(
														color: Colors.black12,
														blurRadius: 10.0,
														offset: Offset(0.0, 10.0),
													),
												],
											),
                child: Column(children: <Widget> [
                Container(
                  alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    document['title'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                    fontWeight: FontWeight.w800))),
                Container(
                  alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                  child: Text(document['description'],
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18.0))),
              ])),
							onTap: () => callback(context, document));
					});
			});
		}
}
