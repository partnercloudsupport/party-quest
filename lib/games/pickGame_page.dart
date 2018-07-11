import 'package:flutter/material.dart';
import 'data.dart';
import 'pickGame_page_item.dart';
import 'package:fluro/fluro.dart';
import 'package:gratzi_game/application.dart';
import 'package:gratzi_game/components/page_transformer.dart';

class PickGamePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Stack(children: [
      Scaffold(
        // color: Colors.white,
        appBar: new AppBar(elevation: -1.0, title: new Text("Pick a Category")),
        body: Column(children: <Widget>[
          Expanded(
            child: PageTransformer(
              pageViewBuilder: (context, visibilityResolver) {
                return PageView.builder(
                  controller: PageController(viewportFraction: 0.85),
                  itemCount: sampleItems.length,
                  itemBuilder: (context, index) {
                    final item = sampleItems[index];
                    final pageVisibility =
                        visibilityResolver.resolvePageVisibility(index);
                    return IntroPageItem(
                      item: item,
                      pageVisibility: pageVisibility,
                    );
                  },
                );
              },
            ),
          ),
          new Padding(
              padding: const EdgeInsets.only(bottom: 55.0)),
        ]),
      ),
      // Positioned(
      //   left: 10.0,
      //   top: 35.0,
      //   width: 60.0,
      //   height: 60.0,
      //   child: new FlatButton(
      //           key: null,
      //           onPressed: () => Navigator.pop(context),
      //           color: Colors.white,
      //           child: new Icon(Icons.close))
      //   // new IconButton(
      //   //     icon: new Icon(Icons.close),
      //   //     tooltip: 'Close.',
      //   //     onPressed: () => Navigator.pop(context)),
      // ),
    ]);
  }
}
