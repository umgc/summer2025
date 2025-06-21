const cors = require('cors');
const express = require('express');
const session = require('express-session');
const pgSession = require('connect-pg-simple')(session);
const bodyParser = require('body-parser');
const pool = require('./db');
const userRoutes = require('./routes/users');
const friendRoutes = require('./routes/friends');
const authRoutes = require('./routes/auth');
const gamificationRoutes = require('./routes/gamification');
const feedRoutes = require('./routes/feed'); // ✅ Import feed routes

const app = express();
const PORT = 3000;

// ✅ CORS middleware
app.use(cors({
  origin: ['http://localhost:3000', 'http://127.0.0.1:3000', 'http://10.0.2.2:3000'], // ✅ Expand for mobile emulator
  credentials: true
}));

// ✅ Body parser middleware
app.use(bodyParser.json());

// ✅ Serve static image files from uploads folder
app.use('/uploads', express.static('uploads')); // 🔥 This enables photo serving

// ✅ Session middleware
app.use(session({
  store: new pgSession({
    pool: pool,
    tableName: 'user_sessions',
  }),
  secret: '123456',
  resave: false,
  saveUninitialized: false,
  cookie: {
    maxAge: 24 * 60 * 60 * 1000, // 1 day
    secure: false,              // Set to true if using HTTPS
    httpOnly: true,
  },
}));

// ✅ Mounting route modules
app.use('/api/auth', authRoutes);
app.use('/api/gamification', gamificationRoutes);
app.use('/api/feed', feedRoutes); // ✅ Feed routes
app.use('/users', userRoutes); // ✅ users routes
app.use('/friends', friendRoutes); // ✅ Friends request routes


// ✅ Root endpoint
app.get('/', (req, res) => {
  res.send("CareConnect Backend is Running 🚀");
});

// ✅ Start server
app.listen(PORT, () => {
  console.log(`Server started on http://localhost:${PORT}`);
});
