// Custom Flutter service worker with optimized initialization
// This reduces the timeout issues by streamlining the service worker preparation

const CACHE_NAME = 'careconnect-v1.0.0';
const MAX_CACHE_AGE = 24 * 60 * 60 * 1000; // 24 hours

// Essential files to cache immediately
const ESSENTIAL_FILES = [
  '/',
  '/index.html',
  '/manifest.json',
  '/favicon.png',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png'
];

// Optimized install event - faster initialization
self.addEventListener('install', (event) => {
  console.log('CareConnect SW: Fast install');
  
  // Skip waiting and activate immediately to reduce timeout
  self.skipWaiting();
  
  // Cache essential files in background (non-blocking)
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => cache.addAll(ESSENTIAL_FILES))
      .catch((error) => console.warn('CareConnect SW: Background caching failed:', error))
  );
});

// Optimized activate event - faster activation
self.addEventListener('activate', (event) => {
  console.log('CareConnect SW: Fast activate');
  
  // Take control immediately without waiting for cache cleanup
  self.clients.claim();
  
  // Clean old caches in background (non-blocking)
  caches.keys().then((cacheNames) => {
    cacheNames.forEach((cacheName) => {
      if (cacheName !== CACHE_NAME) {
        caches.delete(cacheName);
      }
    });
  });
});

// Optimized fetch event with network-first strategy for better performance
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);
  
  // Skip non-GET requests and chrome-extension URLs
  if (request.method !== 'GET' || url.protocol === 'chrome-extension:') {
    return;
  }
  
  // Network-first strategy for API calls and dynamic content
  if (url.pathname.includes('/api/') || url.pathname.includes('.json')) {
    event.respondWith(
      fetch(request)
        .then((response) => {
          // Cache successful responses
          if (response.ok) {
            const responseClone = response.clone();
            caches.open(CACHE_NAME).then((cache) => {
              cache.put(request, responseClone);
            });
          }
          return response;
        })
        .catch(() => {
          // Fallback to cache if network fails
          return caches.match(request);
        })
    );
    return;
  }
  
  // Cache-first strategy for static assets
  event.respondWith(
    caches.match(request)
      .then((cachedResponse) => {
        if (cachedResponse) {
          // Check if cache is still fresh
          const cacheDate = cachedResponse.headers.get('date');
          if (cacheDate && (Date.now() - new Date(cacheDate).getTime()) < MAX_CACHE_AGE) {
            return cachedResponse;
          }
        }
        
        // Fetch from network
        return fetch(request)
          .then((response) => {
            // Cache successful responses
            if (response.ok) {
              const responseClone = response.clone();
              caches.open(CACHE_NAME).then((cache) => {
                cache.put(request, responseClone);
              });
            }
            return response;
          })
          .catch(() => {
            // Return cached version as fallback
            return cachedResponse || new Response('Offline', { status: 503 });
          });
      })
  );
});

// Handle push notifications efficiently
self.addEventListener('push', (event) => {
  if (!event.data) return;
  
  try {
    const data = event.data.json();
    const title = data.title || 'CareConnect';
    const options = {
      body: data.body || 'New notification',
      icon: '/icons/Icon-192.png',
      badge: '/icons/Icon-192.png',
      tag: data.tag || 'careconnect-notification',
      requireInteraction: false,
      silent: false
    };
    
    event.waitUntil(
      self.registration.showNotification(title, options)
    );
  } catch (error) {
    console.warn('CareConnect SW: Push notification error:', error);
  }
});

// Handle notification clicks
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  
  event.waitUntil(
    clients.openWindow('/') // Open the app
  );
});

console.log('CareConnect Service Worker: Initialized successfully');
