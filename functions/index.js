const functions = require('firebase-functions');
const _ = require('underscore');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });


const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

// exports.onPlayerAdded = functions.firestore  
//   .document('Games/{gameId}')
//   .onWrite((change, context) => {
//     console.log(change.after.data());
//     console.log(gameId);
//   });

// exports.turnChange = functions.firestore.document('Games/{gameId}/Logs/{logId}').onCreate((snap, context) => {
//   const newLog = snap.data();
//   if (newLog.type == 'guess' || newLog.type == 'question') {
//     var turnRef = db.collection('Games/' + context.params.gameId + '/Logs').doc('Turn');
//     return turnRef.get().then((turnResult) => {
//       var turnData = turnResult.data()
//       // console.log(turnData);
//       if (newLog.type == 'guess') {
//         // Add user to guessers
//         var guessers = turnData['guessers'] == null ? {} : turnData['guessers'];
//         guessers[newLog.userId] = true;
//         return turnRef.update({ 'guessers': guessers });
//       } else if (newLog.type == 'question') {
//         // Reset guessers to empty
//         return turnRef.update({ 'guessers': {}, 'type': 'peggFriend' });
//       }
//     });
//   } else {
//     return null;
//   }
// });

exports.reactionChange = functions.firestore
  .document('Games/{gameId}/Reactions/{authorId}')
  .onWrite((change, context) => {
    var authorId = context.params.authorId;
    var gameId = context.params.gameId;
    var beforeData = change.before.data();
    var afterData = change.after.data();
    // console.log(beforeData);
    // console.log(afterData);
    var diff = _.omit(afterData, function(v,k) { return beforeData[k] === v; });
    var reactionType = _.keys(diff)[0]; // we only care about one reaction (shouldnt be more than one)
    if(reactionType != null) {
      // Increment User.totalReactions and User.reactions[reactionType]
      var userRef = db.collection('Users').doc(authorId);
      var userPromise = userRef.get().then((userResult) => {
        var reactions = userResult.data()['reactions'];
        var totalReactions = userResult.data()['totalReactions'];
        if(reactions == null) reactions = {};
        reactions[reactionType] == null ? reactions[reactionType] = 1 : reactions[reactionType]++;
        totalReactions == null ? totalReactions = 1 : totalReactions++;
        return userRef.update({'reactions': reactions, 'totalReactions': totalReactions});
      });

      // Increment Game.totalReactions
      var gameRef = db.collection('Games').doc(gameId);
      var gamePromise = gameRef.get().then((gameResult) => {
        var reactions = gameResult.data()['reactions'];
        var totalReactions = gameResult.data()['totalReactions'];
        if(reactions == null) reactions = {};
        reactions[reactionType] == null ? reactions[reactionType] = 1 : reactions[reactionType]++;
        totalReactions == null ? totalReactions = 1 : totalReactions++;
        return gameRef.update({'reactions': reactions, 'totalReactions': totalReactions});
      });

      return Promise.all([gamePromise, userPromise]);
    }
  });


exports.removePlayer = functions.https.onCall((data, context) => {
  // console.log("uid: " + context.auth.uid);
  console.log(data);
  var gameRef = db.collection('Games').doc(data.gameId);
  var userRef = db.collection('Users').doc(data.userId);
  return gameRef.get().then((gameResult) => {
    var gameData = gameResult.data()
    // console.log("creator: " + gameData['creator']);
    // Only the game creator can remove players
    if (gameData['creator'] == context.auth.uid) {
      // Remove user from Game.players
      var players = gameData['players']
      delete players[data.userId];
      // Update turn to next player if it was the removed player's turn
      var turn = gameData['turn']
      if(turn['playerId'] == data.userId){
        turn['turnPhase'] = 'act';
        turn['playerId'] = Object.keys(players)[0];
        turn['playerImageUrl'] = null;
        turn['playerName'] = null;
      }
      // deactivate player's character
      gameData['characters'][data.userId]['inactive'] = true;
      return gameRef.update({ 'players': players, 'turn': turn, 'characters': gameData['characters'] }).then(() => {
        // Remove user from User.games
        return userRef.get().then(userResult => {
          var userData = userResult.data()
          var games = userData['games'] == null ? {} : userData['games'];
          delete games[data.gameId];
          return userRef.update({ 'games': games });
        });
      });
    } else {
      return null;
    }
  });
});

