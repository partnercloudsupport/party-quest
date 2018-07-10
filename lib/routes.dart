/*
 * fluro
 * A Posse Production
 * http://goposse.com
 * Copyright (c) 2018 Posse Productions LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'games/info_page.dart';
import 'games/pickGame_page.dart';
import 'games/joinGame_page.dart';
import 'games/userProfile_page.dart';
import 'games/myGames_page.dart';

class Routes {

  static void configureRoutes(Router router) {
    router.notFoundHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
    });
    router.define('info', handler: infoPageHandler);
    router.define('userProfile', handler: userProfilePageHandler);
    router.define('newGame', handler: newGameHandler);
    router.define('joinGame', handler: joinGameHandler);
    router.define('myGames', handler: myGamesHandler);
    router.define('/', handler: homePageHandler);
  }

  static var homePageHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new HomePage();
  });

  static var newGameHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new PickGamePage();
  });

  static var joinGameHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new JoinGamePage();
  });

  static var infoPageHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new InfoPage();
  }); 
  
  static var myGamesHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new MyGamesPage();
  });

  static var userProfilePageHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new UserProfilePage();
  });

}