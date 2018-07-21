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

exports.acceptRequest = functions.https.onCall((data, context) => {
  // console.log("uid: " + context.auth.uid);
  console.log(data);
  var gameRef = admin.firestore().collection('Games').doc(data.gameId);
  var userRef = admin.firestore().collection('Users').doc(data.userId);
  return gameRef.get().then( (gameResult) => {
    var gameData = gameResult.data()
    console.log("creator: " + gameData['creator']);
    // Only the game creator can approve requests
    if(gameData['creator'] == context.auth.uid) {
      // Add user to Game.players
      var players = gameData['players']
      players[data.userId] = true;
      // console.log("players: " + players);
      return gameRef.update({'players': players}).then(() => {
        // Add game to User.games
        return userRef.get().then(userResult => {
          var userData = userResult.data()
          var games = userData['games'] == null ? {} : userData['games'];
          games[data.gameId] = true;
          // console.log("games: " + games);
          var requests = userData['requests'];
          requests[data.code] = null;
          // console.log("requests: " + requests);
          return userRef.update({'games': games, 'requests': requests});    
        });
      });
    } else {
      return null;
    }
  });
  // res.send(Items[Math.floor(Math.random()*Items.length)]);
});
