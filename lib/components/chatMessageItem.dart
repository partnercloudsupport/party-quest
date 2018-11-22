import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart';
import 'package:party_quest/globals.dart' as globals;
import 'package:cached_network_image/cached_network_image.dart';

class ChatMessageListItem extends StatelessWidget {
  final int index;
  final Function onTap;
  final DocumentSnapshot document;
	ChatMessageListItem(this.index, this.document, this.onTap);

	Widget build(BuildContext context) {
     return GestureDetector(
        child: document['type'] == 'narration' ? _buildNarratorBubble() : _buildUserBubble(),
        onTapUp: (TapUpDetails details) => onTap(details, document));
  }

  Widget _buildNarratorBubble(){
    return Padding(padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0), 
      child: Column(
        children: <Widget>[
          document['titleImageUrl'] != null ?
          ( document['titleImageUrl'].contains('http') ? CachedNetworkImage(placeholder: CircularProgressIndicator(), imageUrl: document['titleImageUrl'], height: 120.0, width: 120.0) 
            : Container(width: 120.0, height: 120.0, decoration: BoxDecoration(image: DecorationImage(image: AssetImage(document['titleImageUrl']), fit: BoxFit.fill))))
          : Container(),
        document['title'] != null ?
          Padding(padding: EdgeInsets.only(top: 5.0, bottom: 10.0), child: Text(document['title'],
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.5, fontSize: 24.0)))
          : Container(),
            Bubble(
              message: document['text'].replaceAll('\\n', '\n\n'),
              time: timeAgo(document['dts'].toLocal()),
              personPerspective: 'third',
              type: document['type'],
              color: document['color'],
              reactions: document['reactions']),
      ]));
    }

  Widget _buildUserBubble(){
		var chatItem;
		if (document['userId'] != globals.currentUser.documentID) {
			chatItem = Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Expanded(
						child: Column(
						crossAxisAlignment: CrossAxisAlignment.end,
						children: [
							Bubble(
								message: document['text'],
								time: timeAgo(document['dts'].toLocal()),
								personPerspective: 'first',
								type: document['type'],
								reactions: document['reactions'],
                title: document['title']),
						],
					)),
					Container(
						margin: const EdgeInsets.only(left: 8.0),
						decoration: BoxDecoration(
							boxShadow: [
								BoxShadow(
									blurRadius: 10.0,
									spreadRadius: 1.0,
									offset: Offset(0.0, 7.0),
									color: Colors.black.withOpacity(.2))
							],
						),
						child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(.3),
              backgroundImage: document['profileUrl'].contains('http') ? CachedNetworkImageProvider(document['profileUrl']) : AssetImage(document['profileUrl']))
					),
				],
			);
		} else {
			chatItem = Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Container(
						margin: const EdgeInsets.only(right: 8.0),
						decoration: BoxDecoration(
							boxShadow: [
								BoxShadow(
									blurRadius: 10.0,
									spreadRadius: 1.0,
									offset: Offset(0.0, 7.0),
									color: Colors.black.withOpacity(.2))
							],
						),
						child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(.3),
              backgroundImage: document['profileUrl'].contains('http') ? CachedNetworkImageProvider(document['profileUrl']) : AssetImage(document['profileUrl'])),
					),
					Flexible(
						child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Bubble(
								message: document['text'],
								time: timeAgo(document['dts'].toLocal()),
								personPerspective: 'second',
								userName: document['userName'],
								type: document['type'],
								reactions: document['reactions'],
                title: document['title']),
						],
					)),
				],
			);
		}
		return Container(
			margin: const EdgeInsets.only(
				left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
			child: chatItem);
	}
}

class Bubble extends StatelessWidget {
	Bubble({this.message, this.time, this.personPerspective, this.type, this.color, this.userName, this.reactions, this.title});

	final String message, time, type, userName, title, color;
	final personPerspective;
	final Map reactions;

