importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyA8vh_epaVSejNhnqoEJ1G7whL1NLc-WSM",
  authDomain: "notes-17086.firebaseapp.com",
  projectId: "notes-17086",
  storageBucket: "notes-17086.firebasestorage.app",
  messagingSenderId: "676273052550",
  appId: "1:676273052550:web:fc9eecbdf974da4867ea07",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/favicon.png",
  };
  return self.registration.showNotification(notificationTitle, notificationOptions);
});