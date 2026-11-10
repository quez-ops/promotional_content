importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyCJqzfwGqXO1p--KjJwaiVONhotGg2mmhk",
  authDomain: "inclass13-auth-64e6b.firebaseapp.com",
  projectId: "inclass13-auth-64e6b",
  storageBucket: "inclass13-auth-64e6b.firebasestorage.app",
  messagingSenderId: "47870117885",
  appId: "1:47870117885:web:2adc3e22fdae45ee5e3b94"
});

const messaging = firebase.messaging();
