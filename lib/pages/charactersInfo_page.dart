import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:party_quest/globals.dart' as globals;
import 'package:cloud_functions/cloud_functions.dart';

class CharactersInfoPage extends StatefulWidget {
  final DocumentSnapshot _gameInfo;
  final QuerySnapshot _gamePlayers;
  final QuerySnapshot _gameReactions;
  CharactersInfoPage(this._gameInfo, this._gamePlayers, this._gameReactions);
	@override
	_CharactersInfoPageState createState() => new _CharactersInfoPageState();
}

class _CharactersInfoPageState extends State<CharactersInfoPage> {
	final PageController _pageController = PageController();
  int _pageNumber = 0;
  int _characterCount = 0;

  @override
  Widget build(BuildContext context) {
    if(widget._gameInfo == null || widget._gameInfo['characters'] == null) return Container();
    // List<Widget> characterWidgets = [];
    _characterCount = 0;
    // for(var key in widget._gameInfo['characters'].keys){
    //   if(widget._gameInfo['characters'][key]['inactive'] == null || widget._gameInfo['characters'][key]['inactive'] != true){
    //     _characterCount++;
    //     characterWidgets.add(_buildCharacterWidget(widget._gameInfo['characters'][key]));
    //   }
    // }
    return widget._gameInfo.data['characters'] != null ? Stack(
      children: <Widget>[
        PageView(
          children: _buildCharacterWidgets(),
          controller: _pageController,
          onPageChanged: _onPageChange),
        _buildArrows(),
    ]) :
    Container();
  }

  List<Widget> _buildCharacterWidgets() {
    List<Widget> labelListTiles = [];
    widget._gamePlayers.documents.forEach((player) {
      Map playerReactions;
      for(final reactions in widget._gameReactions.documents){
        if(reactions.documentID == player.documentID){
          playerReactions = reactions.data;
          break;
        }
      }
      if(widget._gameInfo.data['characters'][player.documentID] != null && widget._gameInfo.data['characters'][player.documentID]['inactive'] != true){
        _characterCount++;
        labelListTiles.add(_buildCharacterWidget(widget._gameInfo.data['characters'][player.documentID], player, playerReactions));
      }
      // labelListTiles.add(Padding(padding: EdgeInsets.symmetric(vertical: 10.0), child: 
      
    });
    return labelListTiles;
  }

