importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
    apiKey: 'AIzaSyBbr5lbd1eVEnWDdrUgw5vm4_ZrTR172zk',
    appId: '1:130725020117:web:62ea954247e38d8479fd5c',
    messagingSenderId: '130725020117',
    projectId: 'ordrz-app',
    authDomain: 'ordrz-app.firebaseapp.com',
    databaseURL: 'https://ordrz-app-default-rtdb.firebaseio.com',
    storageBucket: 'ordrz-app.appspot.com',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});