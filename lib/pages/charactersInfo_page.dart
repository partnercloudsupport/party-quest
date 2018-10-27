import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CharactersInfoPage extends StatefulWidget {
  final DocumentSnapshot _gameInfo;
  CharactersInfoPage(DocumentSnapshot gameInfo) : this._gameInfo = gameInfo;
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
    List<Widget> characterWidgets = [];
    _characterCount = 0;
    for(var key in widget._gameInfo['characters'].keys){
      if(widget._gameInfo['characters'][key]['inactive'] == null || widget._gameInfo['characters'][key]['inactive'] != true){
        _characterCount++;
        characterWidgets.add(_buildCharacterWidget(widget._gameInfo['characters'][key]));
      }
    }
    return Stack(
      children: <Widget>[
        PageView(
          children: characterWidgets,
          controller: _pageController,
          onPageChanged: _onPageChange),
        _buildArrows(),
    ]);
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

	Widget _buildCharacterWidget(Map character) {  
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
      character['backstory'] != null ? Padding(padding: EdgeInsets.symmetric(vertical: 30.0), child: Text(character['backstory']['level1'], style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w400))) : Container()
      ]));
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