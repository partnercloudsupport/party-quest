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
import 'info_page.dart';
import 'quests/pickQuest_page.dart';
import 'quests/joinQuest_page.dart';

class Routes {

  static void configureRoutes(Router router) {
    router.notFoundHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
    });
    router.define('info', handler: infoPageHandler);
    router.define('newQuest', handler: newQuestHandler);
    router.define('joinQuest', handler: joinQuestHandler);
    router.define('/', handler: homePageHandler);
  }

  static var homePageHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new HomePage();
  });

  static var newQuestHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new PickQuestPage();
  });

  static var joinQuestHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new JoinQuestPage();
  });

  static var infoPageHandler = new Handler(handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new InfoPage();
  });

}