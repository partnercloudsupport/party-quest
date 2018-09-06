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
import 'pages/inviteFriends_page.dart';
import 'pages/pickScenario_page.dart';
import 'pages/pickCharacter_page.dart';
import 'pages/pickResponse_page.dart';
import 'pages/pickAction_page.dart';

class Routes {

  static void configureRoutes(Router router) {
    router.notFoundHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
    });
    router.define('info', handler: infoPageHandler);
    router.define('userProfile', handler: userProfilePageHandler);
    router.define('createGame', handler: createGameHandler);
    router.define('joinGame', handler: joinGameHandler);
    router.define('inviteFriends', handler: inviteFriendsHandler);
    router.define('pickScenario', handler: pickScenarioHandler);
    router.define('pickAction', handler: pickActionHandler);
    router.define('pickCharacter', handler: pickCharacterHandler);
    router.define('pickResponse', handler: pickResponseHandler);
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

  static var pickCharacterHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new PickCharacterPage();
  });

  static var pickActionHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new PickActionPage();
  });

  static var pickResponseHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new PickResponsePage();
  });

  static var pickScenarioHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    // String answerId = params["answerId"]?.first;
    return new PickScenarioPage();
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