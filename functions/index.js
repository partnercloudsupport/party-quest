const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });


const admin = require('firebase-admin');
admin.initializeApp();

exports.onPlayerAdded = functions.firestore
  .document('Games/{gameId}')
  .onWrite((change, context) => {
    console.log(change.after.data());
    console.log(gameId);
  });