  Widget _buildReactionsRow(Map playerReactions){
		List<Widget> reactionsListTiles = [];
    for(var key in playerReactions.keys){
      reactionsListTiles.add(Container(child: Image.asset('assets/images/reaction-' + key + '.png'), height: 20.0));
			reactionsListTiles.add(Padding(padding: EdgeInsets.only(right: 10.0, left: 0.0, top: 9.0), child: Text("${playerReactions[key]}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 10.0))));
    }
    return Padding(padding: EdgeInsets.only(top: 5.0), child: Row(children: reactionsListTiles));
  }

  Widget _buildArrows(){
    return Padding(
      padding: EdgeInsets.only(top: 100.0), child:
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        _pageNumber != 0 ? IconButton(onPressed: _previousPage, icon: Icon(Icons.chevron_left, color: Colors.white), iconSize: 50.0) : Container(height: 50.0),
        _pageNumber != _characterCount-1 ? IconButton(onPressed: _nextPage, icon: Icon(Icons.chevron_right, color: Colors.white), iconSize: 50.0) : Container(height: 50.0),
        // GestureDetector(onTap: _nextPage, child: Icon(Icons.chevron_right, color: Colors.white, size: 50.0)),
    ]));
  }

  void _onPageChange(int pageNum) {
    setState((){
      _pageNumber = pageNum;
    });
  }

  void _nextPage(){
    _pageController.nextPage(duration: Duration(milliseconds: 1500), curve: Curves.elasticOut);
  }

  void _previousPage(){
    _pageController.previousPage(duration: Duration(milliseconds: 1500), curve: Curves.elasticOut);
  }

	Widget _buildCharacterWidget(Map character, DocumentSnapshot player, Map playerReactions) {
    var canRomove = player.documentID != widget._gameInfo.data['creator'] && globals.currentUser.documentID == widget._gameInfo.data['creator'];
    return Padding(padding: EdgeInsets.symmetric(horizontal: 20.0), child: ListView(children: <Widget>[
      Stack(
        alignment: Alignment.center,
        children: <Widget>[
        Container(child: Image(height: 250.0, image: character['imageUrl'].contains('http') ? CachedNetworkImageProvider(character['imageUrl']): AssetImage(character['imageUrl']))),
        character['HP'] <= 0 ? Container(child: Image(height: 250.0, image: AssetImage('assets/images/dead-text.png'))) : Container(),
      ]),
      // CharacterAnimation(document['characterFileName'], document['spriteX'], document['spriteY'], document['spriteCount'])), 
      Text(
         character['characterName'],
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 34.0,
          fontWeight: FontWeight.w800)),
      Padding(padding: EdgeInsets.only(bottom: 10.0, top: 0.0), 
        child: Row(children: <Widget>[
          Expanded(child: Padding(padding: EdgeInsets.only(right: 20.0), child: Text(character['HP'].toString() + 'HP', textAlign: TextAlign.right, style: TextStyle(color: Colors.red, fontSize: 22.0)))),
          Text(character['characterClass'] != null ? character['characterClass'] : '', style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w400)),
          Expanded(child: Padding(padding: EdgeInsets.only(left: 20.0), child: Text(character['XP'].toString() + 'XP', style: TextStyle(color: Colors.green, fontSize: 22.0)))),
      ])),
      Row(mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
          _buildSkillBoxWidget('Dexterity',  character['skills']['dexterity']),
          _buildSkillBoxWidget('Strength',  character['skills']['strength']),
          _buildSkillBoxWidget('Intelligence',  character['skills']['intelligence']),
          _buildSkillBoxWidget('Charisma',  character['skills']['charisma'])
          ]),
      Padding(padding: EdgeInsets.symmetric(vertical: 10.0), child: Container()),
      // Text('Played by',
      //   textAlign: TextAlign.left,
      //   style: TextStyle(color: Colors.white70, fontSize: 18.0, fontWeight: FontWeight.w400))),
      ListTile(
        isThreeLine: false,
        leading:  CircleAvatar(
          radius: 25.0, 
          backgroundColor: Colors.white.withOpacity(.3),
          backgroundImage: player['profilePic'].contains('http') ? CachedNetworkImageProvider(player['profilePic']) : AssetImage("${player['profilePic']}")),
        title: Text(player['name'], style: TextStyle(color: Colors.white, fontSize: 20.0)),
        subtitle: playerReactions == null? Container(width: 10.0) : _buildReactionsRow(playerReactions),
        trailing: (canRomove ? GestureDetector(child: Text('remove', style: TextStyle(color: Colors.blue, fontSize: 14.0)), onTap: () => _handleRemovePlayer(player)) : Container(width: 10.0)) 
      ),
      // Padding(padding: EdgeInsets.symmetric(vertical: 10.0), child: 
      // Text('Backstory',
      //   textAlign: TextAlign.left,
      //   style: TextStyle(color: Colors.white70, fontSize: 20.0, fontWeight: FontWeight.w400))),
      character['backstory'] != null ? Padding(padding: EdgeInsets.symmetric(vertical: 30.0), child: Text(character['backstory']['level1'], style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w400))) : Container()
      ]));
		}

    void _handleRemovePlayer(DocumentSnapshot player) async {
      await CloudFunctions.instance.call(functionName: 'removePlayer', parameters: <String, dynamic>{
        'userId': player.documentID,
        'gameId': globals.currentGame.documentID
      });
    }

		Widget _buildSkillBoxWidget(String dimension, int value) {
			return Expanded(
				child: Container(
				child: Padding(padding: EdgeInsets.all(0.0), 
					child: Column( children: <Widget>[
            Text((value > 0 ? '+' : '') + value.toString(), style: TextStyle(color: Colors.white, fontSize: 30.0)), 
            Text(dimension, style: TextStyle(color: Colors.white)
          )]
        ))));
		}
}