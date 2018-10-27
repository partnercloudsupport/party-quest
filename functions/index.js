const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });


const admin = require('firebase-admin');
admin.initializeApp();

// exports.onPlayerAdded = functions.firestore
//   .document('Games/{gameId}')
//   .onWrite((change, context) => {
//     console.log(change.after.data());
//     console.log(gameId);
//   });

// exports.turnChange = functions.firestore.document('Games/{gameId}/Logs/{logId}').onCreate((snap, context) => {
//   const newLog = snap.data();
//   if (newLog.type == 'guess' || newLog.type == 'question') {
//     var turnRef = admin.firestore().collection('Games/' + context.params.gameId + '/Logs').doc('Turn');
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

exports.removePlayer = functions.https.onCall((data, context) => {
  // console.log("uid: " + context.auth.uid);
  console.log(data);
  var gameRef = admin.firestore().collection('Games').doc(data.gameId);
  var userRef = admin.firestore().collection('Users').doc(data.userId);
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


exports.acceptRequest = functions.https.onCall((data, context) => {
  // console.log("uid: " + context.auth.uid);
  console.log(data);
  var gameRef = admin.firestore().collection('Games').doc(data.gameId);
  var userRef = admin.firestore().collection('Users').doc(data.userId);
  return gameRef.get().then((gameResult) => {
    var gameData = gameResult.data()
    console.log("creator: " + gameData['creator']);
    // Only the game creator can approve requests
    if (gameData['creator'] == context.auth.uid) {
      // Add user to Game.players
      var players = gameData['players']
      players[data.userId] = true;
      // reactivate player's character
      if(gameData['characters'][data.userId] != null){
        // console.log('set inactive to false' + gameData['characters'][data.userId]);
        gameData['characters'][data.userId]['inactive'] = false;
      }
      // console.log("players: " + players);
      return gameRef.update({ 'players': players, 'characters': gameData['characters'] }).then(() => {
        // Add game to User.games
        return userRef.get().then(userResult => {
          var userData = userResult.data()
          var games = userData['games'] == null ? {} : userData['games'];
          games[data.gameId] = true;
          // console.log("games: " + games);
          var requests = userData['requests'];
          requests[data.code] = null;
          // console.log("requests: " + requests);
          return userRef.update({ 'games': games, 'requests': requests });
        });
      });
    } else {
      return null;
    }
  });
  // res.send(Items[Math.floor(Math.random()*Items.length)]);
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
    return loadTokens(pushData.friendId).then(tokens => {
      admin.messaging().sendToDevice(tokens, payload)
      .then( results => {
        // Delete the push item
        console.log(results);
        snapshot.ref.remove()
      });
  });
});

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