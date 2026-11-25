// Firebase Web SDK compatible; service worker para mensajes en segundo plano.
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');
firebase.initializeApp({
  apiKey: 'AIzaSyAjAOMc3Q2q1USyKOrzxpfguL4LQcuVTmo',
  authDomain: 'tiendgorras.firebaseapp.com',
  projectId: 'tiendgorras',
  storageBucket: 'tiendgorras.firebasestorage.app',
  messagingSenderId: '647979020997',
  appId: '1:647979020997:web:7951679f4e55f9672836ac'
});
const messaging = firebase.messaging();
messaging.onBackgroundMessage((payload) => {
  // Los mensajes con notification se muestran automáticamente por FCM.
  if (!payload.notification && payload.data && payload.data.title) {
    return self.registration.showNotification(payload.data.title, {
      body: payload.data.body || '', icon: 'icons/Icon-192.png'
    });
  }
});
