import 'package:flutter/material.dart';
import '../components/gamesList_view.dart';
import '../components/playersList_view.dart';
import '../components/userProfile_view.dart';

class HomePage extends StatefulWidget {
	@override
	createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
	// String _title;
	final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

	@override
	Widget build(BuildContext context) {
		return DefaultTabController(
        length: 3,
        child: Scaffold(
			key: _scaffoldKey,
			// backgroundColor: Colors.white,
			// drawer: AccountDrawer(), // left side
			appBar: AppBar(
        elevation: 20.0,
        title:
          Container(
            // height: 200.0,
            child: 
            Row(children: <Widget>[
            Expanded(child: Text('Party', style: TextStyle(color: Colors.white, fontSize: 30.0), textAlign: TextAlign.right,)),
            Container(width: 40.0, child: Image.asset('assets/images/20D20.png')),
            Expanded(child: Text('Quest', style: TextStyle(color: Colors.white, fontSize: 30.0)))])
          // , decoration: BoxDecoration(
          //   image: DecorationImage(
          //     image: AssetImage("assets/images/header-gradient.png"),
          //     fit: BoxFit.fitWidth)),
          )
        ,
        bottom: TabBar(
            labelPadding: EdgeInsets.all(0.0),
            labelColor: Colors.white,
            labelStyle: TextStyle(fontSize: 30.0, fontFamily: 'LondrinaSolid'),
            unselectedLabelStyle: TextStyle(fontSize: 20.0, fontFamily: 'LondrinaSolid'),
            indicatorColor: Colors.white.withOpacity(0.0),
              tabs: [
                Tab(child: Text('Players')), //icon: Icon(Icons.people, color: Colors.white)),
                Tab(child: Text('Games')), //icon: Icon(Icons.bubble_chart, color: Colors.white)),
                Tab(child: Text('Profile')), //icon: Icon(Icons.person, color: Colors.white)),
              ],
            ),
				// leading: IconButton(
				// 	icon: Icon(Icons.account_circle, color: Colors.white),
				// 	onPressed: () => _scaffoldKey.currentState.openDrawer()),
				backgroundColor: Theme.of(context).primaryColor,
				// title: Text(_title == null ? 'Public Games' : _title,
				// 	style:
				// 		TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 25.0, letterSpacing: 1.5)),
				// elevation: 0.0,
				// actions: <Widget>[
				// 	IconButton(
				// 		icon: Icon(
				// 			Icons.info_outline,
				// 			color: Colors.white,
				// 		),
				// 		tooltip: 'Info about this Game.',
				// 		onPressed: _openInfoView)
				// ],
			),
			// bottomNavigationBar: _buildBottomBar(),
      body: Container(
				decoration: BoxDecoration(
					image: DecorationImage(
					// image: AssetImage("assets/images/$_gameType.jpg"),
					image: AssetImage("assets/images/background-cosmos.png"),
					fit: BoxFit.cover,
					// colorFilter: ColorFilter.mode(
					// Colors.black.withOpacity(0.9), BlendMode.dstATop)
				)
        ),
				child: TabBarView(
            children: [
              PlayersListView(),
              GamesListView(),
              UserProfileView()
            ],
          ))));   
	}
}
