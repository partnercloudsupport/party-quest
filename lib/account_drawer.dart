import 'package:flutter/material.dart';
import 'application.dart';
import 'package:fluro/fluro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountDrawer extends StatefulWidget {
  @override
  _AccountDrawerState createState() => _AccountDrawerState();
}

class _AccountDrawerState extends State<AccountDrawer> {
  CollectionReference get games => Firestore.instance.collection('Games');

  User currentUser = User(
      'Augustin Bralley',
      'augman@gmail.com',
      'https://lh3.googleusercontent.com/-DsBDODH3QXk/AAAAAAAAAAI/AAAAAAAAAAA/AAnnY7q3aaQQkR02rDq6Csf-UX4bg1c_-A/s192-c-mo/photo.jpg',
      'assets/images/city_bg.jpg');

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children
      ..addAll(_buildUserAccounts(context))
      ..addAll(_buildMainMenu(context))
      ..addAll([new Divider()])
      ..add(_buildLabel('My Games'))
      ..add(_buildMyGamesWidgets(context));

    return Drawer(
      child: ListView(padding: EdgeInsets.zero, children: children),
    );
  }

  Widget _buildLabel(String labelName) {
    return ListTile(
        title: Text(labelName,
            style: new TextStyle(
              color: Colors.grey,
              // fontWeight: FontWeight.w800,
              fontFamily: 'Roboto',
              // letterSpacing: 0.5,
              fontSize: 12.0,
            )));
  }

  List<Widget> _buildMainMenu(BuildContext context) {
    return [
      ListTile(
          title: Text("Create Game"),
          leading: Icon(Icons.create),
          onTap: () => Application.router.navigateTo(context, 'newGame',
              transition: TransitionType.fadeIn)),
      ListTile(
          title: Text("Join Game"),
          leading: Icon(Icons.contacts),
          onTap: () => Application.router.navigateTo(context, 'joinGame',
              transition: TransitionType.fadeIn))
    ];
  }

  List<Widget> _buildUserAccounts(BuildContext context) {
    return [
      UserAccountsDrawerHeader(
        accountEmail: new Text("10 Games, 543 points",
            style: new TextStyle(
              color: Colors.white,
              // fontWeight: FontWeight.w800,
              // fontFamily: 'Roboto',
              letterSpacing: 0.2,
              // fontSize: 22.0,
            )),
        accountName: Text(
          currentUser.name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontFamily: 'Roboto',
            letterSpacing: 0.5,
            fontSize: 20.0,
          ),
        ),
        currentAccountPicture: GestureDetector(
          child: CircleAvatar(
            backgroundImage: NetworkImage(currentUser.profilePic),
          ),
          onTap: () => Application.router.navigateTo(context, 'userProfile',
              transition: TransitionType.fadeIn),
        ),
        onDetailsPressed: () => Application.router.navigateTo(
            context, 'userProfile',
            transition: TransitionType.fadeIn),
        // otherAccountsPictures: <Widget>[
        //   GestureDetector(
        //     child: CircleAvatar(
        //       backgroundImage: NetworkImage(otherQuest.icon),
        //     ),
        //     onTap: () => switchAccounts(),
        //   ),
        // ],
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(currentUser.background), fit: BoxFit.fill)),
      )
    ];
  }

  Widget _buildMyGamesWidgets(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: games.orderBy('dts', descending: true).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...');
          List<Widget> labelListTiles = [];
          // final int messageCount = snapshot.data.documents.length;
          snapshot.data.documents.forEach((game) {
            labelListTiles.add(new ListTile(
              title: Text(game['code']),
              subtitle: Text(game['type']),
              // onTap: () => _onListTileTap(context, labelName),
            ));
          });
          return Column(children: labelListTiles);
        });
  }
}

class User {
  final String name;
  final String email;
  final String profilePic;
  final String background;

  User(this.name, this.email, this.profilePic, this.background);

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        email = json['email'],
        profilePic = json['profilePic'],
        background = json['background'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'profilePic': profilePic,
        'background': background
      };
}
