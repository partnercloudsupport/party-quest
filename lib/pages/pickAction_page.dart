import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pegg_party/globals.dart' as globals;
// import 'dart:math';

class PickActionPage extends StatefulWidget {
	@override
	_PickActionPageState createState() => new _PickActionPageState();
}

class _PickActionPageState extends State<PickActionPage> with SingleTickerProviderStateMixin {
	dynamic _characterData;
	dynamic _turnData;
	TabController _tabController;
	TextEditingController _textController;
  List<String> _skills = ['dexterity', 'strength', 'charisma', 'intelligence'];

	@override
	void initState() {
		super.initState();
		_tabController = TabController(vsync: this, length: 4);
    _textController = TextEditingController();
	}

	@override
	void dispose() {
		_tabController.dispose();
		_textController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: new AppBar(
				automaticallyImplyLeading: false,
				leading: new IconButton(
					icon: new Icon(Icons.close, color: Colors.white),
					onPressed: () => Navigator.pop(context)),
				backgroundColor: const Color(0xFF00073F),
				elevation: -1.0,
				title: new Text(
					"What do you do?",
					style:
						TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 30.0, letterSpacing: 1.5),
				)),
			body: Container(
				decoration: BoxDecoration(
					image: DecorationImage(
						image: AssetImage("assets/images/background-gradient.png"),
						fit: BoxFit.fill)),
				child: _buildBody()));
	}

	Widget _buildBody() {
		var _gameId = globals.gameState['id'];
			return FutureBuilder(
			future: Firestore.instance.collection('Games').document(_gameId).get(),
			builder: (BuildContext context, AsyncSnapshot snapshot) {
				if(snapshot.hasData){
				  _characterData = snapshot.data['characters'][globals.userState['userId']];
          _turnData = snapshot.data['turn'];
          List<Widget> pageWidgets = [];
          pageWidgets
            ..addAll(_buildHeaderDetails())
            ..addAll(_buildTabsDetails())
            ..addAll(_buildDescriptionField())
            ..addAll(_buildSubmitButton());
          return Column( children: <Widget>[Expanded(child: Container(child: ListView(children: pageWidgets)))]);
        } else {
				  return CircularProgressIndicator(); 
        }
			});
		}

	List<Widget> _buildHeaderDetails(){
			return [
				CachedNetworkImage(
					placeholder: CircularProgressIndicator(),
					imageUrl: _characterData['imageUrl'],
					height: 180.0,
					width: 180.0), 
				Center(child: Padding(padding: EdgeInsets.only(top: 5.0, bottom: 20.0), child: Text(
					_characterData['characterName'],
					style: TextStyle(
						color: Colors.white,
						fontSize: 22.0,
						fontWeight: FontWeight.w800)))),
			];
		}

	List<Widget> _buildTabsDetails(){
			return [
				Padding(padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0), child: Text(
				'Pick a skill:',
				style: TextStyle(
					color: const Color(0xFFFFFFFF),
					fontSize: 18.0,
					fontWeight: FontWeight.w400))),
			TabBar(
				controller: _tabController,
        unselectedLabelColor: const Color(0x66FFFFFF),
        labelColor: const Color(0xFFFFFFFF),
        indicatorSize: TabBarIndicatorSize.tab,
				tabs: <Tab>[
					Tab(icon: Column(children: <Widget>[
						Text(_characterData['skills']['dexterity'].toString(), style: TextStyle(fontSize: 20.0)),
						Text('dexterity'.toString(), style: TextStyle(fontSize: 14.0)),
					])),
					Tab(icon: Column(children: <Widget>[
						Text(_characterData['skills']['strength'].toString(), style: TextStyle(fontSize: 20.0)),
						Text('strength'.toString(), style: TextStyle(fontSize: 14.0)),
					])),
					Tab(icon: Column(children: <Widget>[
						Text(_characterData['skills']['charisma'].toString(), style: TextStyle(fontSize: 20.0)),
						Text('charisma'.toString(), style: TextStyle(fontSize: 14.0)),
					])),
					Tab(icon: Column(children: <Widget>[
						Text(_characterData['skills']['intelligence'].toString(), style: TextStyle(fontSize: 20.0)),
						Text('intelligence'.toString(), style: TextStyle(fontSize: 14.0)),
					]))
					]
				),
				Row( children: <Widget>[ Expanded(child: Container(height: 50.0, child: TabBarView(
					controller: _tabController,
					children: //myTabs.map((Tab tab) {
						<Widget> [
							Container(child: Padding(padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), child: Text('Move, dodge, sneak...', style: TextStyle(color: const Color(0xFFFFFFFF), fontSize: 16.0)))),
							Container(child: Padding(padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), child: Text('Break, jump, hit, withstand...', style: TextStyle(color: const Color(0xFFFFFFFF), fontSize: 16.0)))),
							Container(child: Padding(padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), child: Text('Persuade, charm, bribe, disarm...', style: TextStyle(color: const Color(0xFFFFFFFF), fontSize: 16.0)))),
							Container(child: Padding(padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), child: Text('Find something, discern a truth, use a device...', style: TextStyle(color: const Color(0xFFFFFFFF), fontSize: 16.0)))),
						]
					// }).toList(),
				)))]),
			];
		}

	List<Widget> _buildDescriptionField(){
				return [ Container(
				height: 100.0,
				margin: EdgeInsets.symmetric(horizontal: 10.0),
				padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
				child: TextField(
					maxLines: null,
					keyboardType: TextInputType.text,
					controller: _textController,
					style: TextStyle(color: Colors.white, fontSize: 18.0, fontFamily: 'LondrinaSolid'),
					decoration:
						InputDecoration.collapsed(hintText: 'Describe the action.', hintStyle: TextStyle(color: const Color(0x99FFFFFF))),
				),
				decoration: BoxDecoration(
					color: const Color(0x33FFFFFF),
					borderRadius: BorderRadius.circular(8.0)),
			)
				];
			}

	List<Widget> _buildSubmitButton(){
					return [Container(
				margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
				child: Padding(
					padding: const EdgeInsets.only(top: 20.0),
					child: RaisedButton(
						padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 50.0),
							color: const Color(0xFF00b0ff),
							shape: new RoundedRectangleBorder(
								borderRadius:
									new BorderRadius.circular(
										10.0)),
							onPressed: () => _handleSubmitted(),
							child: new Text(
								"Attempt to do this.",
								style: new TextStyle(
									fontSize: 20.0,
									color: Colors.white,
									fontWeight: FontWeight.w800,
								)))))
						];
				}

  void _handleSubmitted(){
      Navigator.pop(context);
		  var _gameId = globals.gameState['id'];
      var chosenSkill = _skills[_tabController.index];
      var skillPower = _characterData['skills'][chosenSkill];
			Firestore.instance.collection('Games/$_gameId/Logs').document()
      .setData(<String, dynamic>{
        'text': _textController.text,
        'title': chosenSkill,
        'type': 'characterAction',
        'dts': DateTime.now(),
        'profileUrl': _characterData['imageUrl'],
        'userId': globals.userState['userId']
      });
			Firestore.instance.collection('Games/$_gameId/Logs').document()
      .setData(<String, dynamic>{
        'text': _characterData['characterName'] + ' succeeds spectacularly!',
        'type': 'narration',
        'dts': DateTime.now(),
        'userId': globals.userState['userId']
      });
      var turns = [_turnData, {'turnPhase': 'respond', 'dts': DateTime.now()}];
      var combinedTurns = turns.reduce((map1, map2) => map1..addAll(map2));
      final DocumentReference turn =
        Firestore.instance.collection('Games').document(_gameId);
      turn.updateData(<String, dynamic>{
        'turn': combinedTurns
      });
    }
}
