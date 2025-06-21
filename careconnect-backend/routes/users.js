// routes/users.js
const express = require('express');
const router = express.Router();
const pool = require('../db');

// Search users by name or email
router.get('/search', async (req, res) => {
  const query = req.query.query;
  if (!query) return res.status(400).json({ message: 'Query is required' });

  try {
    const result = await pool.query(
      `SELECT id, name, email FROM users WHERE name ILIKE $1 OR email ILIKE $1`,
      [`%${query}%`]
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Search error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
});

module.exports = router;
 
