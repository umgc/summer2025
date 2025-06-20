const express = require('express');
const router = express.Router();
const gamification = require('../controllers/gamificationController');
const requireLogin = require('../middleware/requireLogin');
const pool = require('../db'); // ✅ Add this to use for the new query

// Existing routes
router.post('/xp/award', requireLogin, gamification.awardXP);
router.get('/xp/progress/:userId', requireLogin, gamification.getXPProgress);
router.get('/achievements/:userId', requireLogin, gamification.getAchievements);
router.get('/achievements/all/:userId', requireLogin, gamification.getAllAchievements);

// ✅ New route to get all achievements (universal list)
router.get('/achievements/all', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, title, description, xp_required, badge_icon FROM achievements ORDER BY id'
    );
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Error fetching all achievements:", error);
    res.status(500).json({ message: 'Server error retrieving achievements.' });
  }
});

module.exports = router;
