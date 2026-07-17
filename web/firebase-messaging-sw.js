importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyC0ewVeqbl1XklqvhqgHYW43KhddWsYU8w",
  appId: "1:629704576770:web:19e849894664150978fc1b",
  messagingSenderId: "629704576770",
  projectId: "window-garden-82313",
  authDomain: "window-garden-82313.firebaseapp.com",
  storageBucket: "window-garden-82313.firebasestorage.app",
  measurementId: "G-DKPZJ2B8NJ"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log("[firebase-messaging-sw.js] Received background message ", payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png"
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
