/*
 * fluro
 * A Posse Production
 * http://goposse.com
 * Copyright (c) 2018 Posse Productions LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/info_page.dart';
import 'pages/createGame_pages.dart';
import 'pages/joinGame_page.dart';
import 'pages/userProfile_page.dart';
import 'pages/myGames_page.dart';
import 'pages/peggYourself_pages.dart';
import 'pages/inviteFriends_page.dart';
import 'pages/peggFriend_page.dart';
import 'pages/pickQuestion_page.dart';

class Routes {

  static void configureRoutes(Router router) {
    router.notFoundHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
    });
    router.define('info', handler: infoPageHandler);
    router.define('userProfile', handler: userProfilePageHandler);
    router.define('createGame', handler: createGameHandler);
    router.define('joinGame', handler: joinGameHandler);
    router.define('peggYourself', handler: peggYourselfHandler);
    router.define('inviteFriends', handler: inviteFriendsHandler);
    router.define('peggFriend', handler: peggFriendHandler);
    router.define('pickQuestion', handler: pickQuestionHandler);
    router.define('myGames', handler: myGamesHandler);
    router.define('/', handler: homePageHandler);
  }

  static var homePageHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new HomePage();
  });

  static var createGameHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new CreateGamePages();
  });

  static var joinGameHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new JoinGamePage();
  });

  static var peggYourselfHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new PeggYourselfPages();
  });

  static var pickQuestionHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new PickQuestionPage();
  });

  static var peggFriendHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    String answerId = params["answerId"]?.first;
    return new PeggFriendPage(answerId);
  });

  static var inviteFriendsHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    String code = params["code"]?.first;
    return new InviteFriendsPage(code);
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