	@override
	Widget build(BuildContext context) {
		var bg = Colors.white.withOpacity(.2);
    var fontColor = Colors.white;
		if (type == 'characterAction') {
			bg = const Color(0xFFFEFFFE);
      fontColor = Colors.black;
		} else if(type == 'narration' && (color == 'FF694F' || color == '9deb00')) { // TODO: hacky hardcoding
      fontColor = Colors.black;
      // bg = Color(int.parse("0x" + 'FFF44336'));
      bg = Color(int.parse("0x" + 'FF' + color));
    }

		// final fontColor = type == 'characterAction'
		// 	? Colors.black
		// 	: color == null ? Colors.white : Color(int.parse("0x" + 'FF' + color));
		final align = personPerspective == 'first' ? CrossAxisAlignment.start : CrossAxisAlignment.end;
		// final icon = delivered ? Icons.done_all : Icons.done;
		final radius = personPerspective == 'first'
			? BorderRadius.only(
				topLeft: Radius.circular(20.0),
				bottomLeft: Radius.circular(20.0),
				bottomRight: Radius.circular(20.0),
				)
			: personPerspective == 'second' ? BorderRadius.only(
				topRight: Radius.circular(20.0),
				bottomLeft: Radius.circular(20.0),
				bottomRight: Radius.circular(20.0),
				) 
        : BorderRadius.all(Radius.circular(20.0)); //third
		return Column(
			crossAxisAlignment: align,
			children: <Widget>[
				Container(
					margin: const EdgeInsets.all(3.0),
					padding: const EdgeInsets.all(8.0),
					decoration: BoxDecoration(
						boxShadow: [
							BoxShadow(
								blurRadius: 10.0,
								spreadRadius: 1.0,
								offset: Offset(0.0, 10.0),
								color: Colors.black.withOpacity(.2))
						],
						color: bg,
						borderRadius: radius,
					),
					child: Stack(
						children: <Widget>[
							title != null
								? Positioned(
									top: 0.0,
									right: personPerspective == 'first' ? 0.0 : null,
									left: personPerspective == 'second' ? 0.0 : null,
									child: Text(title,
										style: TextStyle(
											fontSize: 14.0,
											color: fontColor,
											fontWeight: FontWeight.w600)),
									)
								: Container(width: 0.0, height: 0.0),
							Padding(
								padding: type != null
									? EdgeInsets.only(top: title != null ? 18.0 : 0.0, bottom: reactions != null ? 28.0 : title != null ? 10.0 : 0.0)
									: EdgeInsets.only(bottom: reactions != null ? 28.0 : title != null ? 10.0 : 0.0),
								child: Text(message,
									style: TextStyle(fontSize: 19.0, color: fontColor),
									textAlign: personPerspective == 'first' ? TextAlign.right : TextAlign.left),
							),
							Positioned(
								bottom: 0.0,
								right: personPerspective == 'first' ? 0.0 : null,
								left: personPerspective == 'second' ? 0.0 : null,
								child: 
									reactions == null ? Container() : _buildReactionsIcons(reactions, type)
							)
						],
					),
				)
			],
		);
	}

		Widget _buildReactionsIcons(Map reactions, String type){
			List<Widget> reactionsListTiles = [];

			for(var key in reactions.keys){
        var reactionCount;
        // BACKWARDS COMPATIBLE - changed reactions from storing an int to a array of userIds.
        if(reactions[key] is int){
          reactionCount = reactions[key].toString();
        } else {
          reactionCount = reactions[key].length.toString();
        }
				reactionsListTiles.add(Container(child: Image.asset('assets/images/reaction-' + key + '.png'), height: 30.0));
				reactionsListTiles.add(Padding(padding: EdgeInsets.only(right: 10.0, left: 0.0, top: 9.0), child: Text(reactionCount, style: TextStyle(color: type == 'characterAction' ? Colors.black : Colors.white, fontWeight: FontWeight.w400, fontSize: 10.0))));
			}
			return Container(height: 20.0, child: Row(children: reactionsListTiles));
		}
}
