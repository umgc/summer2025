// Simplified Firebase service worker to avoid timeout issues
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js');

// Initialize Firebase with minimal config
firebase.initializeApp({
  apiKey: 'AIzaSyDSZfDwvL4ZYRkEddUyP4adRyvnEMvRvvQ',
  authDomain: 'careconnectptdemo.firebaseapp.com',
  projectId: 'careconnectptdemo',
  storageBucket: 'careconnectptdemo.firebasestorage.app',
  messagingSenderId: '1070028273529',
  appId: '1:1070028273529:web:d88c7e7069e88454ffa1a8'
});

const messaging = firebase.messaging();

// Simplified background message handler
messaging.onBackgroundMessage(function(payload) {
  console.log('Background message received:', payload);
  
  const notificationTitle = payload.notification?.title || 'CareConnect';
  const notificationOptions = {
    body: payload.notification?.body || 'New notification',
    icon: '/favicon.png'
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});