exports.createRequest = functions.https.onCall((data, context) => {
  var title, body, recipientId;
  data.userId = context.auth.uid;
  switch(data.requestType) {
    case 'joinGame': 
      title =  "New request to join the party!";
      body = data.userName + " would like to join '" + data.gameTitle + "'";
      recipientId = data.creatorId;
      break;
    default: return;
  }
  data.title = title;
  data.body = body;
  return db.collection('Users/' + recipientId + '/Inbox')
    .add(data).then((docRef) => {
      data.inboxId = docRef.id;
      let payload = {
        data: data,
        notification: {
            title: title,
            body: body,
            sound: 'default',
            badge: '1'
      }};
      return sendPush(recipientId, payload);
    })
});


exports.rejectRequest = functions.https.onCall((data, context) => {
  // console.log("uid: " + context.auth.uid);
  var userRef = db.collection('Users').doc(data.friendId);
  var inboxRef = db.collection('Users').doc(data.userId).collection('Inbox').doc(data.inboxId);
  return userRef.get().then(userResult => {
    var userData = userResult.data()
    var requests = userData['requests'];
    requests[data.gameId] = null;
    var batch = db.batch();
    // Remove request from User.requests
    // Delete inbox item
    batch.update(userRef, { 'requests': requests });
    batch.delete(inboxRef);
    return batch.commit();
  });
});

exports.acceptRequest = functions.https.onCall((data, context) => {
  // console.log("uid: " + context.auth.uid);
  var gameRef = db.collection('Games').doc(data.gameId);
  var userRef = db.collection('Users').doc(data.friendId);
  var inboxRef = db.collection('Users').doc(data.userId).collection('Inbox').doc(data.inboxId);
  return db.runTransaction(function(transaction) {
    return transaction.getAll(gameRef, userRef).then(function(results) {
      var gameData = results[0].data();
      var userData = results[1].data();
      //UPDATE GAME
      if (gameData['creator'] != context.auth.uid) return null;  // Only the game creator can approve requests
      var players = gameData['players']
      players[data.friendId] = true;
      if(gameData['characters'][data.friendId] != null) gameData['characters'][data.friendId]['inactive'] = false; // player may be inactive (been removed)
      // Add friend to Game.players
      transaction.update(gameRef, { 'players': players, 'characters': gameData['characters'] });
      //UPDATE USER
      var games = userData['games'] == null ? {} : userData['games'];
      games[data.gameId] = true;
      var requests = userData['requests'];
      requests[data.gameId] = null;
      var batch = db.batch();
      // Add game to friend's User.games
      // Remove request from friend's User.requests
      // Delete inbox item
      batch.update(userRef, { 'games': games, 'requests': requests });
      batch.delete(inboxRef);
      batch.commit().then(() => {
        let payload = {
          data: data,
          notification: {
            title: "You've been accepted into the party.",
            body: "Welcome to " + data.gameTitle + "!",
            sound: 'default',
            badge: '1' }};
        sendPush(data.friendId, payload);
      });
    });
  });
});

exports.sendPush = functions.database.ref('/push/{pushId}')
  .onCreate((snapshot, context) => {
    console.log(snapshot.val());
    let pushData = snapshot.val();
    let payload = {
      notification: {
          title: pushData.title,
          body: pushData.message,
          sound: 'default',
          badge: '1'
      },
      data: pushData
    };
    // console.log(pushData.friendId)
    return sendPush(pushData.userId, payload)
      .then(results => {
        // Delete the push item
        console.log(results);
        snapshot.ref.remove()
      });
});

function sendPush(recipientId, payload){
  return loadTokens(recipientId).then(tokens => {
    admin.messaging().sendToDevice(tokens, payload)
  });
}

function loadTokens(userId) {
  let dbRef = admin.database().ref('/deviceTokens/' + userId);
  let defer = new Promise((resolve, reject) => {
      dbRef.once('value', (snapshot) => {
          let data = snapshot.val();
          console.log(data);
          let tokens = [];
          for (var property in data) {
            tokens.push(property);
          }
          resolve(tokens);
      }, (err) => {
          reject(err);
      });
  });
  return defer;
}