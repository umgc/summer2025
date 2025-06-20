const express = require('express');
const router = express.Router();
const feedController = require('../controllers/feedController');
const multer = require('multer');

// File upload config
const storage = multer.diskStorage({
  destination: './uploads/',
  filename: (req, file, cb) => cb(null, `${Date.now()}-${file.originalname}`)
});
const upload = multer({ storage });

// Post routes
router.post('/', upload.single('image'), feedController.createPost); // 👈 With image
router.get('/:userId', feedController.getUserFeed);
router.get('/:postId/comments', feedController.getComments);
router.post('/:postId/comments', feedController.createComment);

module.exports = router;
