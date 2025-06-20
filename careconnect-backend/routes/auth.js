const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const multer = require('multer');

// Configure multer for avatar storage
const storage = multer.diskStorage({
  destination: './uploads/',
  filename: (req, file, cb) => cb(null, `${Date.now()}-${file.originalname}`)
});
const upload = multer({ storage });

// Existing routes...
router.post('/register', authController.registerUser);
router.post('/login', authController.loginUser);
router.get('/profile', authController.getProfile);
router.get('/verify/:token', authController.verifyEmail);
router.post('/logout', authController.logoutUser);

// ✅ NEW: Upload avatar route
router.post('/avatar/:userId', upload.single('avatar'), authController.uploadAvatar);

module.exports = router;