// routes/friends.js
const express = require('express');
const router = express.Router();
const pool = require('../db');

// Send a friend request
router.post('/request', async (req, res) => {
  const { fromUserId, toUserId } = req.body;
  if (!fromUserId || !toUserId) {
    return res.status(400).json({ message: 'Both user IDs are required' });
  }

  try {
    await pool.query(
      `INSERT INTO friend_requests (from_user_id, to_user_id, status) VALUES ($1, $2, 'pending')`,
      [fromUserId, toUserId]
    );
    res.status(201).json({ message: 'Friend request sent' });
  } catch (err) {
    console.error('Friend request error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
});

module.exports = router;

// Accept a friend request
router.post('/accept', async (req, res) => {
  const { requestId } = req.body;

  if (!requestId) {
    return res.status(400).json({ message: 'Request ID is required' });
  }

  try {
    // Get the friend request
    const result = await pool.query(
      `SELECT from_user_id, to_user_id FROM friend_requests WHERE id = $1 AND status = 'pending'`,
      [requestId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Pending request not found' });
    }

    const { from_user_id, to_user_id } = result.rows[0];

    // Update friend request status
    await pool.query(
      `UPDATE friend_requests SET status = 'accepted' WHERE id = $1`,
      [requestId]
    );

    // Insert into friends table (optional if you want to maintain a separate friends list)
    await pool.query(
      `INSERT INTO friends (user_id_1, user_id_2) VALUES ($1, $2), ($2, $1)`,
      [from_user_id, to_user_id]
    );

    res.json({ message: 'Friend request accepted' });
  } catch (err) {
    console.error('Accept error:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
});

// Get pending friend requests for a user
router.get('/requests/:userId', async (req, res) => {
  const { userId } = req.params;

  try {
    const result = await pool.query(
      `SELECT fr.id, fr.from_user_id, u.name AS from_username
       FROM friend_requests fr
       JOIN users u ON fr.from_user_id = u.id
       WHERE fr.to_user_id = $1 AND fr.status = 'pending'`,
      [userId]
    );

    res.json(result.rows);
  } catch (err) {
    console.error('Failed to fetch friend requests:', err);
    res.status(500).json({ message: 'Internal server error' });
  }
});
